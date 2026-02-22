import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/backend/api_requests/api_calls.dart';
import 'package:ugo_driver/services/voice_service.dart';
import 'package:ugo_driver/services/ride_notification_service.dart';
import 'package:ugo_driver/services/floating_bubble_service.dart';
import 'package:ugo_driver/home/ride_request_model.dart';
import '../models/ride_status.dart';
import '../models/payment_mode.dart';
import 'dart:async';

// Import your components
import '../components/active_ride_card.dart';
import '../components/new_request_card.dart';
import '../components/start_ride_card.dart';
import '../components/otp_screen.dart';
import '../components/complete_ride_overlay.dart';
import '../components/review_screen.dart';
import '../components/cancel_ride_sheet.dart';
import '../components/cash_payment_screen.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/config.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';

class RideRequestOverlay extends StatefulWidget {
  final LatLng? driverLocation;
  // ✅ ADDED: Callback to notify HomeWidget when ride is fully finished
  final VoidCallback? onRideComplete;

  const RideRequestOverlay({
    super.key,
    this.driverLocation,
    this.onRideComplete,
  });

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
  final PageController _requestPageController =
      PageController(viewportFraction: 0.94);

  bool _matchesDriverVehicle(RideRequest ride) {
    // Prefer admin vehicle id match when available.
    final driverVehicleId = FFAppState().adminVehicleId;
    if (driverVehicleId > 0 && ride.vehicleTypeId != null) {
      return driverVehicleId == ride.vehicleTypeId;
    }

    // Fallback to string-based vehicle type match.
    final driverType = (FFAppState().selectvehicle.isNotEmpty
            ? FFAppState().selectvehicle
            : FFAppState().vehicleType)
        .toString()
        .trim()
        .toLowerCase();
    final rideType = (ride.vehicleType ?? '').toString().trim().toLowerCase();
    if (driverType.isEmpty || rideType.isEmpty) return true; // don't block if missing
    return driverType == rideType;
  }

