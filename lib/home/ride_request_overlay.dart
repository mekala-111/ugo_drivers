import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'ride_request_model.dart';
import 'openGoogleMapsNavigation.dart';

class RideRequestOverlay extends StatefulWidget {
  const RideRequestOverlay({Key? key}) : super(key: key);

  @override
  RideRequestOverlayState createState() => RideRequestOverlayState();
}

class RideRequestOverlayState extends State<RideRequestOverlay> {
  // --- CONFIGURATION ---
  static const Color primaryColor = Color(0xFFFF7B10);
  static const String BASE_URL = "https://ugotaxi.icacorp.org/api";

  // --- STATE VARIABLES ---
  final List<RideRequest> activeRequests = [];
  final Map<int, int> timers = {};
  final Set<int> seenRideIds = {};
  final Set<int> paymentPendingRides = {};
  final Set<int> completedRides = {};

  // --- AUDIO & ALERTS ---
  late AudioPlayer audioPlayer;
  bool isAlerting = false;
  Timer? tickTimer;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  // --- PAYMENT ---
  String? selectedPaymentMethod; // 'cash', 'razorpay'
  int? cashCollectedRideId;
  bool cashCollected = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    _configureAudio();
    _initializeNotifications();
    _startTickTimer();

    // RESTORE STATE: If app was killed, check if we have an active ride
    final int savedRideId = FFAppState().activeRideId;
    if (savedRideId != 0) {
      _fetchRideFromBackend(savedRideId);
    }
  }

  @override
  void dispose() {
    tickTimer?.cancel();
    audioPlayer.dispose();
    _stopAlert();
    super.dispose();
  }

  // --- LOGIC: AUDIO & NOTIFICATIONS ---

  void _configureAudio() {
    try {
      AudioPlayer.global.setAudioContext(const AudioContext(
        android: AudioContextAndroid(
          usageType: AndroidUsageType.alarm,
          contentType: AndroidContentType.sonification,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: [
            AVAudioSessionOptions.defaultToSpeaker,
            AVAudioSessionOptions.mixWithOthers
          ],
        ),
      ));
    } catch (e) {
      debugPrint("Audio Config Error: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(
        android: androidSettings, iOS: DarwinInitializationSettings());
    await localNotifications.initialize(settings);
  }

  void _updateAlertState() {
    // Alert if any ride is in SEARCHING state
    bool hasSearchingRequests = activeRequests
        .any((r) => (r.status ?? '').toUpperCase() == 'SEARCHING');
    if (hasSearchingRequests) {
      _startAlert();
    } else {
      _stopAlert();
    }
  }

  Future<void> _startAlert() async {
    if (isAlerting) return;
    try {
      isAlerting = true;
      // Ensure 'assets/audios/riderequest.mp3' exists
      await audioPlayer.play(AssetSource('audios/riderequest.mp3'));
      Vibration.vibrate(pattern: [0, 400, 200, 400], repeat: 0);
    } catch (e) {
      isAlerting = false;
      debugPrint("Audio Play Error: $e");
    }
  }

  void _stopAlert() {
    if (!isAlerting) return;
    isAlerting = false;
    audioPlayer.stop();
    Vibration.cancel();
  }

  void _startTickTimer() {
    tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      bool changed = false;
      final idsToRemove = <int>[];

      setState(() {
        timers.forEach((id, remaining) {
          if (remaining > 0) {
            timers[id] = remaining - 1;
            changed = true;
          } else {
            idsToRemove.add(id);
          }
        });

        for (var id in idsToRemove) {
          activeRequests.removeWhere((r) => r.id == id);
          timers.remove(id);
          seenRideIds.remove(id);
          changed = true;
        }
      });

      if (changed) _updateAlertState();
    });
  }

  Future<void> _showNotification(RideRequest ride) async {
    const androidDetails = AndroidNotificationDetails(
      'ride_requests',
      'UGO Ride Requests',
      channelDescription: 'New ride requests',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      color: primaryColor,
    );
    const details = NotificationDetails(android: androidDetails);
    await localNotifications.show(
        ride.id,
        "New UGO Ride Request!",
        "Fare: ₹${ride.estimatedFare?.toStringAsFixed(0)} | ${ride.distance} km",
        details);
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
    ));
  }

  // --- LOGIC: RIDE MANAGEMENT ---

  // Called via Socket from HomeWidget
  void handleNewRide(Map<String, dynamic> rawData) {
    try {
      // Normalize data
      final updatedRide = RideRequest.fromJson(rawData);
      if (!mounted) return;

      final String status = (updatedRide.status ?? '').toUpperCase();

      // 1. Handle CANCELLATION
      if (status == 'CANCELLED') {
        _removeRideById(updatedRide.id);
        _showSnack("Ride #${updatedRide.id} cancelled", Colors.red);
        return;
      }

      // 2. Handle ALREADY ACCEPTED by others
      if (status == 'ACCEPTED' &&
          updatedRide.driverId != FFAppState().driverid) {
        _removeRideById(updatedRide.id);
        // Silent removal is standard, or show a toast
        return;
      }

      final index = activeRequests.indexWhere((r) => r.id == updatedRide.id);

      if (index != -1) {
        // UPDATE EXISTING
        setState(() {
          activeRequests[index] = updatedRide;
        });

        // If status changed to something that stops alerting
        _updateAlertState();
      } else {
        // ADD NEW RIDE

        // RAPIDO LOGIC: If we are already ON TRIP, we can ignore new SEARCHING requests
        // or add them to queue. Here we add them but don't force switch view.
        bool busy = activeRequests.any((r) => [
              'ACCEPTED',
              'ARRIVED',
              'STARTED',
              'OTPVERIFIED'
            ].contains(r.status?.toUpperCase()));

        if (busy && status == 'SEARCHING') {
          // Optional: You can choose to IGNORE new requests while busy
          // return;
        }

        setState(() {
          activeRequests.add(updatedRide);
          seenRideIds.add(updatedRide.id);

          if (status == 'SEARCHING') {
            timers[updatedRide.id] = 45; // 45 seconds countdown
          }
        });

        if (status == 'SEARCHING') {
          _showNotification(updatedRide);
        }
        _updateAlertState();
      }
    } catch (e) {
      debugPrint("Error parsing ride: $e");
    }
  }

  Future<void> acceptRide(int rideId) async {
    try {
      _stopAlert();

      // Optimistic UI Update
      setState(() {
        final index = activeRequests.indexWhere((r) => r.id == rideId);
        if (index != -1) {
          activeRequests[index] =
              activeRequests[index].copyWith(status: 'accepted');
        }
      });

      // API Call
      await Dio().post(
        "$BASE_URL/rides/rides/$rideId/accept",
        data: {"driver_id": FFAppState().driverid},
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );

      // State Update
      FFAppState().activeRideId = rideId;
      FFAppState().activeRideStatus = 'accepted';
      _showSnack("Ride Accepted", Colors.green);

      // Fetch Full Details (for precise Lat/Lng) & Navigate
      await _fetchRideFromBackend(rideId);
      final ride = activeRequests.firstWhere((r) => r.id == rideId);

      // Auto Launch Navigation
      final pos = await Geolocator.getCurrentPosition();
      await GoogleMapsNavigation.open(
          originLat: pos.latitude,
          originLng: pos.longitude,
          destLat: ride.pickupLat,
          destLng: ride.pickupLng);
    } on DioException catch (e) {
      // Rollback
      if (e.response?.statusCode == 409 || e.response?.statusCode == 400) {
        _showSnack("Already accepted by another driver", Colors.red);
        _removeRideById(rideId);
      } else {
        _showSnack("Error accepting ride", Colors.red);
      }
    }
  }

  Future<void> verifyOtp(int rideId, String otp) async {
    try {
      final response = await Dio().post(
        "$BASE_URL/rides/verify-otp",
        data: {"otp": otp, "ride_id": rideId},
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );

      if (response.data['success'] == true) {
        // Status usually becomes 'started'
        const newStatus = 'started';

        await _updateLocalRideStatus(rideId, newStatus);

        Navigator.pop(context); // Close OTP Dialog
        _showSnack("OTP Verified. Trip Started!", Colors.green);

        // Get Ride details to Navigate to Drop
        final ride = activeRequests.firstWhere((r) => r.id == rideId,
            orElse: () => RideRequest(
                id: 0,
                userId: 0,
                status: '',
                pickupAddress: '',
                dropAddress: '',
                pickupLat: 0,
                pickupLng: 0,
                dropLat: 0,
                dropLng: 0));

        if (ride.id != 0) {
          final pos = await Geolocator.getCurrentPosition();
          await GoogleMapsNavigation.open(
              originLat: pos.latitude,
              originLng: pos.longitude,
              destLat: ride.dropLat,
              destLng: ride.dropLng);
        }
      } else {
        _showSnack(response.data['message'] ?? "Invalid OTP", Colors.red);
      }
    } catch (e) {
      debugPrint("OTP Error: $e");
      _showSnack("Failed to verify OTP", Colors.red);
    }
  }

  Future<void> updateRideStatus(int rideId, String status) async {
    try {
      await Dio().put(
        "$BASE_URL/rides/rides/$rideId/status",
        data: {"status": status},
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );
      await _updateLocalRideStatus(rideId, status);
    } catch (e) {
      _showSnack("Failed to update status", Colors.red);
    }
  }

  Future<void> _updateLocalRideStatus(int rideId, String status) async {
    setState(() {
      final index = activeRequests.indexWhere((r) => r.id == rideId);
      if (index != -1) {
        activeRequests[index] = activeRequests[index].copyWith(status: status);
      }
    });

    FFAppState().activeRideStatus = status;
    if (status == 'completed') {
      _removeRideById(rideId); // Or move to history
    }
  }

  Future<void> completeRide(int rideId) async {
    // 1. Mark backend as completed
    try {
      await Dio().post(
        "$BASE_URL/drivers/update-ride-status",
        data: {"ride_id": rideId, "status": "completed"},
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );

      setState(() {
        paymentPendingRides.remove(rideId);
        completedRides.add(rideId);
      });

      _showSnack("Ride Completed Successfully!", Colors.green);

      // Auto remove from screen after delay
      Future.delayed(const Duration(seconds: 5), () {
        _removeRideById(rideId);
      });
    } catch (e) {
      _showSnack("Error completing ride", Colors.red);
    }
  }

  Future<void> _fetchRideFromBackend(int rideId) async {
    try {
      final response = await Dio().get(
        "$BASE_URL/rides/$rideId",
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );

      final ride = RideRequest.fromJson(response.data['data']);

      // Force local status sync
      if (FFAppState().activeRideStatus.isNotEmpty) {
        // ride = ride.copyWith(status: FFAppState().activeRideStatus);
      }

      setState(() {
        activeRequests.removeWhere((r) => r.id == rideId);
        activeRequests.add(ride);
      });
    } catch (e) {
      debugPrint("Fetch Ride Error: $e");
    }
  }

  void _removeRideById(int id) {
    if (!mounted) return;
    setState(() {
      activeRequests.removeWhere((r) => r.id == id);
      timers.remove(id);
      seenRideIds.remove(id);
    });
    _updateAlertState();
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    if (activeRequests.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final constrainedHeight = (screenHeight * 0.45).clamp(340.0, 420.0);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.85), Colors.transparent],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: constrainedHeight,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.98),
                itemCount: activeRequests.length,
                itemBuilder: (context, index) {
                  return _buildUberCard(activeRequests[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUberCard(RideRequest ride) {
    final status = (ride.status ?? '').toLowerCase();
    final remaining = timers[ride.id] ?? 0;

    // Status Flags
    final isSearching = status == 'searching';
    final isAccepted = status == 'accepted';
    final isArrived = status == 'arrived';
    final isStarted = status == 'started';
    final isOtpVerified = status == 'otp_verified' || status == 'otpverified';
    final isCompleted = completedRides.contains(ride.id);

    // Color Logic
    Color headerColor;
    String headerText;

    if (isStarted) {
      headerColor = Colors.green.shade700;
      headerText = "ON TRIP";
    } else if (isArrived) {
      headerColor = Colors.blue.shade700;
      headerText = "DRIVER ARRIVED";
    } else if (isAccepted) {
      headerColor = primaryColor;
      headerText = "PICKUP PASSENGER";
    } else {
      headerColor = remaining < 10 ? Colors.redAccent : primaryColor;
      headerText = "NEW REQUEST";
    }

    return Card(
      elevation: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: headerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(headerText,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.white)),
                if (isSearching)
                  Text("${remaining}s",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Colors.white)),
              ],
            ),
          ),

          // BODY
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // STATS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("EARNINGS",
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900)),
                          Text(
                              "₹${ride.estimatedFare?.toStringAsFixed(0) ?? '--'}",
                              style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green.shade900)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("DISTANCE",
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900)),
                          Text("${ride.distance ?? '--'} km",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // LOCATIONS
                  _buildLocationRow(Icons.radio_button_checked, Colors.green,
                      ride.pickupAddress, "PICKUP"),
                  const SizedBox(height: 10),
                  _buildLocationRow(Icons.location_on, Colors.redAccent,
                      ride.dropAddress, "DROP OFF"),

                  const SizedBox(height: 24),

                  // ACTIONS
                  if (isSearching)
                    _buildAcceptUI(ride)
                  else if (isAccepted)
                    _buildArrivedUI(ride)
                  else if (isArrived)
                    _buildStartTripUI(ride)
                  else if (isStarted || isOtpVerified)
                    _buildCompleteTripUI(ride)
                  else if (isCompleted)
                    _buildRideCompletedUI()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(
      IconData icon, Color color, String address, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w900)),
              Text(address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  // --- ACTION WIDGETS ---

  Widget _buildAcceptUI(RideRequest ride) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _removeRideById(ride.id),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("DECLINE",
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => acceptRide(ride.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("ACCEPT",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  Widget _buildArrivedUI(RideRequest ride) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final pos = await Geolocator.getCurrentPosition();
            await GoogleMapsNavigation.open(
                originLat: pos.latitude,
                originLng: pos.longitude,
                destLat: ride.pickupLat,
                destLng: ride.pickupLng);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("NAVIGATE TO PICKUP",
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        FutureBuilder<bool>(
          future: _isDriverNearPickup(ride.pickupLat, ride.pickupLng),
          builder: (context, snapshot) {
            final isNear = snapshot.data ?? false;
            return ElevatedButton(
              onPressed: isNear
                  ? () => updateRideStatus(ride.id, 'arrived')
                  : () => _showSnack(
                      "Move closer to pickup point (within 200m)",
                      Colors.orange),
              style: ElevatedButton.styleFrom(
                backgroundColor: isNear ? primaryColor : Colors.grey.shade400,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text("I HAVE ARRIVED",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStartTripUI(RideRequest ride) {
    return Column(
      children: [
        const Text("Verify Passenger OTP to Start",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _showOtpDialog(ride.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("VERIFY OTP & START",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      ],
    );
  }

  Widget _buildCompleteTripUI(RideRequest ride) {
    final bool paymentPending = paymentPendingRides.contains(ride.id);

    return Column(
      children: [
        // ON TRIP INDICATOR
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: const [
            Icon(Icons.directions_car, color: Colors.green),
            SizedBox(width: 10),
            Text("ON TRIP - NAVIGATING TO DROP",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14))
          ]),
        ),

        ElevatedButton(
          onPressed: () async {
            final pos = await Geolocator.getCurrentPosition();
            await GoogleMapsNavigation.open(
                originLat: pos.latitude,
                originLng: pos.longitude,
                destLat: ride.dropLat,
                destLng: ride.dropLng);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14))),
          child: const Text("NAVIGATE TO DROP",
              style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),

        if (!paymentPending)
          ElevatedButton(
            onPressed: () => setState(() => paymentPendingRides.add(ride.id)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("COMPLETE RIDE",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          ),

        if (paymentPending) _buildPaymentUI(ride),
      ],
    );
  }

  Widget _buildPaymentUI(RideRequest ride) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12)),
          child: Row(children: const [
            Icon(Icons.payments, color: Colors.orange),
            SizedBox(width: 10),
            Text("SELECT PAYMENT METHOD",
                style: TextStyle(fontWeight: FontWeight.w900))
          ]),
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() {
                  selectedPaymentMethod = 'cash';
                  cashCollected = false;
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPaymentMethod == 'cash'
                      ? Colors.green
                      : Colors.grey.shade300,
                  foregroundColor: Colors.black,
                ),
                child: const Text("CASH"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    setState(() => selectedPaymentMethod = 'razorpay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPaymentMethod == 'razorpay'
                      ? Colors.blue
                      : Colors.grey.shade300,
                  foregroundColor: selectedPaymentMethod == 'razorpay'
                      ? Colors.white
                      : Colors.black,
                ),
                child: const Text("ONLINE"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedPaymentMethod == 'cash' && !cashCollected)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const Text("COLLECT CASH",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("₹${ride.estimatedFare?.toStringAsFixed(0)}",
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => cashCollected = true);
                    await completeRide(ride.id);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48)),
                  child: const Text("CASH COLLECTED & FINISH"),
                )
              ],
            ),
          ),
        if (selectedPaymentMethod == 'razorpay')
          ElevatedButton(
            onPressed: () async =>
                await completeRide(ride.id), // Simplified for now
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54)),
            child: const Text("CONFIRM ONLINE PAYMENT"),
          ),
      ],
    );
  }

  Widget _buildRideCompletedUI() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade300, width: 2)),
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 48, color: Colors.green.shade700),
          const SizedBox(height: 12),
          Text("Ride Completed!",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.green.shade900)),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Future<bool> _isDriverNearPickup(double lat, double lng) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final dist =
          Geolocator.distanceBetween(pos.latitude, pos.longitude, lat, lng);
      // Rapido/Uber usually allow 200m-500m radius
      return dist < 250;
    } catch (e) {
      return false;
    }
  }

  void _showOtpDialog(int rideId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Enter OTP",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(hintText: "----", counterText: ""),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 4)
                verifyOtp(rideId, controller.text);
            },
            child: const Text("VERIFY"),
          )
        ],
      ),
    );
  }
}
