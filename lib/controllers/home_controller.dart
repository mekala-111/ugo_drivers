import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:ugo_driver/config.dart';
import 'package:ugo_driver/home/incentive_model.dart';
import 'package:ugo_driver/repositories/driver_repository.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart'
    show
        DriverIdfetchCall,
        GetAllDriversCall,
        NotificationHistoryCall,
        AddMoneyToWalletCall;
import 'package:ugo_driver/services/ride_notification_service.dart';

import '../flutter_flow/flutter_flow_util.dart';

const double _locationUpdateThreshold = 50.0;
const double _notifyDistanceThreshold = 100.0;
const Duration _notifyTimeThreshold = Duration(seconds: 2);

/// Holds all Home screen logic: fetch, socket, location, earnings.
/// HomeWidget listens and delegates UI via callbacks.
class HomeController extends ChangeNotifier {
  HomeController({
    required this.onShowKycDialog,
    required this.onShowLocationDisclosure,
    required this.onShowPermissionDialog,
    required this.onShowBackgroundLocationNotice,
    required this.onShowGoOnlinePermissions,
    required this.onShowSnackBar,
    required this.onSocketRideData,
    required this.onFetchRideById,
  }) {
    // ✅ Synchronous Initialization: Ensures UI sees correct state on first frame
    isOnline = FFAppState().isonline; 
    driverName = '${FFAppState().firstName} ${FFAppState().lastName}';
  }

  final Future<void> Function() onShowKycDialog;
  final Future<bool> Function() onShowLocationDisclosure;
  final Future<void> Function() onShowPermissionDialog;
  final Future<bool> Function() onShowBackgroundLocationNotice;
  final Future<bool> Function() onShowGoOnlinePermissions;
  final void Function(String messageKey, {bool isError}) onShowSnackBar;
  final void Function(dynamic data) onSocketRideData;
  final void Function(int rideId) onFetchRideById;

  late io.Socket _socket;
  StreamSubscription<Position>? _locationSub;
  Position? _lastSavedPosition;
  DateTime? _lastNotifyTime;
  Position? _lastNotifyPosition;
  bool _isTrackingLocation = false;
  Timer? _availableDriversTimer;
  bool _socketInitialized = false;
  bool _disposed = false;
  int _currentDistanceFilter = 50;

  // ── State ───────────────────────────────────────────────────────────────────

  LatLng? currentUserLocation;
  double driverHeading = 0.0;
  bool isDataLoaded = false;
  String driverName = '';
  String profileImageUrl = '';
  bool isOnline = false;
  String currentRideStatus = 'IDLE';

  int currentRides = 0;
  double totalIncentiveEarned = 0.0;
  List<IncentiveTier> incentiveTiers = [];
  bool isLoadingIncentives = true;

  // ✅ Track completed incentives to detect newly completed ones
  final Set<int> _completedIncentiveIds = {};

  double todayTotal = 0.0;
  int todayRideCount = 0;
  double todayWallet = 0.0;
  double lastRideAmount = 0.0;
  bool isLoadingEarnings = true;

  int availableDriversCount = 0;
  int notificationUnreadCount = 0;