  late AudioPlayer _audioPlayer;
  bool _isAlerting = false;
  Timer? _tickTimer;
  Timer? _searchingPollTimer; // Rapido-style: poll to remove when another driver accepts
  bool _isAcceptingRide = false;
  bool _isCompletingRide = false;
  bool _isCancellingRide = false;
  bool _isAppInForeground = true;

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppInForeground = state == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _searchingPollTimer?.cancel();
    _audioPlayer.dispose();
    _requestPageController.dispose();
    for (var list in _otpControllers.values) {
      for (var c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> handleNewRide(Map<String, dynamic> rawData) async {
    try {
      final updatedRide = RideRequest.fromJson(rawData);
      if (!mounted) return;
      bool shouldShowFloatingRide = false;

      final RideStatus status = updatedRide.status;
      final int myDriverId = FFAppState().driverid;
      final int? rideDriverId = updatedRide.driverId;

      // Remove if cancelled, rejected, or completed by another driver
      if (status == RideStatus.cancelled ||
          status == RideStatus.rejected ||
          status == RideStatus.unknown) {
        removeRideById(updatedRide.id);
        return;
      }

      // Rapido-style: Remove if another driver accepted (status changed to accepted/arrived/started/onTrip with different driver_id)
      final takenByOther = rideDriverId != null &&
          rideDriverId != 0 &&
          rideDriverId != myDriverId &&
          (status == RideStatus.accepted ||
              status == RideStatus.arrived ||
              status == RideStatus.started ||
              status == RideStatus.onTrip);
      if (takenByOther) {
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
        // Driver is on a ride: ignore new ride requests until current ride is completed
        final activeRideStatuses = [RideStatus.accepted, RideStatus.arrived, RideStatus.started, RideStatus.onTrip];
        final hasActiveRide = _activeRequests.any((r) => activeRideStatuses.contains(r.status));
        if (status == RideStatus.searching && hasActiveRide) return;

      // Vehicle type filter: only show rides matching driver's vehicle
      if (status == RideStatus.searching && !_matchesDriverVehicle(updatedRide)) {
        return;
      }

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
              _startAlert(ride: updatedRide);
              _startSearchingPoll(); // Rapido-style: poll to detect when another driver accepts
              RideNotificationService().onNewRideFromSocket(
                rideId: updatedRide.id,
                isAppInForeground: _isAppInForeground,
                estimatedFare: updatedRide.estimatedFare,
                distance: updatedRide.distance,
              );
              shouldShowFloatingRide = !_isAppInForeground;
            }
            if (status != RideStatus.searching) {
              FFAppState().activeRideId = updatedRide.id;
            }
          }
        });
        if (shouldShowFloatingRide) {
          final fare = updatedRide.estimatedFare != null
              ? '₹${updatedRide.estimatedFare!.toStringAsFixed(0)}'
              : 'New Ride';
          final pickupDistanceText = _formatPickupDistance(updatedRide);
          final dropDistanceText = _formatDropDistance(updatedRide);
          await FloatingBubbleService.showRideRequest(
            rideId: updatedRide.id,
            fareText: fare,
            pickupDistanceText: pickupDistanceText,
            dropDistanceText: dropDistanceText,
            pickupText: updatedRide.pickupAddress,
            dropText: updatedRide.dropAddress,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing ride: $e');
    }
  }

  void removeRideById(int id) {
    setState(() {
      _activeRequests.removeWhere((r) => r.id == id);
      _timers.remove(id);
      _waitTimers.remove(id);
      _showOtpOverlay.remove(id);
      if (_otpControllers.containsKey(id)) {
        for (var c in _otpControllers[id]!) {
          c.dispose();
        }
        _otpControllers.remove(id);
      }
    });
    if (_activeRequests.isEmpty) _stopAlert();
    if (_activeRequests.every((r) => r.status != RideStatus.searching)) {
      _stopSearchingPoll();
    }
    if (!_isAppInForeground) {
      FloatingBubbleService.hideRideRequest();
    }
  }

  String _formatPickupDistance(RideRequest ride) {
    final driverLoc = widget.driverLocation;
    if (driverLoc == null || ride.pickupLat == 0 || ride.pickupLng == 0) {
      return 'Pickup distance --';
    }
    final meters = Geolocator.distanceBetween(
      driverLoc.latitude,
      driverLoc.longitude,
      ride.pickupLat,
      ride.pickupLng,
    );
    final km = meters / 1000;
    return 'Pickup ${km.toStringAsFixed(1)} km';
  }

  String _formatDropDistance(RideRequest ride) {
    if (ride.distance == null || ride.distance == 0) {
      return 'Drop distance --';
    }
    return 'Drop ${ride.distance!.toStringAsFixed(1)} km';
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

  void _startAlert({RideRequest? ride}) async {
    if (_isAlerting) return;
    _isAlerting = true;
    try {
      await _audioPlayer.stop();
      if (ride != null && _isAlerting) {
        for (var i = 0; i < 3; i++) {
          await VoiceService().speakNewRideAddress(
            pickupLat: ride.pickupLat,
            pickupLng: ride.pickupLng,
            pickupAddress: ride.pickupAddress,
            dropLat: ride.dropLat,
            dropLng: ride.dropLng,
            dropAddress: ride.dropAddress,
            estimatedFare: ride.estimatedFare,
            repeatCount: 1,
          );
          if (!_isAlerting) return;
          await _playAlertOnce();
          if (!_isAlerting) return;
        }
      }
      if (!_isAlerting) return;
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('audios/ride_request.mp3'));
    } catch (_) {}
  }

  Future<void> _playAlertOnce() async {
    if (!_isAlerting) return;
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(AssetSource('audios/ride_request.mp3'));
      await _audioPlayer.onPlayerComplete.first
          .timeout(const Duration(seconds: 6), onTimeout: () {});
    } catch (_) {}
  }

