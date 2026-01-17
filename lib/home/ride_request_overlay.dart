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

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _configureAudio();
    _initializeNotifications();
    _startTickTimer();
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
        ),
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
    try {
      final updatedRide = RideRequest.fromJson(rawData);
      if (!mounted) return;

      setState(() {
        final index = _activeRequests.indexWhere((r) => r.id == updatedRide.id);

        if (index != -1) {
          // If ride is no longer available to accept, remove it
          if (updatedRide.status == 'cancelled' || updatedRide.status == 'expired' || (updatedRide.status == 'accepted' && updatedRide.driverId != FFAppState().driverid)) {
            _activeRequests.removeAt(index);
            _timers.remove(updatedRide.id);
            _seenRideIds.remove(updatedRide.id);
          } else {
            // Update the ride in the list
            _activeRequests[index] = updatedRide;
          }
        } else if (updatedRide.status == 'SEARCHING') {
          _activeRequests.add(updatedRide);
          _seenRideIds.add(updatedRide.id);
          _timers[updatedRide.id] = 30;
          _showNotification(updatedRide);
        }

        _updateAlertState();
      });
    } catch (e) {
      debugPrint("❌ Error parsing ride: $e");
    }
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
             final position = await Geolocator.getCurrentPosition();
             await GoogleMapsNavigation.open(
               originLat: position.latitude, originLng: position.longitude,
               destLat: ride.pickupLat ?? 0, destLng: ride.pickupLng ?? 0,
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
        ElevatedButton(
          onPressed: () => _updateRideStatus(ride.id, 'arrived'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("I HAVE ARRIVED", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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

  Widget _buildCompleteTripUI(RideRequest ride) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
             final position = await Geolocator.getCurrentPosition();
             await GoogleMapsNavigation.open(
               originLat: position.latitude, originLng: position.longitude,
               destLat: ride.dropLat ?? 0, destLng: ride.dropLng ?? 0,
             );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("NAVIGATE TO DROP", style: TextStyle(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _updateRideStatus(ride.id, 'completed'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text("COMPLETE TRIP", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ),
      ],
    );
  }

  Future<void> _acceptRide(int rideId) async {
    try {
      final url = "https://ugotaxi.icacorp.org/api/rides/rides/$rideId/accept";
      await Dio().post(url, data: {"driver_id": FFAppState().driverid}, 
        options: Options(headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}));
    } catch (e) {
      _startAlert();
      debugPrint("Accept Error: $e");
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
          decoration: const InputDecoration(hintText: "4-digit OTP"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _verifyOtp(rideId, controller.text);
            },
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyOtp(int rideId, String otp) async {
    try {
      final url = "https://ugotaxi.icacorp.org/api/rides/rides/$rideId/verify-otp";
      final response = await Dio().post(url, data: {"otp": otp}, 
        options: Options(headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}));
      if(response.statusCode == 200) _updateRideStatus(rideId, 'started');
    } catch (e) {
       debugPrint("OTP Error: $e");
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
}
