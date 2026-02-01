import 'package:flutter/material.dart';
import 'package:ugo_driver/app_state.dart';
import './ride_request_model.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/home/openGoogleMapsNavigation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:ugo_driver/services/floating_bubble_service.dart';

class RideRequestOverlay extends StatefulWidget {
  const RideRequestOverlay({Key? key}) : super(key: key);

  @override
  RideRequestOverlayState createState() => RideRequestOverlayState();
}

class RideRequestOverlayState extends State<RideRequestOverlay>
    with WidgetsBindingObserver {
  static const Color primaryColor = Color(0xFFFF7B10);

  final List<RideRequest> _activeRequests = [];
  final Map<int, int> _timers = {};
  final Map<int, int> _waitTimers = {};
  final Map<int, int> _swipeResets = {};
  final Set<int> _seenRideIds = {};
  late AudioPlayer _audioPlayer;
  bool _isAlerting = false;
  final Set<int> _paymentPendingRides = {};
  String? _selectedPaymentMethod;
  final Set<int> _completedRides = {};

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Track app lifecycle state
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  static const platform = MethodChannel('com.ugocabs.drivers/floating_bubble');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final rideId = FFAppState().activeRideId;
    if (rideId != 0) {
      _fetchRideFromBackend(rideId);
    }
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _configureAudio();
    _initializeNotifications();
    _startTickTimer();
    _initializeFloatingBubbleService();
    _setupOverlayActionHandler();
    _setupMethodChannelHandler();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _appLifecycleState = state;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App went to background - show floating bubble
        _showFloatingBubble();
        break;
      case AppLifecycleState.resumed:
      case AppLifecycleState.detached:
        // App came back to foreground - hide floating bubble immediately
        _hideFloatingBubble();
        break;
    }
  }

  Future<void> _showFloatingBubble() async {
    try {
      await FloatingBubbleService.showFloatingBubble();
      print('🎈 Floating bubble SHOWN - App in background');
    } catch (e) {
      print('Error showing floating bubble: $e');
    }
  }

  Future<void> _hideFloatingBubble() async {
    try {
      await FloatingBubbleService.hideFloatingBubble();
      print('🛑 Floating bubble HIDDEN - App in foreground');
    } catch (e) {
      print('❌ Error hiding floating bubble: $e');
    }
  }

  Future<void> _initializeFloatingBubbleService() async {
    try {
      bool hasPermission = await FloatingBubbleService.checkOverlayPermission();
      if (!hasPermission) {
        // Request permission if not granted
        await FloatingBubbleService.requestOverlayPermission();
        // Try again after a short delay
        await Future.delayed(const Duration(seconds: 2));
        hasPermission = await FloatingBubbleService.checkOverlayPermission();
      }

      if (hasPermission) {
        // Service will be started when needed in showFloatingBubble()
        print(
            '🎈 Floating bubble permission granted - service will start when needed');
      } else {
        print('❌ Floating bubble permission denied');
      }
    } catch (e) {
      print('Error initializing floating bubble service: $e');
    }
  }

  void _setupOverlayActionHandler() {
    FloatingBubbleService.setOverlayActionHandler((action, rideIdString) {
      final rideId = int.tryParse(rideIdString);
      if (rideId != null) {
        _handleOverlayAction(action, rideId);
      }
    });
  }

  void _setupMethodChannelHandler() {
    platform.setMethodCallHandler((call) async {
      print('🎯 Method channel call received: ${call.method}');
      if (call.method == 'onOverlayAction') {
        final Map<String, dynamic> args =
            Map<String, dynamic>.from(call.arguments);
        final String action = args['action'];
        final String rideIdString = args['rideId'];
        print('🎯 Overlay action: $action for ride: $rideIdString');
        final rideId = int.tryParse(rideIdString);
        if (rideId != null) {
          _handleOverlayAction(action, rideId);
        }
      }
    });
  }

  void _showSnack(String message, {Color color = Colors.black}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _fetchRideFromBackend(int rideId) async {
    try {
      final response = await Dio().get(
        "https://ugotaxi.icacorp.org/api/rides/$rideId",
        options: Options(
          headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}",
          },
        ),
      );

      RideRequest ride = RideRequest.fromJson(response.data['data']);
      if (FFAppState().activeRideStatus.isNotEmpty) {
        ride = ride.copyWith(status: FFAppState().activeRideStatus);
      }

      setState(() {
        _activeRequests.clear();
        _activeRequests.add(ride);
        if (ride.status == 'arrived') {
          _waitTimers[ride.id] = 180;
        }
      });
    } catch (e) {
      debugPrint("❌ Failed to restore ride: $e");
    }
  }

  void _configureAudio() {
    try {
      AudioPlayer.global.setAudioContext(AudioContext(
          android: AudioContextAndroid(
            usageType: AndroidUsageType.alarm,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.mixWithOthers,
            ],
          )));
    } catch (e) {
      debugPrint("🔊 Audio Config Error: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for persistent notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ugo_driver_channel',
      'UGO Driver Notifications',
      description: 'Persistent notifications for UGO Driver app',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Create ride requests channel
    const AndroidNotificationChannel rideChannel = AndroidNotificationChannel(
      'ride_requests_channel',
      'Ride Requests',
      description: 'Notifications for new ride requests',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(rideChannel);
  }

  Future<void> _showPersistentNotification() async {
    final activeRides =
        _activeRequests.where((r) => r.status != 'COMPLETED').length;
    final searchingRides =
        _activeRequests.where((r) => r.status == 'SEARCHING').length;

    String title = 'UGO Driver';
    String body = 'App running in background';

    if (activeRides > 0) {
      title = 'Active Ride${activeRides > 1 ? 's' : ''} ($activeRides)';
      body = searchingRides > 0
          ? '$searchingRides ride${searchingRides > 1 ? 's' : ''} waiting for acceptance'
          : 'Ride in progress';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'ugo_driver_channel',
      'UGO Driver Notifications',
      channelDescription: 'Persistent notifications for UGO Driver app',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      999, // Unique ID for persistent notification
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _hidePersistentNotification() async {
    await _localNotifications.cancel(999);
  }

  Future<void> _showRideRequestNotification(RideRequest ride) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'ride_requests_channel',
        'Ride Requests',
        channelDescription: 'Notifications for new ride requests',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        autoCancel: false,
        ongoing: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('accept_ride', 'Accept'),
          AndroidNotificationAction('reject_ride', 'Reject'),
        ],
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotifications.show(
        999, // Use a fixed ID for ride requests
        'New Ride Request',
        'From: ${ride.pickupAddress}\nTo: ${ride.dropAddress}\nFare: ₹${ride.estimatedFare ?? 0}',
        platformChannelSpecifics,
        payload: ride.id.toString(),
      );
    } catch (e) {
      print('❌ Error showing ride request notification: $e');
    }
  }

  void _onNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload == null) return;

    final rideId = int.tryParse(payload);
    if (rideId == null) return;

    // Find the ride in active requests
    final rideIndex = _activeRequests.indexWhere((r) => r.id == rideId);
    if (rideIndex == -1) return;

    final ride = _activeRequests[rideIndex];

    if (response.actionId == 'accept_ride') {
      await _acceptRideFromNotification(ride);
    } else if (response.actionId == 'reject_ride') {
      await _rejectRideFromNotification(ride);
    }

    // Hide the notification after action
    await _hidePersistentNotification();
    // Also hide the overlay if it's showing
    await FloatingBubbleService.hideRideRequestOverlay();
  }

  void _handleOverlayAction(String action, int rideId) async {
    print('🎯 Handling overlay action: $action for ride: $rideId');
    // Find the ride in active requests
    final rideIndex = _activeRequests.indexWhere((r) => r.id == rideId);
    if (rideIndex == -1) {
      print('❌ Ride not found in active requests: $rideId');
      return;
    }

    final ride = _activeRequests[rideIndex];
    print('✅ Found ride: ${ride.id}');

    if (action == 'accept') {
      await _acceptRideFromOverlay(ride);
      // Hide the overlay after accepting
      await FloatingBubbleService.hideRideRequestOverlay();
    } else if (action == 'reject') {
      await _rejectRideFromOverlay(ride);
      // Hide the overlay after rejecting
      await FloatingBubbleService.hideRideRequestOverlay();
    }
  }

  Future<void> _acceptRideFromNotification(RideRequest ride) async {
    _stopAlert();
    try {
      // Bring app to foreground first
      await SystemChannels.platform.invokeMethod('SystemNavigator.pop');

      // Then accept the ride
      await _acceptRide(ride.id);
      print('✅ Ride accepted from notification: ${ride.id}');
    } catch (e) {
      print('❌ Error accepting ride from notification: $e');
    }
  }

  Future<void> _rejectRideFromNotification(RideRequest ride) async {
    try {
      // Remove the ride from active requests
      setState(() {
        _activeRequests.removeWhere((r) => r.id == ride.id);
        _timers.remove(ride.id);
      });

      // Update alert state
      _updateAlertState();

      print('❌ Ride rejected from notification: ${ride.id}');
    } catch (e) {
      print('❌ Error rejecting ride from notification: $e');
    }
  }

  Future<void> _acceptRideFromOverlay(RideRequest ride) async {
    print('🎯 Accepting ride from overlay: ${ride.id}');
    _stopAlert();
    try {
      // For overlay actions (when app is in background), directly accept the ride
      // without trying to bring app to foreground
      await _acceptRide(ride.id);
      print('✅ Ride accepted from overlay: ${ride.id}');
    } catch (e) {
      print('❌ Error accepting ride from overlay: $e');
    }
  }

  Future<void> _rejectRideFromOverlay(RideRequest ride) async {
    try {
      // Remove the ride from active requests
      setState(() {
        _activeRequests.removeWhere((r) => r.id == ride.id);
        _timers.remove(ride.id);
      });

      // Update alert state
      _updateAlertState();

      print('❌ Ride rejected from overlay: ${ride.id}');
    } catch (e) {
      print('❌ Error rejecting ride from overlay: $e');
    }
  }

  void _updateAlertState() {
    // Only play alert if there is at least one ride in SEARCHING status
    final hasSearching = _activeRequests.any((r) => r.status == 'SEARCHING');
    if (!hasSearching) {
      _stopAlert();
    } else {
      _startAlert();
    }

    // Update persistent notification if app is in background
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.inactive) {
      _showPersistentNotification();
    }
  }

  void _startTickTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      bool changed = false;
      final idsToRemove = <int>[];

      setState(() {
        _timers.forEach((id, remaining) {
          if (remaining > 0) {
            _timers[id] = remaining - 1;
            changed = true;
          } else {
            idsToRemove.add(id);
          }
        });

        _waitTimers.forEach((id, remaining) {
          if (remaining > 0) {
            _waitTimers[id] = remaining - 1;
          }
        });

        for (var id in idsToRemove) {
          // Don't remove ride if it's accepted - keep it on the list
          final rideToRemove =
              _activeRequests.where((r) => r.id == id).isNotEmpty
                  ? _activeRequests.firstWhere((r) => r.id == id)
                  : null;
          if (rideToRemove != null &&
              rideToRemove.status.toLowerCase() != 'accepted' &&
              rideToRemove.status.toLowerCase() != 'arrived' &&
              rideToRemove.status.toLowerCase() != 'started' &&
              rideToRemove.status.toLowerCase() != 'completed') {
            _activeRequests.removeWhere((r) => r.id == id);
            _timers.remove(id);
            _seenRideIds.remove(id);
            changed = true;
          }
        }

        if (changed) {
          _updateAlertState();
        }
      });
    });
  }

  void _startAlert() async {
    if (_isAlerting) return;
    try {
      _isAlerting = true;
      await _audioPlayer.play(AssetSource('audios/ride_request.mp3'));
      Vibration.vibrate(pattern: [0, 400, 200, 400], repeat: 0);
    } catch (e) {
      _isAlerting = false;
      debugPrint("🔊 Audio Error: $e");
    }
  }

  void _stopAlert() {
    if (!_isAlerting) return;
    _isAlerting = false;
    _audioPlayer.stop();
    Vibration.cancel();
  }

  void handleNewRide(Map<String, dynamic> rawData) {
    try {
      final updatedRide = RideRequest.fromJson(rawData);
      if (!mounted) return;

      if (updatedRide.status.toLowerCase() == "cancelled") {
        removeRideById(updatedRide.id);
        _showCancelledSnackBar(updatedRide.id);
        return;
      }
      // Only remove ride if it was accepted by another driver (not the current user)
      if (updatedRide.status.toLowerCase() == 'accepted' &&
          updatedRide.driverId != null &&
          updatedRide.driverId != FFAppState().driverid) {
        removeRideById(updatedRide.id);
        return;
      }

      final index = _activeRequests.indexWhere((r) => r.id == updatedRide.id);
      if (index != -1) {
        setState(() {
          _activeRequests[index] = updatedRide;
          if (updatedRide.status == 'arrived' &&
              !_waitTimers.containsKey(updatedRide.id)) {
            _waitTimers[updatedRide.id] = 180;
          }
        });
      } else {
        setState(() {
          _activeRequests.add(updatedRide);
          _seenRideIds.add(updatedRide.id);
          _timers[updatedRide.id] = 30;
        });
        _updateAlertState();

        // Show background overlay if app is in background
        if (_isAppInBackground()) {
          _showBackgroundRideOverlay(updatedRide);
        }
      }
    } catch (e) {
      print("❌ Error parsing ride request: $e");
    }
  }

  bool _isAppInBackground() {
    return _appLifecycleState == AppLifecycleState.paused ||
        _appLifecycleState == AppLifecycleState.inactive ||
        _appLifecycleState == AppLifecycleState.hidden;
  }

  Future<void> _showBackgroundRideOverlay(RideRequest ride) async {
    try {
      // Show the detailed ride request overlay
      await FloatingBubbleService.showRideRequestOverlay(
        ride.pickupAddress,
        ride.dropAddress,
        ride.estimatedFare?.toStringAsFixed(0) ?? '0',
        ride.id.toString(),
        FFAppState().accessToken,
        FFAppState().driverid.toString(),
      );

      // Also show persistent notification as backup
      await _showRideRequestNotification(ride);
    } catch (e) {
      print('❌ Error showing background ride overlay: $e');
    }
  }

  void _showCancelledSnackBar(int rideId) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ride #$rideId has been cancelled"),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void removeRideById(int idToRemove) {
    if (!mounted) return;
    setState(() {
      _activeRequests.removeWhere((ride) => ride.id == idToRemove);
      _timers.remove(idToRemove);
      _waitTimers.remove(idToRemove);
      _swipeResets.remove(idToRemove);
      _seenRideIds.remove(idToRemove);
      _updateAlertState();
    });
  }

  void _resetSwipe(int rideId) {
    if (!mounted) return;
    setState(() {
      _swipeResets[rideId] = (_swipeResets[rideId] ?? 0) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeRequests.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ride count indicator
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${_activeRequests.length} Ride${_activeRequests.length == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _activeRequests.map((ride) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: _isAppInBackground()
                      ? _buildBothCards(ride)
                      : (ride.status == 'SEARCHING'
                          ? _buildSearchingCard(ride)
                          : _buildActiveRideCard(ride)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingCard(RideRequest ride) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2ECC71), width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.directions_car,
                      size: 18, color: Color(0xFF344054)),
                  SizedBox(width: 6),
                  Text("Auto",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF344054))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // First name and mobile number
            if (ride.firstName != null && ride.firstName!.isNotEmpty)
              Text('Name: ${ride.firstName}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            if (ride.mobileNumber != null && ride.mobileNumber!.isNotEmpty)
              Text('Mobile: ${ride.mobileNumber}',
                  style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text("₹${ride.estimatedFare?.toStringAsFixed(0) ?? '0'}",
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF101828))),
                const SizedBox(width: 10),
                const Text("+",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black26)),
                const SizedBox(width: 10),
                const Text("₹6",
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2ECC71))),
              ],
            ),
            const SizedBox(height: 24),
            _buildLocationSection(ride),
            const SizedBox(height: 24),
            _buildAcceptUI(ride),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRideCard(RideRequest ride) {
    final bool isAccepted = ride.status == 'accepted';
    final bool isArrived = ride.status == 'arrived';
    final bool isStarted = ride.status == 'started';
    final bool isOtpVerified = ride.status == 'otp_verified';
    final bool isCompleted = _completedRides.contains(ride.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isCompleted)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton.icon(
              onPressed: () async {
                final pos = await Geolocator.getCurrentPosition();
                await GoogleMapsNavigation.open(
                  originLat: pos.latitude,
                  originLng: pos.longitude,
                  destLat:
                      (isAccepted || isArrived) ? ride.pickupLat : ride.dropLat,
                  destLng:
                      (isAccepted || isArrived) ? ride.pickupLng : ride.dropLng,
                );
              },
              icon: const Icon(Icons.navigation, color: Colors.black),
              label: Text(
                (isAccepted || isArrived) ? "Go to pickup" : "Go to drop",
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC33),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            children: [
              if (isAccepted || isArrived)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text("Customer Verified Location",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.black54)),
                    ],
                  ),
                ),
              if (isArrived && _waitTimers.containsKey(ride.id))
                _buildWaitTimerUI(ride.id),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First name and mobile number
                    if (ride.firstName != null && ride.firstName!.isNotEmpty)
                      Text('Name: ${ride.firstName}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    if (ride.mobileNumber != null &&
                        ride.mobileNumber!.isNotEmpty)
                      Text('Mobile: ${ride.mobileNumber}',
                          style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text("Customer",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(
                      (isAccepted || isArrived)
                          ? ride.pickupAddress
                          : ride.dropAddress,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    if (isAccepted || isArrived) ...[
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message, color: Colors.black),
                        label: const Text("Message customer",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (isAccepted)
                      UgoSwipeButton(
                          key: ValueKey(
                              'swipe_${ride.id}_${_swipeResets[ride.id] ?? 0}'),
                          text: "Arrived",
                          color: Colors.blue.shade700,
                          onSwipe: () {
                            _updateRideStatus(ride.id, 'arrived');
                            FFAppState().activeRideStatus = 'arrived';
                          })
                    else if (isArrived)
                      UgoSwipeButton(
                          key: ValueKey(
                              'swipe_${ride.id}_${_swipeResets[ride.id] ?? 0}'),
                          text: "Start Ride",
                          color: Colors.green.shade700,
                          onSwipe: () {
                            _showOtpDialog(ride.id);
                          })
                    else if (isOtpVerified)
                      UgoSwipeButton(
                          key: ValueKey(
                              'swipe_${ride.id}_${_swipeResets[ride.id] ?? 0}'),
                          text: "Start Ride",
                          color: Colors.green.shade700,
                          onSwipe: () {
                            _updateRideStatus(ride.id, 'started');
                            FFAppState().activeRideStatus = 'started';
                          })
                    else if (isStarted)
                      UgoSwipeButton(
                          key: ValueKey(
                              'swipe_${ride.id}_${_swipeResets[ride.id] ?? 0}'),
                          text: "Complete Ride",
                          color: Colors.red.shade800,
                          onSwipe: () {
                            setState(() => _paymentPendingRides.add(ride.id));
                          })
                    else if (isCompleted)
                      _buildRideCompletedUI(ride),
                    if (_paymentPendingRides.contains(ride.id)) ...[
                      const SizedBox(height: 20),
                      _buildPaymentUI(ride),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBothCards(RideRequest ride) {
    return Column(
      children: [
        _buildSearchingCard(ride),
        const SizedBox(height: 16),
        _buildActiveRideCard(ride),
      ],
    );
  }

  Widget _buildWaitTimerUI(int rideId) {
    final int remaining = _waitTimers[rideId] ?? 0;
    final int minutes = remaining ~/ 60;
    final int seconds = remaining % 60;
    final String timerText =
        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Wait Timer",
                    style: TextStyle(color: Colors.black54, fontSize: 14)),
                Text(timerText,
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const VerticalDivider(width: 20),
          const Expanded(
            flex: 2,
            child: Text(
              "After 3 minutes, you will get extra charge for waiting",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(RideRequest ride) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 10, color: Colors.black)),
                Container(
                    width: 1.5,
                    height: 45,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(1))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${ride.distance?.toStringAsFixed(1) ?? '0.4'} Km",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black)),
                  Text(ride.pickupAddress,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.arrow_drop_down, size: 22, color: Colors.black),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("2 Km",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black)),
                  Text(ride.dropAddress,
                      style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF475467),
                          fontWeight: FontWeight.w500,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptUI(RideRequest ride) {
    final int remaining = _timers[ride.id] ?? 0;
    return Row(
      children: [
        GestureDetector(
          onTap: () => removeRideById(ride.id),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                      value: remaining / 30,
                      strokeWidth: 4,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.red.shade400),
                      backgroundColor: const Color(0xFFF2F4F7))),
              const Icon(Icons.remove, color: Color(0xFF344054), size: 30),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              _stopAlert(); // Stop the alert sound when Accept is pressed
              await _acceptRide(ride.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCC33),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                elevation: 0),
            child: const Text("Accept",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentUI(RideRequest ride) {
    return Column(
      children: [
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => setState(() => _selectedPaymentMethod = "cash"),
          style: ElevatedButton.styleFrom(
              backgroundColor: _selectedPaymentMethod == "cash"
                  ? Colors.green
                  : Colors.grey.shade200,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50)),
          child: const Text("CASH"),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _completeRide(ride.id),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60)),
          child: const Text("CONFIRM & FINISH",
              style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Future<void> _completeRide(int rideId) async {
    try {
      await Dio().post(
          "https://ugotaxi.icacorp.org/api/drivers/update-ride-status",
          data: {"ride_id": rideId, "status": "completed"},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));
      setState(() {
        _paymentPendingRides.remove(rideId);
        _completedRides.add(rideId);
      });
      FFAppState().activeRideId = 0;
      FFAppState().activeRideStatus = '';
      // Ride card will stay visible until driver confirms cash collection
    } catch (e) {
      debugPrint("❌ Complete Ride Error: $e");
    }
  }

  Future<void> _acceptRide(int rideId) async {
    print('🎯 Making API call to accept ride: $rideId');
    _stopAlert();
    try {
      FFAppState().activeRideId = rideId;
      FFAppState().activeRideStatus = 'accepted';
      print(
          '📤 Sending accept request to: https://ugotaxi.icacorp.org/api/rides/rides/$rideId/accept');
      print('📤 Driver ID: ${FFAppState().driverid}');
      print('📤 Token: ${FFAppState().accessToken}');
      final response = await Dio().post(
          "https://ugotaxi.icacorp.org/api/rides/rides/$rideId/accept",
          data: {"driver_id": FFAppState().driverid},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));
      print(
          '📥 Accept API response: ${response.statusCode} - ${response.data}');
      _showSnack("✅ Ride accepted", color: Colors.green);
      setState(() {
        final index = _activeRequests.indexWhere((r) => r.id == rideId);
        if (index != -1) {
          _activeRequests[index] =
              _activeRequests[index].copyWith(status: 'accepted');
        }
      });
    } catch (e) {
      print('❌ Accept API error: $e');
      FFAppState().activeRideId = 0;
      FFAppState().activeRideStatus = '';
      _showSnack("❌ Unable to accept ride ${e.toString()}", color: Colors.red);
    }
  }

  Future<void> _updateRideStatus(int rideId, String status) async {
    try {
      final response = await Dio().put(
          "https://ugotaxi.icacorp.org/api/rides/$rideId",
          data: {"ride_status": status, "driver_id": FFAppState().driverid},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));
      print('Status update response: \\n${response.data}');
      if (status == 'completed') {
        removeRideById(rideId);
        FFAppState().activeRideId = 0;
        FFAppState().activeRideStatus = '';
      } else {
        setState(() {
          final index = _activeRequests.indexWhere((r) => r.id == rideId);
          if (index != -1) {
            _activeRequests[index] =
                _activeRequests[index].copyWith(status: status);
          }
          if (status == 'arrived') {
            _waitTimers[rideId] = 180;
          }
        });
      }
    } catch (e) {
      debugPrint("Status Update Error: $e");
    }
  }

  void _showOtpDialog(int rideId) {
    final controller = TextEditingController();
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text("Enter Passenger OTP"),
                content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 4),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("CANCEL")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _verifyOtp(rideId, controller.text.trim());
                      },
                      child: const Text("VERIFY"))
                ])).then((_) {
      // If the ride is still in a state that requires swiping to start, reset the swipe button
      final index = _activeRequests.indexWhere((r) => r.id == rideId);
      if (index != -1) {
        final r = _activeRequests[index];
        if (r.status == 'arrived' || r.status == 'otp_verified') {
          _resetSwipe(rideId);
        }
      }
    });
  }

  Future<void> _verifyOtp(int rideId, String otp) async {
    try {
      final res = await Dio().post(
          "https://ugotaxi.icacorp.org/api/rides/verify-otp",
          data: {"otp": otp, "ride_id": rideId},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));
      if (res.data['success'] == true) {
        final newStatus = res.data['data']['status'];
        setState(() {
          final idx = _activeRequests.indexWhere((r) => r.id == rideId);
          if (idx != -1)
            _activeRequests[idx] =
                _activeRequests[idx].copyWith(status: newStatus);
          _waitTimers.remove(rideId);
        });
        FFAppState().activeRideStatus = newStatus;
      } else {
        _showSnack("❌ Invalid OTP", color: Colors.red);
        _resetSwipe(rideId);
      }
    } catch (e) {
      debugPrint("❌ OTP ERROR: $e");
      _showSnack("❌ Error verifying OTP", color: Colors.red);
      _resetSwipe(rideId);
    }
  }

  Widget _buildRideCompletedUI(RideRequest ride) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 12),
          const Text(
            "Ride Completed Successfully",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Final Fare",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      "₹${ride.estimatedFare?.toStringAsFixed(0) ?? '0'}",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _completedRides.remove(ride.id);
                _activeRequests.removeWhere((r) => r.id == ride.id);
              });
              _showSnack("✅ Cash collected", color: Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              "CASH COLLECTED",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class UgoSwipeButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onSwipe;

  const UgoSwipeButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onSwipe,
  }) : super(key: key);

  @override
  _UgoSwipeButtonState createState() => _UgoSwipeButtonState();
}

class _UgoSwipeButtonState extends State<UgoSwipeButton> {
  double _position = 0.0;
  bool _isComplete = false;

  @override
  void didUpdateWidget(UgoSwipeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      setState(() {
        _position = 0;
        _isComplete = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final thumbSize = 52.0;
        final maxPosition = maxWidth - thumbSize - 8;

        return Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  widget.text.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned(
                left: 4 + _position,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isComplete) return;
                    setState(() {
                      _position += details.delta.dx;
                      if (_position < 0) _position = 0;
                      if (_position > maxPosition) _position = maxPosition;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isComplete) return;
                    if (_position > maxPosition * 0.8) {
                      setState(() {
                        _position = maxPosition;
                        _isComplete = true;
                      });
                      widget.onSwipe();
                    } else {
                      setState(() {
                        _position = 0;
                      });
                    }
                  },
                  child: Container(
                    height: thumbSize,
                    width: thumbSize,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward, color: widget.color),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