  void _stopAlert() {
    if (!_isAlerting) return;
    _isAlerting = false;
    _audioPlayer.stop();
  }

  /// Rapido-style: Poll SEARCHING rides to remove when another driver accepts.
  void _startSearchingPoll() {
    if (_searchingPollTimer?.isActive == true) return;
    _searchingPollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _pollSearchingRides());
  }

  void _stopSearchingPoll() {
    _searchingPollTimer?.cancel();
    _searchingPollTimer = null;
  }

  Future<void> _pollSearchingRides() async {
    if (!mounted) return;
    final searchingIds = _activeRequests
        .where((r) => r.status == RideStatus.searching)
        .map((r) => r.id)
        .toList();
    if (searchingIds.isEmpty) {
      _stopSearchingPoll();
      return;
    }
    for (final rideId in searchingIds) {
      try {
        final response = await Dio().get(
          '${Config.baseUrl}/api/rides/$rideId',
          options: Options(
              headers: {'Authorization': 'Bearer ${FFAppState().accessToken}'}),
        );
        if (!mounted) return;
        final data = response.data;
        final rideData = data is Map && data['data'] != null
            ? (data['data'] as Map<String, dynamic>)
            : (data is Map<String, dynamic> ? data : null);
        if (rideData != null) handleNewRide(rideData);
      } catch (_) {}
    }
  }

  /// Public: Fetch ride by ID (e.g. when user taps notification from background).
  Future<void> fetchRideById(int rideId) async {
    await _fetchRideFromBackend(rideId);
  }

  Future<void> acceptRideFromBubble(int rideId) async {
    await _acceptRide(rideId);
  }

  Future<void> declineRideFromBubble(int rideId) async {
    _ignoreRideRequest(rideId);
  }

  Future<void> _fetchRideFromBackend(int rideId) async {
    try {
      final response = await Dio().get(
        '${Config.baseUrl}/api/rides/$rideId',
        options: Options(
            headers: {'Authorization': 'Bearer ${FFAppState().accessToken}'}),
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
    if (_isAcceptingRide) return;
    if (!mounted) return;
    setState(() => _isAcceptingRide = true);
    try {
      final res = await Dio().post(
          '${Config.baseUrl}/api/rides/rides/$rideId/accept',
          data: {'driver_id': FFAppState().driverid},
          options: Options(headers: {
            'Authorization': 'Bearer ${FFAppState().accessToken}'
          }));
      if (!mounted) return;
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 300) {
        _updateRideStatus(rideId, RideStatus.accepted);
        FFAppState().activeRideId = rideId;
        VoiceService().rideAccepted();
        // ✅ Uber-style: once one ride is accepted, stop and clear other requests
        setState(() {
          _activeRequests.removeWhere(
              (r) => r.id != rideId && r.status == RideStatus.searching);
          _timers.removeWhere((key, _) => key != rideId);
        });
        _stopAlert();
        _stopSearchingPoll();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res.data?['message'] ?? 'Could not accept ride. Try again.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to accept ride. Please check your connection.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isAcceptingRide = false);
    }
  }

  Future<void> _updateRideStatus(int rideId, RideStatus status) async {
    try {
      final payload = status.value.toLowerCase();
      await Dio().put('${Config.baseUrl}/api/rides/$rideId',
          data: {'ride_status': payload, 'driver_id': FFAppState().driverid},
          options: Options(headers: {
            'Authorization': 'Bearer ${FFAppState().accessToken}'
          }));
      _updateLocalRideStatus(rideId, status);
    } catch (e) {
      print('Status Update Error: $e');
    }
  }

  Future<void> _verifyOtp(int rideId) async {
    final controllers = _otpControllers[rideId];
    if (controllers == null) return;
    final otp = controllers.map((c) => c.text).join();

    try {
      final res = await Dio().post(
          '${Config.baseUrl}/api/rides/verify-otp',
          data: {'otp': otp, 'ride_id': rideId},
          options: Options(headers: {
            'Authorization': 'Bearer ${FFAppState().accessToken}'
          }));

      if (res.data['success'] == true && mounted) {
        _showOtpOverlay.remove(rideId);
        _updateLocalRideStatus(rideId, RideStatus.started);
        VoiceService().rideStarted();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
        }
        for (var c in controllers) {
          c.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification Failed')));
      }
    }
  }

  void _updateLocalRideStatus(int rideId, RideStatus status, {double? finalFare, PaymentMode? paymentMode}) {
    setState(() {
      final idx = _activeRequests.indexWhere((r) => r.id == rideId);
      if (idx != -1) {
        var updated = _activeRequests[idx].copyWith(status: status);
        if (finalFare != null) updated = updated.copyWith(finalFare: finalFare);
        if (paymentMode != null) updated = updated.copyWith(paymentMode: paymentMode);
        _activeRequests[idx] = updated;
        if (status == RideStatus.arrived) _waitTimers[rideId] = 0;
        if (status == RideStatus.completed) _paymentPendingRides.add(rideId);
      }
    });
  }

  String _formatWaitTime(int rideId) {
    final s = _waitTimers[rideId] ?? 0;
    return "${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}";
  }

  Future<void> _cancelRide(int rideId) async {
    if (_isCancellingRide || !mounted) return;
    // Rapido-style: show reason picker bottom sheet first
    final reason = await showCancelRideReasonSheet(context);
    if (reason == null || reason.isEmpty || !mounted) return;
    setState(() => _isCancellingRide = true);
    try {
      final res = await CancelRideCall.call(
        rideId: rideId,
        cancellationReason: reason,
        token: FFAppState().accessToken,
        cancelledBy: 'driver',
      );
      if (!mounted) return;
      if (res.succeeded && (CancelRideCall.success(res.jsonBody) == true)) {
        Provider.of<RideState>(context, listen: false).clearRide();
        removeRideById(rideId);
        FFAppState().activeRideId = 0;
        if (widget.onRideComplete != null) widget.onRideComplete!();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            CancelRideCall.message(res.jsonBody) ??
                FFLocalizations.of(context).getText('drv_ride_cancelled'),
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(CancelRideCall.message(res.jsonBody) ??
              'Failed to cancel ride. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connection error. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isCancellingRide = false);
    }
  }

  void _ignoreRideRequest(int rideId) {
    if (!mounted) return;
    removeRideById(rideId);
    if (_activeRequests.isEmpty) {
      _stopAlert();
    }
  }

  Future<void> _completeRide({required int rideId, required int userId}) async {
    if (_isCompletingRide) return;
    if (!mounted) return;
    setState(() => _isCompletingRide = true);
    try {
      final res = await CompleteRideCall.call(
        rideId: rideId,
        driverId: FFAppState().driverid,
        userId: userId,
        token: FFAppState().accessToken,
      );
      if (!mounted) return;
      if (res.succeeded) {
        final fare = CompleteRideCall.finalFare(res.jsonBody);
        final pmStr = CompleteRideCall.paymentMode(res.jsonBody);
        final pm = pmStr != null ? parsePaymentMode(pmStr) : null;
        _updateLocalRideStatus(rideId, RideStatus.completed,
            finalFare: fare, paymentMode: pm);
        VoiceService().rideCompleted();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Failed to complete ride. Please try again.'),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Connection error. Please try again.'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isCompletingRide = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Guard against a race where the list becomes empty during build.
    if (_activeRequests.isEmpty) return const SizedBox.shrink();

    final searchingRides =
        _activeRequests.where((r) => r.status == RideStatus.searching).toList();
    final activeRide = _activeRequests.firstWhere(
      (r) =>
          r.status == RideStatus.accepted ||
          r.status == RideStatus.arrived ||
          r.status == RideStatus.started ||
          r.status == RideStatus.onTrip ||
          r.status == RideStatus.completed,
      orElse: () => searchingRides.isNotEmpty ? searchingRides.last : _activeRequests.last,
    );
    final RideRequest ride = activeRide;
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
      Null onDone() {
        if (!mounted) return;
        Provider.of<RideState>(context, listen: false).clearRide();
        setState(() {
          _paymentPendingRides.remove(ride.id);
          _activeRequests.removeWhere((r) => r.id == ride.id);
          FFAppState().activeRideId = 0;
        });
        if (widget.onRideComplete != null) widget.onRideComplete!();
      }
      // Show screen based on payment mode
      if (ride.paymentMode.isCash) {
        return Positioned.fill(
          child: Container(
            color: Colors.white,
            child: CashPaymentScreen(
              ride: ride,
              onCollectConfirmed: onDone,
            ),
          ),
        );
      }
      // Online / wallet / default: show review screen
      return Positioned.fill(
        child: Container(
          color: Colors.white,
          child: ReviewScreen(
            ride: ride,
            onSubmit: onDone,
            onClose: () {},
          ),
        ),
      );
    }

    switch (status) {
      case RideStatus.searching:
        if (searchingRides.length == 1) {
          return Positioned(
            bottom: 0, left: 0, right: 0,
            child: NewRequestCard(
              ride: searchingRides.first,
              remainingTime: _timers[searchingRides.first.id] ?? 0,
              onAccept: _isAcceptingRide
                  ? null
                  : () => _acceptRide(searchingRides.first.id),
              onDecline:
                  _isAcceptingRide ? null : () => removeRideById(searchingRides.first.id),
              driverLocation: widget.driverLocation,
              isLoading: _isAcceptingRide,
            ),
          );
        }
        final pageHeight = (MediaQuery.sizeOf(context).height * 0.55)
            .clamp(380.0, 560.0);
        return Positioned(
          bottom: 0, left: 0, right: 0,
          child: SizedBox(
            height: pageHeight,
            child: PageView.builder(
              controller: _requestPageController,
              itemCount: searchingRides.length,
              itemBuilder: (context, index) {
                final r = searchingRides[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NewRequestCard(
                    ride: r,
                    remainingTime: _timers[r.id] ?? 0,
                    onAccept:
                        _isAcceptingRide ? null : () => _acceptRide(r.id),
                    onDecline:
                        _isAcceptingRide ? null : () => removeRideById(r.id),
                    driverLocation: widget.driverLocation,
                    isLoading: _isAcceptingRide,
                  ),
                );
              },
            ),
          ),
        );
      case RideStatus.accepted:
        return Positioned.fill(
          child: RidePickupOverlay(
            ride: ride,
            onSwipe: () {
              _updateRideStatus(ride.id, RideStatus.arrived);
              VoiceService().arrivedAtPickup();
            },
            formattedWaitTime: '',
            onCancel: _isCancellingRide ? null : () => _cancelRide(ride.id),
          ),
        );
      case RideStatus.arrived:
        return Positioned.fill(
          child: RideBottomOverlay(
            ride: ride,
            formattedWaitTime: _formatWaitTime(ride.id),
            onSwipe: () {
              setState(() => _showOtpOverlay.add(ride.id));
              VoiceService().pleaseStartRide();
            },
            onCancel: _isCancellingRide ? () {} : () => _cancelRide(ride.id),
            onCall: () => launchUrl(Uri.parse('tel:${ride.mobileNumber ?? ''}')),
          ),
        );
      case RideStatus.started:
      case RideStatus.onTrip:
        return Positioned.fill(
          child: RideCompleteOverlay(
            ride: ride,
            onSwipe: _isCompletingRide
                ? null
                : () => _completeRide(rideId: ride.id, userId: ride.userId),
            isLoading: _isCompletingRide,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}