import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart';
import 'package:ugo_driver/home/ride_request_model.dart';
import '../models/ride_status.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

// Import your components
import '../components/active_ride_card.dart';
import '../components/new_request_card.dart';
import '../components/start_ride_card.dart';
import '../components/otp_screen.dart';
import '../components/complete_ride_overlay.dart';
import '../components/review_screen.dart';

import '/flutter_flow/flutter_flow_util.dart';

class RideRequestOverlay extends StatefulWidget {
  final LatLng? driverLocation;
  // ✅ ADDED: Callback to notify HomeWidget when ride is fully finished
  final VoidCallback? onRideComplete;

  const RideRequestOverlay({
    Key? key,
    this.driverLocation,
    this.onRideComplete,
  }) : super(key: key);

  @override
  RideRequestOverlayState createState() => RideRequestOverlayState();
}

class RideRequestOverlayState extends State<RideRequestOverlay>
    with WidgetsBindingObserver {

  final List<RideRequest> _activeRequests = [];
  final Map<int, int> _timers = {};
  final Map<int, int> _waitTimers = {};
  final Set<int> _showOtpOverlay = {};
  final Set<int> _paymentPendingRides = {};
  final Map<int, List<TextEditingController>> _otpControllers = {};

  late AudioPlayer _audioPlayer;
  bool _isAlerting = false;
  Timer? _tickTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _startTickTimer();

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

  void handleNewRide(Map<String, dynamic> rawData) {
    try {
      final updatedRide = RideRequest.fromJson(rawData);
      if (!mounted) return;

      final RideStatus status = updatedRide.status;

      // Remove if cancelled or completed by another driver
      if (status == RideStatus.cancelled || status == RideStatus.unknown) {
        // NOTE: 'completed_by_other' isn't represented in enum; treat as unknown.
        removeRideById(updatedRide.id);
        return;
      }

      final index = _activeRequests.indexWhere((r) => r.id == updatedRide.id);

      if (index != -1) {
        setState(() {
          _activeRequests[index] = updatedRide;
          if (status == RideStatus.arrived && !_waitTimers.containsKey(updatedRide.id)) {
            _waitTimers[updatedRide.id] = 0;
          }
        });
      } else {
        setState(() {
          final validStatuses = [
            RideStatus.searching,
            RideStatus.accepted,
            RideStatus.arrived,
            RideStatus.started,
            RideStatus.onTrip,
          ];
          if (validStatuses.contains(status)) {
            _activeRequests.add(updatedRide);
            if (status == RideStatus.searching) {
              _timers[updatedRide.id] = 30;
              _startAlert();
            }
            if (status != RideStatus.searching) {
              FFAppState().activeRideId = updatedRide.id;
            }
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

  Future<void> _fetchRideFromBackend(int rideId) async {
    try {
      final response = await Dio().get(
        "https://ugo-api.icacorp.org/api/rides/$rideId",
        options: Options(
            headers: {"Authorization": "Bearer ${FFAppState().accessToken}"}),
      );
      if (response.data['data'] != null) handleNewRide(response.data['data']);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        FFAppState().activeRideId = 0;
      }
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
      // update both server and local state
      _updateRideStatus(rideId, RideStatus.accepted);
      FFAppState().activeRideId = rideId;
    } catch (e) {
      print("Accept Error: $e");
    }
  }

  Future<void> _updateRideStatus(int rideId, RideStatus status) async {
    try {
      final payload = status.value.toLowerCase();
      await Dio().put("https://ugo-api.icacorp.org/api/rides/$rideId",
          data: {"ride_status": payload, "driver_id": FFAppState().driverid},
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
          _updateLocalRideStatus(rideId, 'started' as RideStatus);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
        for (var c in controllers) c.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verification Failed")));
    }
  }

  void _updateLocalRideStatus(int rideId, RideStatus status) {
    setState(() {
      final idx = _activeRequests.indexWhere((r) => r.id == rideId);
      if (idx != -1) {
        _activeRequests[idx] = _activeRequests[idx].copyWith(status: status);
        if (status == RideStatus.arrived) _waitTimers[rideId] = 0;
        if (status == RideStatus.completed) _paymentPendingRides.add(rideId);
      }
    });
  }

  String _formatWaitTime(int rideId) {
    final s = _waitTimers[rideId] ?? 0;
    return "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";
  }

  Future<void> _completeRide({required int rideId, required int userId}) async {
    try {
      await CompleteRideCall.call(
        rideId: rideId,
        driverId: FFAppState().driverid,
        userId: userId,
        token: FFAppState().accessToken,
      );
    } catch (e) {
      print("Complete Ride Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guard against a race where the list becomes empty during build.
    if (_activeRequests.isEmpty) return const SizedBox.shrink();

    // capture into a local variable immediately after the emptiness check.
    final RideRequest ride = _activeRequests.last;
    final RideStatus status = ride.status;

    if (_showOtpOverlay.contains(ride.id)) {
      if (!_otpControllers.containsKey(ride.id)) {
        _otpControllers[ride.id] = List.generate(4, (_) => TextEditingController());
      }
      return Positioned.fill(
          child: OtpVerificationSheet(
            otpControllers: _otpControllers[ride.id]!,
            onVerify: () => _verifyOtp(ride.id),
          ));
    }

    if (_paymentPendingRides.contains(ride.id) || status == RideStatus.completed) {
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
              // ✅ NOTIFY PARENT TO REFRESH UI
              if (widget.onRideComplete != null) {
                widget.onRideComplete!();
              }
            },
            onClose: () {},
          ),
        ),
      );
    }

    switch (status) {
      case RideStatus.searching:
        return Positioned(
          bottom: 0, left: 0, right: 0,
          child: NewRequestCard(
            ride: ride,
            remainingTime: _timers[ride.id] ?? 0,
            onAccept: () => _acceptRide(ride.id),
            onDecline: () => removeRideById(ride.id),
            driverLocation: widget.driverLocation,
          ),
        );
      case RideStatus.accepted:
        return Positioned.fill(
          child: RidePickupOverlay(
            ride: ride,
            onSwipe: () => _updateRideStatus(ride.id, RideStatus.arrived),
            formattedWaitTime: '',
          ),
        );
      case RideStatus.arrived:
        return Positioned.fill(
          child: RideBottomOverlay(
            ride: ride,
            formattedWaitTime: _formatWaitTime(ride.id),
            onSwipe: () => setState(() => _showOtpOverlay.add(ride.id)),
            onCancel: () {},
            onCall: () {},
          ),
        );
      case RideStatus.started:
      case RideStatus.onTrip:
        return Positioned.fill(
          child: RideCompleteOverlay(
            ride: ride,
            onSwipe: () => _completeRide(rideId: ride.id, userId: ride.userId),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}