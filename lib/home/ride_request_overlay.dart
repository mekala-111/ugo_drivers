import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart';
import 'package:ugo_driver/home/ride_request_model.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

// ✅ Import LatLng
import '/flutter_flow/lat_lng.dart';

// Import the refactored components
import '../components/active_ride_card.dart';
import '../components/new_request_card.dart';
import '../components/start_ride_card.dart'; // Contains RideBottomOverlay
import '../components/otp_screen.dart';
import '../components/complete_ride_overlay.dart';
import '../components/review_screen.dart';

import '/flutter_flow/flutter_flow_util.dart';

class RideRequestOverlay extends StatefulWidget {
  // ✅ 1. Add driverLocation variable
  final LatLng? driverLocation;

  const RideRequestOverlay({
    Key? key,
    this.driverLocation, // ✅ 2. Initialize in constructor
  }) : super(key: key);

  @override
  RideRequestOverlayState createState() => RideRequestOverlayState();
}

class RideRequestOverlayState extends State<RideRequestOverlay>
    with WidgetsBindingObserver {
  // --- State ---
  final List<RideRequest> _activeRequests = [];
  final Map<int, int> _timers = {};
  final Map<int, int> _waitTimers = {};
  final Set<int> _showOtpOverlay = {};
  final Set<int> _paymentPendingRides = {};
  final Map<int, List<TextEditingController>> _otpControllers = {};

  late AudioPlayer _audioPlayer;
  bool _isAlerting = false;
  Timer? _tickTimer;

  bool get hasActiveRides => _activeRequests.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _startTickTimer();

    // Load active ride if exists
    if (FFAppState().activeRideId != 0) {
      _fetchRideFromBackend(FFAppState().activeRideId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _audioPlayer.dispose();
    for (var list in _otpControllers.values) {
      for (var c in list) c.dispose();
    }
    super.dispose();
  }

  // --- Data Handling & State Management ---
  void handleNewRide(Map<String, dynamic> rawData) {
    try {
      final updatedRide = RideRequest.fromJson(rawData);
      if (!mounted) return;

      if (updatedRide.status.toLowerCase() == "cancelled") {
        removeRideById(updatedRide.id);
        return;
      }

      final index = _activeRequests.indexWhere((r) => r.id == updatedRide.id);

      // ✅ LOGIC: If another driver accepted it, status won't be SEARCHING
      // So we remove it from the list to make it "disappear" like Rapido
      if (updatedRide.status.toLowerCase() != 'searching' &&
          updatedRide.status.toLowerCase() !=
              'accepted' && // Keep if WE accepted
          updatedRide.status.toLowerCase() != 'arrived' &&
          updatedRide.status.toLowerCase() != 'started') {
        // If it's just a general update and not one of our active states, remove it.
        if (index != -1 && _activeRequests[index].status == 'SEARCHING') {
          removeRideById(updatedRide.id);
          return;
        }
      }

      if (index != -1) {
        setState(() {
          _activeRequests[index] = updatedRide;
          if (updatedRide.status.toLowerCase() == 'arrived' &&
              !_waitTimers.containsKey(updatedRide.id)) {
            _waitTimers[updatedRide.id] = 0;
          }
        });
      } else {
        setState(() {
          // Only add if it is actually searching
          if (updatedRide.status.toLowerCase() == 'searching') {
            _activeRequests.add(updatedRide);
            _timers[updatedRide.id] = 30;
            _startAlert();
          }
        });
      }
    } catch (e) {
      print("❌ Error parsing ride: $e");
    }
  }

  void removeRideById(int id) {
    setState(() {
      _activeRequests.removeWhere((r) => r.id == id);
      _timers.remove(id);
      _waitTimers.remove(id);
      _showOtpOverlay.remove(id);
      if (_otpControllers.containsKey(id)) {
        for (var c in _otpControllers[id]!) c.dispose();
        _otpControllers.remove(id);
      }
    });
    if (_activeRequests.isEmpty) _stopAlert();
  }

  void _startTickTimer() {
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timers.forEach((id, val) {
          if (val > 0) _timers[id] = val - 1;
        });
        _waitTimers.forEach((id, val) {
          _waitTimers[id] = val + 1;
        });
      });
    });
  }

  // --- Audio ---
  void _startAlert() async {
    if (_isAlerting) return;
    _isAlerting = true;
    try {
      await _audioPlayer.play(AssetSource('audios/ride_request.mp3'));
      Vibration.vibrate(pattern: [0, 500, 200, 500], repeat: 0);
    } catch (_) {}
  }

  void _stopAlert() {
    if (!_isAlerting) return;
    _isAlerting = false;
    _audioPlayer.stop();
    Vibration.cancel();
  }

  // --- API ---
  Future<void> _fetchRideFromBackend(int rideId) async {
    try {
      final response = await Dio().get(
        "https://ugo-api.icacorp.org/api/rides/$rideId",
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );
      if (response.data['data'] != null) handleNewRide(response.data['data']);
    } catch (e) {
      print("Fetch Error: $e");
    }
  }

  Future<void> _acceptRide(int rideId) async {
    _stopAlert();
    try {
      await Dio().post(
          "https://ugo-api.icacorp.org/api/rides/rides/$rideId/accept",
          data: {"driver_id": FFAppState().driverid},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));
      _updateLocalRideStatus(rideId, 'accepted');
      FFAppState().activeRideId = rideId;
    } catch (e) {
      print("Accept Error: $e");
    }
  }

  Future<void> _updateRideStatus(int rideId, String status) async {
    try {
      await Dio().put("https://ugo-api.icacorp.org/api/rides/$rideId",
          data: {"ride_status": status, "driver_id": FFAppState().driverid},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));
      _updateLocalRideStatus(rideId, status);
    } catch (e) {
      print("Status Update Error: $e");
    }
  }

  Future<void> _verifyOtp(int rideId) async {
    final controllers = _otpControllers[rideId];
    if (controllers == null) return;

    final otp = controllers.map((c) => c.text).join();
    if (otp.length != 4) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter complete OTP")));
      return;
    }

    try {
      final res = await Dio().post(
          "https://ugo-api.icacorp.org/api/rides/verify-otp",
          data: {"otp": otp, "ride_id": rideId},
          options: Options(headers: {
            "Authorization": "Bearer ${FFAppState().accessToken}"
          }));

      if (res.data['success'] == true) {
        setState(() {
          _showOtpOverlay.remove(rideId);
          _updateLocalRideStatus(rideId, 'started');
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid OTP")));
        for (var c in controllers) c.clear();
      }
    } catch (e) {
      print("OTP Verify Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Verification Failed")));
    }
  }

  void _updateLocalRideStatus(int rideId, String status) {
    setState(() {
      final idx = _activeRequests.indexWhere((r) => r.id == rideId);
      if (idx != -1) {
        _activeRequests[idx] = _activeRequests[idx].copyWith(status: status);
        if (status == 'arrived') _waitTimers[rideId] = 0;
        if (status == 'completed') _paymentPendingRides.add(rideId);
      }
    });
  }

  String _formatWaitTime(int rideId) {
    final s = _waitTimers[rideId] ?? 0;
    return "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";
  }

  Future<void> _completeRide({
    required int rideId,
    required int userId,
  }) async {
    try {
      await CompleteRideCall.call(
        rideId: rideId,
        driverId: FFAppState().driverid,
        userId: userId,
        token: FFAppState().accessToken,
      );
      //
    } catch (e) {
      print("Complete Ride Error: $e");
    }
  }

  // --- UI Building ---
  @override
  Widget build(BuildContext context) {
    if (_activeRequests.isEmpty) return const SizedBox.shrink();

    // Get the most relevant ride
    final ride = _activeRequests.first;
    final status = ride.status.toLowerCase();

    // OTP overlay has priority if it's meant to be shown
    if (_showOtpOverlay.contains(ride.id)) {
      if (!_otpControllers.containsKey(ride.id)) {
        _otpControllers[ride.id] =
            List.generate(4, (_) => TextEditingController());
      }
      return Positioned.fill(
          child: OtpVerificationSheet(
        otpControllers: _otpControllers[ride.id]!,
        onVerify: () => _verifyOtp(ride.id),
      ));
    }

    // After ride is 'completed', show the review screen
    if (_paymentPendingRides.contains(ride.id) || status == 'completed') {
      return Positioned.fill(
        child: Container(
          color: Colors.white,
          child: ReviewScreen(
            ride: ride,
            onSubmit: () {
              setState(() {
                _paymentPendingRides.remove(ride.id);
                _activeRequests.removeWhere((r) => r.id == ride.id);
                FFAppState().activeRideId = 0;
              });
            },
            onClose: () {},
          ),
        ),
      );
    }

    // Main ride flow logic
    switch (status) {
      case 'searching':
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: NewRequestCard(
            ride: ride,
            remainingTime: _timers[ride.id] ?? 0,
            onAccept: () => _acceptRide(ride.id),
            onDecline: () => removeRideById(ride.id),
            driverLocation: widget.driverLocation, // ✅ 3. Pass Location to Card
          ),
        );
      case 'accepted':
        return Positioned.fill(
          child: RidePickupOverlay(
            ride: ride,
            onSwipe: () => _updateRideStatus(ride.id, 'arrived'),
            formattedWaitTime: '',
          ),
        );
      case 'arrived':
        return Positioned.fill(
          child: RideBottomOverlay(
            ride: ride,
            formattedWaitTime: _formatWaitTime(ride.id),
            onSwipe: () => setState(() => _showOtpOverlay.add(ride.id)),
            onCancel: () {},
            onCall: () {},
          ),
        );
      case 'started':
        return Positioned.fill(
          child: RideCompleteOverlay(
            ride: ride,
            onSwipe: () => _completeRide(
              rideId: ride.id,
              userId: ride.userId,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