  // ── Init ───────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // ✅ Re-assert side effects for persisted Online state
    if (isOnline) {
      _startLocationTracking();
      RideNotificationService().showOnlineNotification();
    }
    _fetchInitialRideStatus();
    await Future.wait([
      _fetchDriverProfile(),
      _fetchIncentiveData(),
      _fetchTodayEarnings(),
    ]);
    isDataLoaded = true;
    _notify();
    _initSocket();
    _fetchNotificationCount();
  }
  /// Call this after the user opens the notifications screen.
    Future<void> refreshNotificationCount() async {
      await _fetchNotificationCount();
    }
   
   
    void resetNotificationCount() {
  notificationUnreadCount = 0;
  _notify();
}

  Future<void> _fetchNotificationCount() async {
  if (_disposed) return;
  final token = FFAppState().accessToken;
  if (token.isEmpty) return;
  try {
    final res = await NotificationHistoryCall.call(token: token);
    if (_disposed || !res.succeeded) return;
    final list = NotificationHistoryCall.notifications(res.jsonBody);
    if (list == null) return;
    int count = 0;
    for (final n in list) {
      final isRead = getJsonField(n, r'$.is_read');
      if (isRead != true) count++;
    }
    if (_disposed) return;
    notificationUnreadCount = count;
    // ✅ Keep FFAppState in sync too
    FFAppState().update(() {
      FFAppState().notificationUnreadCount = count;
    });
    _notify();
  } catch (_) {}
}

  void handlePendingRideFromNotification(int rideId) {
    if (rideId <= 0) return;
    onFetchRideById(rideId);
  }

  Future<void> _fetchDriverProfile() async {
    final userDetails = await DriverRepository.instance.fetchDriverProfile(
      token: FFAppState().accessToken,
      driverId: FFAppState().driverid,
    );
    final postQR = await DriverRepository.instance.fetchPostQR(
      token: FFAppState().accessToken,
      driverId: FFAppState().driverid,
    );

    if (_disposed) return;

    if (kDebugMode) {
      debugPrint('🔍 === Driver Profile Response ===');
      debugPrint('Response Succeeded: ${userDetails.succeeded}');
      debugPrint('Response JSON: ${userDetails.jsonBody}');
    }

    if (userDetails.jsonBody != null) {
      final fetchedName = getJsonField(
        userDetails.jsonBody,
        r'''$.data.first_name''',
      ).toString();
      if (fetchedName != 'null' && fetchedName.isNotEmpty) {
        driverName = fetchedName;
      }

      final img = DriverIdfetchCall.profileImage(userDetails.jsonBody);

      if (kDebugMode) {
        debugPrint('🖼️ Raw img value from API: $img');
        debugPrint('🖼️ img is null: ${img == null}');
        debugPrint('🖼️ img is empty: ${img?.isEmpty ?? true}');
      }

      if (img != null && img.isNotEmpty) {
        profileImageUrl =
            img.startsWith('http') ? img : '${Config.baseUrl}/$img';
        // Pre-cache or validate URL if needed, but the main.dart change 
        // already prevents the 404 from being a "Fatal Crash".
        if (kDebugMode) {
          debugPrint('✅ Final profileImageUrl: $profileImageUrl');
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ No profile image found in response');
        }
      }
    }

    // Preferred city: support multiple API shapes (preferred_city_id, preferred_city.id, city_id)
    final body = userDetails.jsonBody;
    int? parsedCityId;
    String? parsedCityName;
    if (body != null) {
      final preferredCityIdRaw =
          getJsonField(body, r'''$.data.preferred_city_id''');
      if (preferredCityIdRaw != null) {
        parsedCityId = int.tryParse(preferredCityIdRaw.toString());
      }
      if (parsedCityId == null || parsedCityId <= 0) {
        final preferredCityObj =
            getJsonField(body, r'''$.data.preferred_city''');
        if (preferredCityObj != null && preferredCityObj is Map) {
          final id = preferredCityObj['id'];
          if (id != null) parsedCityId = int.tryParse(id.toString());
          final name = preferredCityObj['name']?.toString();
          if (name != null && name.isNotEmpty) parsedCityName = name;
        }
      }
      if (parsedCityId == null || parsedCityId <= 0) {
        final cityIdRaw = getJsonField(body, r'''$.data.city_id''');
        if (cityIdRaw != null) {
          parsedCityId = int.tryParse(cityIdRaw.toString());
        }
      }
    }
    if (parsedCityId != null && parsedCityId > 0) {
      FFAppState().preferredCityId = parsedCityId;
      if (parsedCityName != null && parsedCityName.isNotEmpty) {
        FFAppState().preferredCityName = parsedCityName;
      }
    }
    // If API did not return a preferred city, keep existing app state (e.g. set during registration)

    FFAppState().kycStatus = getJsonField(
      (userDetails.jsonBody ?? ''),
      r'''$.data.kyc_status''',
    ).toString().trim();
    FFAppState().qrImage = getJsonField(
      (postQR.jsonBody ?? ''),
      r'''$.data.qr_code_image''',
    ).toString();

    final isOnlineFromApi = DriverIdfetchCall.isonline(userDetails.jsonBody);
    
    // ✅ SYNC LOGIC:
    // If the driver is NOT locally online, but the API says they ARE online, 
    // it means a previous session was left hanging. Sync it.
    if (!isOnline && isOnlineFromApi == true) {
      if (kDebugMode) debugPrint('♻️ Syncing Online status from API (Previously hanging session)');
      isOnline = true;
      FFAppState().isonline = true;
      _startLocationTracking();
      RideNotificationService().showOnlineNotification();
    } 
    // If the driver IS locally online, but the API says they are NOT, 
    // we already re-asserted in init() if it was silent, but we'll double-check here.
    else if (isOnline && isOnlineFromApi != true) {
      if (kDebugMode) debugPrint('♻️ Re-asserting Online status (Server mismatch)');
      await goOnline(silent: true);
    } else {
      // If API and local state are consistent, ensure FFAppState is updated
      isOnline = isOnlineFromApi == true;
      FFAppState().isonline = isOnline; // Sync local intent with API
    }

    if (isOnline) {
      _fetchAvailableDrivers();
      _availableDriversTimer?.cancel();
      _availableDriversTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => _fetchAvailableDrivers(),
      );
    }
    _notify();
  }

  void _fetchInitialRideStatus() {
    if (FFAppState().activeRideId != 0) {
      currentRideStatus = 'FETCHING';
      _notify();
    }
  }

  Future<void> _fetchAvailableDrivers() async {
    if (!isOnline || _disposed) return;
    try {
      final res = await DriverRepository.instance.getAllDrivers(
        token: FFAppState().accessToken,
      );
      if (_disposed) return;
      if (res.succeeded && res.jsonBody != null) {
        availableDriversCount =
            GetAllDriversCall.availableDrivers(res.jsonBody).length;
        _notify();
      }
    } catch (_) {}
  }

  // ── Online/Offline ─────────────────────────────────────────────────────────

  Future<void> goOnline({bool silent = false}) async {
    if (FFAppState().kycStatus.trim().toLowerCase() != 'approved') {
      isOnline = false;
      _notify();
      if (!silent) await onShowKycDialog();
      return;
    }

    if (FFAppState().preferredCityId <= 0) {
      isOnline = false;
      _notify();
      if (!silent) onShowSnackBar('drv_select_preferred_city', isError: true);
      return;
    }

    // First time going online: show "Give all permissions" (Display over apps, Battery, Background Location)
    if (!FFAppState().hasSeenGoOnlinePermissions) {
      if (silent) {
        isOnline = false;
        _notify();
        return;
      }
      final completed = await onShowGoOnlinePermissions();
      if (!completed) {
        isOnline = false;
        _notify();
        return;
      }
    }

    // Rapido-style: location requested at pre-login. Only show disclosure if not yet granted.
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      if (!silent) await onShowPermissionDialog();
      isOnline = false;
      _notify();
      return;
    }

    // ONLY show disclosure if permission is actually denied
    if (permission == LocationPermission.denied) {
      if (silent) {
        isOnline = false;
        _notify();
        return;
      }
      final agreed = await onShowLocationDisclosure();
      if (!agreed) {
        isOnline = false;
        _notify();
        return;
      }
      // Request permission after user agrees to disclosure
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await onShowPermissionDialog();
        isOnline = false;
        _notify();
        return;
      }
    }

    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Geolocator error: $e');
    }

    await DriverRepository.instance.updateDriver(
      id: FFAppState().driverid,
      token: FFAppState().accessToken,
      isonline: null,
      latitude: position?.latitude,
      longitude: position?.longitude,
      fcmToken: FFAppState().fcmToken.isNotEmpty ? FFAppState().fcmToken : null,
    );

    final res = await DriverRepository.instance.setOnlineStatus(
      token: FFAppState().accessToken,
      isOnline: true,
    );

    if (_disposed) return;
    if (res.succeeded) {
      isOnline = true;
      _startLocationTracking(
          skipDisclosure: true); // Already shown in goOnline()
      RideNotificationService().showOnlineNotification();
      _fetchAvailableDrivers();
      _availableDriversTimer?.cancel();
      _availableDriversTimer = Timer.periodic(
        const Duration(seconds: 45),
        (_) => _fetchAvailableDrivers(),
      );
      if (!silent) onShowSnackBar('drv_you_online', isError: false);
    } else {
      isOnline = false;
      if (!silent) {
        final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString();
        if (msg != null && msg.isNotEmpty) {
          onShowSnackBar(msg, isError: true);
        } else {
          onShowSnackBar('drv_go_online_failed', isError: true);
        }
      }
    }
    _notify();
  }

  Future<void> goOffline() async {
    _stopLocationTracking();
    RideNotificationService().hideOnlineNotification();
    final res = await DriverRepository.instance.setOnlineStatus(
      token: FFAppState().accessToken,
      isOnline: false,
    );

    if (!res.succeeded) {
      isOnline = true;
      final msg = getJsonField(res.jsonBody ?? {}, r'$.message')?.toString();
      if (msg != null && msg.isNotEmpty) {
        onShowSnackBar(msg, isError: true);
      } else {
        onShowSnackBar('drv_failed_offline', isError: true);
      }
    } else {
      await DriverRepository.instance.updateDriver(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
        isonline: false,
        latitude: null,
        longitude: null,
      );
    }
    if (_disposed) return;
    _notify();
  }

  Future<void> toggleOnlineStatus() async {
    final intendedValue = !isOnline;

    if (!intendedValue) {
      final status = currentRideStatus.toUpperCase();
      if (['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP'].contains(status)) {
        onShowSnackBar('drv_cannot_offline', isError: true);
        return;
      }
    }

    isOnline = intendedValue;
    FFAppState().isonline = intendedValue; // ✅ Persist user's explicit manual toggle intent
    _notify();

    if (intendedValue) {
      await goOnline();
    } else {
      await goOffline();
    }
  }

  Future<void> onAppResumed() async {
    // If the driver intended to stay online, silently ping the backend to ensure they were not dropped
    if (FFAppState().isonline) {
      if (kDebugMode) debugPrint('♻️ App Resumed: Re-asserting Online status to ensure background drop did not happen');
      await DriverRepository.instance.setOnlineStatus(
        token: FFAppState().accessToken,
        isOnline: true,
      );
    }
  }

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _startLocationTracking({bool skipDisclosure = false}) async {
    if (_isTrackingLocation) return;
    _isTrackingLocation = true;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isTrackingLocation = false;
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (!skipDisclosure && permission == LocationPermission.denied) {
      final agreed = await onShowLocationDisclosure();
      if (!agreed) {
        _isTrackingLocation = false;
        return;
      }
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isTrackingLocation = false;
        await onShowPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isTrackingLocation = false;
      await onShowPermissionDialog();
      return;
    }

    // Rapido/Uber-style: require background location for ride matching when app is backgrounded
    if (Platform.isAndroid &&
        permission == LocationPermission.whileInUse &&
        !FFAppState().hasAskedBackgroundLocation) {
      FFAppState().hasAskedBackgroundLocation = true;
      final agreed = await onShowBackgroundLocationNotice();
      if (!agreed) {
        _isTrackingLocation = false;
        return;
      }
      final upgraded = await Geolocator.requestPermission();
      if (upgraded == LocationPermission.denied ||
          upgraded == LocationPermission.deniedForever ||
          upgraded == LocationPermission.whileInUse) {
        _isTrackingLocation = false;
        await onShowPermissionDialog();
        return;
      }
    }

    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _lastSavedPosition = initialPosition;
      await _updateLocationToServer(initialPosition);
      if (_disposed) return;
      currentUserLocation =
          LatLng(initialPosition.latitude, initialPosition.longitude);
      driverHeading = initialPosition.heading;
      _notify();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting position: $e');
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: _currentDistanceFilter,
      ),
    ).listen(_handleLocationUpdate);
  }

  void _adjustLocationFilter(String status) {
    int newFilter = 50;
    if (status == 'ACCEPTED' ||
        status == 'ARRIVED' ||
        status == 'STARTED' ||
        status == 'ONTRIP') {
      newFilter = 10;
    }

    if (_currentDistanceFilter != newFilter && _isTrackingLocation) {
      _currentDistanceFilter = newFilter;
      _locationSub?.cancel();
      _locationSub = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: _currentDistanceFilter,
        ),
      ).listen(_handleLocationUpdate);
      if (kDebugMode) {
        debugPrint(
            'Location tracking distance filter updated to: $_currentDistanceFilter meters');
      }
    }
  }

  Future<void> _handleLocationUpdate(Position newPosition) async {
    final hasActiveRide = ['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP']
        .contains(currentRideStatus.toUpperCase());

    if (_lastSavedPosition == null) {
      _lastSavedPosition = newPosition;
      await _updateLocationToServer(newPosition);
      if (_disposed) return;
      currentUserLocation = LatLng(newPosition.latitude, newPosition.longitude);
      driverHeading = newPosition.heading;
      _lastNotifyTime = DateTime.now();
      _lastNotifyPosition = newPosition;
      _notify();
      return;
    }

    final distanceInMeters = Geolocator.distanceBetween(
      _lastSavedPosition!.latitude,
      _lastSavedPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    if (distanceInMeters >= _locationUpdateThreshold) {
      await _updateLocationToServer(newPosition);
      _lastSavedPosition = newPosition;
    }

    if (_disposed) return;
    currentUserLocation = LatLng(newPosition.latitude, newPosition.longitude);
    driverHeading = newPosition.heading;

    if (hasActiveRide) {
      _notify();
    } else {
      final shouldNotify = _lastNotifyTime == null ||
          _lastNotifyPosition == null ||
          DateTime.now().difference(_lastNotifyTime!) >= _notifyTimeThreshold ||
          Geolocator.distanceBetween(
                _lastNotifyPosition!.latitude,
                _lastNotifyPosition!.longitude,
                newPosition.latitude,
                newPosition.longitude,
              ) >=
              _notifyDistanceThreshold;
      if (shouldNotify) {
        _lastNotifyTime = DateTime.now();
        _lastNotifyPosition = newPosition;
        _notify();
      }
    }
  }

  Future<void> _updateLocationToServer(Position position) async {
    try {
      await DriverRepository.instance.updateDriver(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
        isonline: true,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating location: $e');
    }
  }

  void _stopLocationTracking() {
    _locationSub?.cancel();
    _locationSub = null;
    _isTrackingLocation = false;
    _lastSavedPosition = null;
    _lastNotifyTime = null;
    _lastNotifyPosition = null;
    _availableDriversTimer?.cancel();
    _availableDriversTimer = null;
  }

  void setUserLocation(LatLng? loc) {
    currentUserLocation = loc;
    _notify();
  }

  // ── Socket ─────────────────────────────────────────────────────────────────
  void _initSocket() {
    if (_socketInitialized) return;
    _socketInitialized = true;

    final token = FFAppState().accessToken;
    final driverId = FFAppState().driverid;

    _socket = io.io(
      Config.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection() // keep auto-reconnect
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );

    _socket.onConnect((_) {
      if (kDebugMode) debugPrint('Socket CONNECTED');
      // This will also fire after a successful reconnect,
      // so we only need to emit watch_entity here.
      _socket.emit('watch_entity', {'type': 'driver', 'id': driverId});
    });

    // Optional: just log reconnect, do NOT re-emit watch_entity here
    _socket.onReconnect((_) {
      if (kDebugMode) debugPrint('Socket RECONNECTED');
      // No emit here to avoid re-snapshotting old rides as “new”
    });

    // Ensure we don't accumulate multiple listeners
    _socket.off('driver_rides');
    _socket.off('ride_updated');
    _socket.off('ride_taken');
    _socket.off('ride_assigned');

    _socket.on('driver_rides', (data) {
      if (!_disposed) onSocketRideData(data);
    });

    _socket.on('ride_updated', (data) {
      if (kDebugMode) debugPrint('🔔 Socket ride_updated event: $data');
      if (!_disposed) onSocketRideData(data);
    });

    // Rapido-style: when another driver accepts, backend may emit ride_taken/ride_assigned
    void onRideTaken(dynamic data) {
      if (_disposed) return;
      final d = data is Map ? Map<String, dynamic>.from(Map.from(data)) : null;
      if (d == null) return;

      final rideId = d['ride_id'] ?? d['rideId'];
      final otherDriverId = d['driver_id'];
      final myId = FFAppState().driverid;

      if (rideId != null && otherDriverId != null && otherDriverId != myId) {
        onSocketRideData(
          {'id': rideId, 'driver_id': otherDriverId, 'ride_status': 'ACCEPTED'},
        );
      }
    }

    _socket.on('ride_taken', onRideTaken);
    _socket.on('ride_assigned', onRideTaken);

    _socket.connect();
  }

  // ── Incentives & Earnings ──────────────────────────────────────────────────

  /// Fetches driver's active incentives from API and filters to show ONLY currently running ones.
  /// Running incentives have progress_status == 'ongoing'.
  /// The ride count is incremented automatically when rides are completed.
  /// This is called:
  /// 1. On app initialization
  /// 2. After each ride completion via onRideComplete()
  Future<void> _fetchIncentiveData() async {
    try {
      isLoadingIncentives = true;
      _notify();

      final response = await DriverRepository.instance.getDriverIncentives(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (_disposed) return;
      if (response.succeeded) {
        final incentivesArray =
            getJsonField(response.jsonBody, r'''$.data''', true);

        if (incentivesArray != null && incentivesArray is List) {
          // 🎯 Filter to show ONLY currently running incentives
          // Completed or locked incentives are hidden from the main panel
          final runningIncentives = incentivesArray
              .where((item) => item['progress_status'] == 'ongoing')
              .toList();

          if (kDebugMode) {
            debugPrint(
                '📊 Incentives fetched: Total=${incentivesArray.length}, Running=${runningIncentives.length}');
            for (var i in runningIncentives) {
              final completed = i['completed_rides'] ?? 0;
              final target = i['target_rides'] ?? 0;
              debugPrint(
                  '  🎯 ${i['incentive']?['name']} - Progress: $completed/$target rides - Status: ${i['progress_status']}');
            }
          }

          // ✅ Check for newly completed incentives
          double newlyCompletedRewards = 0.0;
          List<String> completedIncentiveNames = [];
          for (var item in incentivesArray) {
            final incentiveId = item['id'] ?? 0;
            final status = item['progress_status'] ?? '';
            if (status == 'completed' &&
                !_completedIncentiveIds.contains(incentiveId)) {
              _completedIncentiveIds.add(incentiveId);
              final name = item['incentive']?['name'] ?? 'Incentive';
              final reward =
                  double.tryParse((item['reward_amount'] ?? '0').toString()) ??
                      0.0;
              newlyCompletedRewards += reward;
              completedIncentiveNames.add(name);
              debugPrint(
                  '🎉 Newly completed incentive detected: $name - Reward: ₹$reward');
            }
          }

          // ✅ Trigger wallet update for newly completed incentives
          if (newlyCompletedRewards > 0) {
            debugPrint(
                '💰 Adding ₹$newlyCompletedRewards to wallet for completed incentives');
            await _addIncentiveRewardToWallet(
                newlyCompletedRewards, completedIncentiveNames);
          }

          // Calculate current rides count from running incentives
          currentRides = 0;
          for (final item in runningIncentives) {
            final completed = item['completed_rides'] ?? 0;
            if (completed > currentRides) currentRides = completed;
          }

          if (kDebugMode) {
            debugPrint('✅ Updated ride count: $currentRides rides completed');
          }

          // Calculate total earned from all running incentives
          totalIncentiveEarned = 0.0;
          for (final item in runningIncentives) {
            if (item['progress_status'] == 'completed') {
              final rewardStr = item['reward_amount'] ?? '0';
              totalIncentiveEarned += double.tryParse(rewardStr) ?? 0.0;
            }
          }

          // Convert to IncentiveTier objects for UI display
          incentiveTiers = runningIncentives.map<IncentiveTier>((item) {
            return IncentiveTier(
              id: item['id'] ?? 0,
              targetRides: item['target_rides'] ?? 0,
              rewardAmount:
                  double.tryParse(item['reward_amount'] ?? '0') ?? 0.0,
              isLocked: false, // Running incentives are never locked
              description: item['incentive']?['name'],
            );
          }).toList();
        } else {
          incentiveTiers = [];
        }
      } else {
        incentiveTiers = [];
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching incentive data: $e');
      incentiveTiers = [];
    } finally {
      if (!_disposed) {
        isLoadingIncentives = false;
        _notify();
      }
    }
  }

  /// Add completed incentive reward to wallet
  Future<void> _addIncentiveRewardToWallet(
      double amount, List<String> incentiveNames) async {
    try {
      if (kDebugMode) {
        debugPrint(
            '💰 Processing wallet update for ₹$amount (${incentiveNames.length} incentives)');
      }

      final res = await AddMoneyToWalletCall.call(
        driverId: FFAppState().driverid,
        amount: amount,
        currency: 'INR',
        token: FFAppState().accessToken,
      );

      if (res.succeeded) {
        if (kDebugMode) {
          debugPrint(
              '✅ Incentive reward ₹$amount added to wallet successfully!');
        }
        onShowSnackBar('incentive_reward_added', isError: false);
      } else {
        if (kDebugMode) {
          debugPrint(
              '⚠️ Failed to add incentive reward to wallet: ${res.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error adding incentive reward to wallet: $e');
      }
    }
  }

  Future<void> _fetchTodayEarnings() async {
    try {
      isLoadingEarnings = true;
      _notify();

      final response = await DriverRepository.instance.getTodayEarnings(
        driverId: FFAppState().driverid,
        token: FFAppState().accessToken,
        period: 'daily',
      );

      if (_disposed) return;
      if (response.succeeded) {
        final data = response.jsonBody['data'];
        todayTotal = (data['totalEarnings'] ?? 0).toDouble();
        todayRideCount = data['totalRides'] ?? 0;
        todayWallet = (data['walletEarnings'] ?? 0).toDouble();
        final rides = data['rides'] as List? ?? [];
        if (rides.isNotEmpty) {
          lastRideAmount = (rides.first['amount'] ?? 0).toDouble();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Earnings error: $e');
    } finally {
      if (!_disposed) {
        isLoadingEarnings = false;
        _notify();
      }
    }
  }

  Future<void> fetchTodayEarnings() => _fetchTodayEarnings();
  Future<void> fetchIncentiveData() => _fetchIncentiveData();

  void setRideStatus(String status) {
    currentRideStatus = status;
    _adjustLocationFilter(status);
    _notify();
  }

  void onRideComplete() {
    if (_disposed) return;
    currentRideStatus = 'IDLE';
    _notify();
    debugPrint('🔄 Ride completed. Refreshing earnings and incentives...');
    _fetchTodayEarnings();
    _fetchIncentiveData(); // ✅ Explicitly refresh incentives to update ride count
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopLocationTracking();
    if (_socketInitialized) {
      try {
        _socket.disconnect();
      } catch (_) {}
    }
    super.dispose();
  }
}
