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

class RideRequestOverlay extends StatefulWidget {
  const RideRequestOverlay({Key? key}) : super(key: key);

  @override
  RideRequestOverlayState createState() => RideRequestOverlayState();
}

class RideRequestOverlayState extends State<RideRequestOverlay> {
  // YOUR PRIMARY COLOR
  static const Color primaryColor = Color(0xFFFF7B10);

  final List<RideRequest> _activeRequests = [];
  final Map<int, int> _timers = {};
  final Set<int> _seenRideIds = {};
  late AudioPlayer _audioPlayer;
  bool _isAlerting = false;
  Timer? _tickTimer;
  final Set<int> _paymentPendingRides = {};
  String? _selectedPaymentMethod; // "cash" | "razorpay"
  final Set<int> _completedRides = {};
  bool _showCashAmount = false;




  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
     final rideId = FFAppState().activeRideId;
  final status = FFAppState().activeRideStatus;
  if (rideId != 0) {
    _fetchRideFromBackend(rideId);
  }
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _configureAudio();
    _initializeNotifications();
    _startTickTimer();
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

    // 🔥 FORCE LOCAL STATUS
    if (FFAppState().activeRideStatus.isNotEmpty) {
      ride = ride.copyWith(
        status: FFAppState().activeRideStatus,
      );
    }

    setState(() {
      _activeRequests.clear();
      _activeRequests.add(ride);
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
        )
      ));
    } catch (e) {
      debugPrint("🔊 Audio Config Error: $e");
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initializationSettings);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _audioPlayer.dispose();
    _stopAlert();
    super.dispose();
  }

  void _updateAlertState() {
    bool hasSearchingRequests = _activeRequests.any((r) => r.status == 'SEARCHING');
    if (hasSearchingRequests) {
      _startAlert();
    } else {
      _stopAlert();
    }
  }

  void _startTickTimer() {
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

        for (var id in idsToRemove) {
          _activeRequests.removeWhere((r) => r.id == id);
          _timers.remove(id);
          _seenRideIds.remove(id);
          changed = true;
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
      debugPrint("🔊 UGO Alert Started - Color: $primaryColor");
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
    debugPrint("🔊 Alert Stopped");
  }

  Future<void> _showNotification(RideRequest ride) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ride_requests', 'UGO Ride Requests',
      channelDescription: 'New ride requests',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      color: primaryColor,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      ride.id,
      'New UGO Ride Request!',
      'Fare: ₹${ride.estimatedFare?.toStringAsFixed(0)} • Distance: ${ride.distance}km',
      details,
    );
  }

 void handleNewRide(Map<String, dynamic> rawData) {
    print("🔎 DEBUG: processing ride data: $rawData");

    try {
      final updatedRide = RideRequest.fromJson(rawData);

      if (!mounted) return;

      // 🚫 HANDLE CANCELLATION FIRST
      if (updatedRide.status.toLowerCase() == "cancelled") {
        print("🛑 Ride ${updatedRide.id} cancelled");

        removeRideById(updatedRide.id);
        _showCancelledSnackBar(updatedRide.id);
        return;
      }
      // 🚫 IGNORE IF ACCEPTED BY ANOTHER DRIVER
      if(updatedRide.status.toLowerCase()=='accepted'&&updatedRide.driverId != FFAppState().driverid){
        print("🛑 Ride ${updatedRide.id} accepted by another driver");

        removeRideById(updatedRide.id);
        return;

      }
      final index = _activeRequests.indexWhere((r) => r.id == updatedRide.id);

      if (index != -1) {
        // 🔄 UPDATE EXISTING RIDE
        setState(() {
          _activeRequests[index] = updatedRide;
        });

        print("🔁 Ride ${updatedRide.id} updated → ${updatedRide.status}");
      } else {
        // ➕ ADD NEW RIDE
        setState(() {
          _activeRequests.add(updatedRide);
          _seenRideIds.add(updatedRide.id);
        });

        print("➕ Ride ${updatedRide.id} added → ${updatedRide.status}");
      }
    } catch (e) {
      print("❌ Error parsing ride request: $e");
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
      _seenRideIds.remove(idToRemove);
      _updateAlertState();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeRequests.isEmpty) return const SizedBox.shrink();

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
                itemCount: _activeRequests.length,
                itemBuilder: (context, index) {
                  return _buildUberCard(_activeRequests[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUberCard(RideRequest ride) {
    final String status = ride.status ?? '';
    final int remaining = _timers[ride.id] ?? 0;
    final bool isSearching = status == 'SEARCHING';
    final bool isAccepted = status == 'accepted';
    final bool isArrived = status == 'arrived';
    final bool isStarted = status == 'started';
    final bool isOtpVerified = status == 'otp_verified';
    final bool isCompleted = _completedRides.contains(ride.id);



    return Card(
      elevation: 20,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isStarted 
                  ? Colors.green.shade700 
                  : isArrived 
                  ? Colors.blue.shade700 
                  : isAccepted 
                  ? primaryColor 
                  : remaining > 10 
                  ? primaryColor 
                  : Colors.redAccent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isStarted 
                      ? "ON TRIP" 
                      : isArrived 
                      ? "DRIVER ARRIVED" 
                      : isAccepted 
                      ? "PICKUP PASSENGER" 
                      : "NEW REQUEST",
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white),
                ),
                if (isSearching)
                  Text("${remaining}s", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white)),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ride Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("EARNINGS", style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w900)),
                          Text("₹${ride.estimatedFare?.toStringAsFixed(0) ?? '--'}", 
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.green.shade900)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("DISTANCE", style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w900)),
                          Text("${ride.distance ?? '--'} km", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildLocationRow(Icons.radio_button_checked, Colors.green, ride.pickupAddress, "PICKUP"),
                  const SizedBox(height: 10),
                  _buildLocationRow(Icons.location_on, Colors.redAccent, ride.dropAddress, "DROP OFF"),
                  const SizedBox(height: 24),

                  // Uber Flow Actions
                  if (isSearching)
                    _buildAcceptUI(ride)
                  else if (isAccepted)
                    _buildArrivedUI(ride)
                  else if (isArrived)
                    _buildStartTripUI(ride)
                    else if (isOtpVerified)
                    _buildStartRideButton(ride)
                  else if (isCompleted)
                    _buildRideCompletedUI()
                  else if (isStarted)
                    _buildCompleteTripUI(ride),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStartRideButton(RideRequest ride) {
  return Column(
    children: [
      // ✅ Success indicator
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "✓ OTP Verified Successfully",
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
      
      // ✅ START RIDE Button
      ElevatedButton(
        onPressed: () async {
          print("🚀 START RIDE CLICKED");

          // ✅ Update backend to 'started'
          await _updateRideStatus(ride.id, 'started');
         FFAppState().activeRideStatus = 'started';

          // ✅ Update local UI
          if (mounted) {
            setState(() {
              final index = _activeRequests.indexWhere((r) => r.id == ride.id);
              if (index != -1) {
                _activeRequests[index] =
                    _activeRequests[index].copyWith(status: 'started');
              }
            });

            // ✅ Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("🚗 Trip Started Successfully!"),
                backgroundColor: Colors.green.shade600,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          
          print("✅ TRIP STATUS UPDATED TO STARTED");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          "START RIDE",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
    ],
  );
}

  Widget _buildAcceptUI(RideRequest ride) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => removeRideById(ride.id),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("DECLINE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () async {
              _stopAlert();
              await _acceptRide(ride.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("ACCEPT", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
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
          print("🚕 ARRIVED button clicked for ride ${ride.id}");
          final position = await Geolocator.getCurrentPosition();
          await GoogleMapsNavigation.open(
            originLat: position.latitude,
            originLng: position.longitude,
            destLat: ride.pickupLat ?? 0,
            destLng: ride.pickupLng ?? 0,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text("NAVIGATE TO PICKUP", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 12),
      FutureBuilder<bool>(
        future: _isDriverNearPickup(ride.pickupLat ?? 0, ride.pickupLng ?? 0),
        builder: (context, snapshot) {
          final isNear = snapshot.data ?? false;

          return ElevatedButton(
            onPressed: isNear
                ? () {
                    _updateRideStatus(ride.id, 'arrived');
                    FFAppState().activeRideStatus = 'arrived';
                    print("📡 BACKEND STATUS UPDATED TO ARRIVED");
                    _showOtpDialog(ride.id);
                  }
                : null, // DISABLED if driver not near
            style: ElevatedButton.styleFrom(
              backgroundColor: isNear ? primaryColor : Colors.grey.shade400,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text("I HAVE ARRIVED", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          );
        },
      ),
    ],
  );
}

  Widget _buildStartTripUI(RideRequest ride) {
    return Column(
      children: [
        const Text("Verify Passenger OTP to Start", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _showOtpDialog(ride.id),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("VERIFY OTP & START", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      ],
    );
  }

  // Widget _buildCompleteTripUI(RideRequest ride) {
  //   return Column(
  //     children: [
  //       ElevatedButton(
  //         onPressed: () async {
  //            final position = await Geolocator.getCurrentPosition();
  //            await GoogleMapsNavigation.open(
  //              originLat: position.latitude, originLng: position.longitude,
  //              destLat: ride.dropLat ?? 0, destLng: ride.dropLng ?? 0,
  //            );
  //         },
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.black,
  //           foregroundColor: Colors.white,
  //           minimumSize: const Size(double.infinity, 54),
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //         ),
  //         child: const Text("NAVIGATE TO DROP", style: TextStyle(fontWeight: FontWeight.w800)),
  //       ),
  //       const SizedBox(height: 12),
  //       ElevatedButton(
  //         onPressed: () => _updateRideStatus(ride.id, 'completed'),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.redAccent,
  //           foregroundColor: Colors.white,
  //           minimumSize: const Size(double.infinity, 54),
  //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  //         ),
  //         child: const Text("COMPLETE TRIP", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildCompleteTripUI(RideRequest ride) {
    final bool paymentPending = _paymentPendingRides.contains(ride.id);
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.directions_car, color: Colors.green),
            SizedBox(width: 10),
            Text(
              "ON TRIP",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      ElevatedButton(
  onPressed: ()  {
    // 1️⃣ Optional: payment confirmation first
    // 2️⃣ Then complete ride
     setState(() {
      _paymentPendingRides.add(ride.id);
      
    });
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 54),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  child: const Text(
    "COMPLETE RIDE",
    style: TextStyle(fontWeight: FontWeight.w900),
  ),
),
 if (paymentPending)
        _buildPaymentUI(ride),
    ],
  );
}
Widget _buildPaymentUI(RideRequest ride) {
  return Column(
    children: [
      // PAYMENT HEADER
      Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: const [
            Icon(Icons.payments, color: Colors.orange),
            SizedBox(width: 10),
            Text(
              "SELECT PAYMENT METHOD",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),

      // 💵 CASH BUTTON
      ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPaymentMethod = "cash";
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedPaymentMethod == "cash"
              ? Colors.green
              : Colors.grey.shade300,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text("CASH"),
      ),

      const SizedBox(height: 10),

      // 💳 RAZORPAY BUTTON
      ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedPaymentMethod = "razorpay";
          });
          _startRazorpayPayment(ride);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedPaymentMethod == "razorpay"
              ? Colors.blue
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: const Text("RAZORPAY"),
      ),

      const SizedBox(height: 16),

      // ✅ CONFIRM BUTTON
      ElevatedButton(
        onPressed: _selectedPaymentMethod == null
            ? null
            : () async {
                await _completeRide(ride.id);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          minimumSize: const Size(double.infinity, 54),
        ),
        child: const Text(
          "CONFIRM & FINISH RIDE",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    ],
  );
}
void _startRazorpayPayment(RideRequest ride) {
  print("💳 Starting Razorpay for ride ${ride.id}");

  // TODO:
  // 1. Create order from backend
  // 2. Open Razorpay SDK
  // 3. On success -> call _completeRide()
  // 4. On failure -> show error
}


Future<void> _completeRide(int rideId) async {
  try {
    await Dio().post(
      "https://ugotaxi.icacorp.org/api/drivers/update-ride-status",
      data: {
        "ride_id": rideId,
        "status": "completed",
      },
      options: Options(
        headers: {
          "Authorization": "Bearer ${FFAppState().accessToken}",
          "Accept": "application/json",
        },
      ),
    );

    // ✅ Mark ride as completed (UI only)
    setState(() {
      _paymentPendingRides.remove(rideId);
      _completedRides.add(rideId);
    });

    _showSnack("💰 Ride completed successfully", color: Colors.green);

    // ⏳ REMOVE AFTER 10 SECONDS
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      setState(() {
        _completedRides.remove(rideId);
        _activeRequests.removeWhere((r) => r.id == rideId);
      });
    });
  } catch (e) {
    debugPrint("❌ Complete Ride Error: $e");
    _showSnack("❌ Failed to complete ride", color: Colors.red);
  }
}



  Future<void> _acceptRide(int rideId) async {
  try {
    // 🔐 SAVE LOCALLY FIRST
    FFAppState().activeRideId = rideId;
    FFAppState().activeRideStatus = 'accepted';

    final url =
        "https://ugotaxi.icacorp.org/api/rides/rides/$rideId/accept";

    await Dio().post(
      url,
      data: {"driver_id": FFAppState().driverid},
      options: Options(
        headers: {"Authorization": "Bearer ${FFAppState().accessToken}"},
      ),
    );

    _showSnack("✅ Ride accepted", color: Colors.green);
  } on DioException catch (e) {
    FFAppState().activeRideId = 0; // rollback
    FFAppState().activeRideStatus = '';

    if (e.response?.statusCode == 409 ||
        e.response?.statusCode == 400) {
      _showSnack("❌ Ride already accepted", color: Colors.red);
      removeRideById(rideId);
    } else {
      _showSnack("❌ Unable to accept ride", color: Colors.red);
    }
  }
}


  Future<void> _updateRideStatus(int rideId, String status) async {
    try {
      final url = "https://ugotaxi.icacorp.org/api/rides/rides/$rideId/status";
      await Dio().put(url, data: {"status": status}, 
        options: Options(headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}));
        if(status == 'completed') removeRideById(rideId);
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
        maxLength: 4,
        decoration: const InputDecoration(
          hintText: "4-digit OTP",
          counterText: "", // Hide character counter
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx), 
          child: const Text("Cancel")
        ),
        ElevatedButton(
          onPressed: () {
            final otp = controller.text.trim();
            
            // Validate OTP
            if (otp.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please enter OTP"),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            if (otp.length != 4) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("OTP must be 4 digits"),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            
            Navigator.pop(ctx);
            _verifyOtp(rideId, otp);
          },
          child: const Text("Verify"),
        ),
      ],
    ),
  );
}


// Future<void> _verifyOtp(int rideId, String otp) async {
//   try {
//     print("🔢 OTP ENTERED: $otp");
//     print("🔍 VERIFYING OTP FOR RIDE $rideId");

//     final url = "https://ugotaxi.icacorp.org/api/rides/verify-otp";

//     final response = await Dio().post(
//       url,
//       data: {
//         "otp": otp,
//         "ride_id": rideId,
//       },
//       options: Options(
//         headers: {
//           "Authorization": "Bearer ${FFAppState().accessToken}",
//         },
//       ),
//     );

//     print("📡 OTP RESPONSE: ${response.data}");

//     if (response.data['success'] == true) {
//       final newStatus = response.data['data']['status']; // started

//       print("✅ OTP VERIFIED → STATUS = $newStatus");

//       // ✅ UPDATE UI USING BACKEND STATUS
//       setState(() {
//         final index =
//             _activeRequests.indexWhere((r) => r.id == rideId);
//         if (index != -1) {
//           _activeRequests[index] =
//               _activeRequests[index].copyWith(status: newStatus);
//         }
//       });
//     }
//   } catch (e) {
//     debugPrint("❌ OTP ERROR: $e");
//   }
// }
Future<void> _verifyOtp(int rideId, String otp) async {
  try {
    print("🔢 OTP ENTERED: $otp");
    print("🔍 VERIFYING OTP FOR RIDE $rideId");

    final url = "https://ugotaxi.icacorp.org/api/rides/verify-otp";

    final response = await Dio().post(
      url,
      data: {
        "otp": otp,
        "ride_id": rideId,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer ${FFAppState().accessToken}",
        },
      ),
    );

    print("📡 OTP RESPONSE: ${response.data}");

    if (response.data['success'] == true) {
      final newStatus = response.data['data']['status']; // started

      print("✅ OTP VERIFIED → STATUS = $newStatus");

      RideRequest? ride;
      

      setState(() {
        final index =
            _activeRequests.indexWhere((r) => r.id == rideId);
        if (index != -1) {
          _activeRequests[index] =
              _activeRequests[index].copyWith(status: newStatus);
          ride = _activeRequests[index];
        }
      });

      // 🚕 UBER BEHAVIOR: AUTO OPEN MAPS
      if (ride != null) {
        print("🗺 AUTO START RIDE → OPEN DROP MAP");

        final position = await Geolocator.getCurrentPosition();
        await GoogleMapsNavigation.open(
          originLat: position.latitude,
          originLng: position.longitude,
          destLat: ride!.dropLat,
          destLng: ride!.dropLng,
        );
      }
    }
  } catch (e) {
    debugPrint("❌ OTP ERROR: $e");
  }
}


  Widget _buildLocationRow(IconData icon, Color color, String address, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 3.0), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.w900)),
              Text(address, maxLines: 2, overflow: TextOverflow.ellipsis, 
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
  Future<bool> _isDriverNearPickup(double pickupLat, double pickupLng, {double thresholdMeters = 50}) async {
  try {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      pickupLat,
      pickupLng,
    );
    print("📍 Distance to pickup: ${distance.toStringAsFixed(2)} meters");
    return distance <= thresholdMeters;
  } catch (e) {
    debugPrint("❌ Error getting location: $e");
    return false;
  }
}
Widget _buildRideCompletedUI() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.green.shade300, width: 2),
    ),
    child: Column(
      children: [
        Icon(Icons.check_circle,
            size: 48, color: Colors.green.shade700),
        const SizedBox(height: 12),
        Text(
          "Ride Completed Successfully",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.green.shade900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Thank you for riding with UGO",
          style: TextStyle(
            fontSize: 13,
            color: Colors.green.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}


}