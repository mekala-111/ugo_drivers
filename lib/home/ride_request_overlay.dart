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
import 'package:ugo_driver/services/ride_alert_audio_service.dart';
import 'package:ugo_driver/services/route_distance_service.dart';
import 'package:ugo_driver/home/ride_request_model.dart';
import 'package:ugo_driver/ride_chat/ride_chat_widget.dart';
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

  /// True while cash collection / rating UI is covering the map — hide home chrome (e.g. incentives).
  /// Valid on startup: if active_ride_id exists but fetch fails (404), unlock the UI.
  final VoidCallback? onGhostRideCleared;

  /// Callback to notify HomeWidget whether to suppress the incentive tracker (e.g. during cash collection).
  final ValueChanged<bool>? onPostRideIncentiveSuppress;

  const RideRequestOverlay({
    super.key,
    this.driverLocation,
    this.onRideComplete,
    this.onGhostRideCleared,
    this.onPostRideIncentiveSuppress,
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
  int? _cashCollectedForRideId;
  final Map<int, List<TextEditingController>> _otpControllers = {};
  final PageController _requestPageController =
      PageController(viewportFraction: 0.94);

  /// Current page when multiple SEARCHING rides are shown (0-based).
  int _multiRequestPageIndex = 0;

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
    if (driverType.isEmpty || rideType.isEmpty) {
      return true; // don't block if missing
    }
    return driverType == rideType;
  }

  /// Returns false if ride is in a different zone (city) than driver's preferred city.
  /// When zone changes, driver should not receive ride requests outside their zone.
  bool _matchesDriverZone(RideRequest ride) {
    final preferredCityId = FFAppState().preferredCityId;
    if (preferredCityId <= 0) return true; // no preferred city set, allow all
    final ridePickupCityId = ride.pickupCityId;
    if (ridePickupCityId == null) {
      return true; // backend didn't send city, allow
    }
    return ridePickupCityId == preferredCityId;
  }

  AudioPlayer? _audioPlayer;
  bool _isAlerting = false;
  int _alertSessionId = 0;
  bool _isDisposed = false;
  Timer? _tickTimer;
  Timer?
      _searchingPollTimer; // Rapido-style: poll to remove when another driver accepts
  bool _isAcceptingRide = false;
  bool _isCompletingRide = false;
  bool _isCancellingRide = false;
  bool _isAppInForeground = true;
  bool _lastPostRideIncentiveSuppress = false;

  /// Locally rejected ride IDs (this driver pressed decline/ignore).
  /// Used so a single decline — either from the overlay or in-app —
  /// is enough to suppress further prompts for the same ride.
  final Set<int> _locallyRejectedRideIds = {};

  void _notifyPostRideIncentiveSuppress(bool suppress) {
    if (_lastPostRideIncentiveSuppress == suppress) return;
    _lastPostRideIncentiveSuppress = suppress;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !mounted) return;
      widget.onPostRideIncentiveSuppress?.call(suppress);
    });
  }

  bool get _driverHasActiveRideLock {
    final lockedStatuses = {
      RideStatus.accepted,
      RideStatus.arrived,
      RideStatus.started,
      RideStatus.onTrip,
    };
    // Lock only from live in-memory ride states, not from a stale persisted ID.
    return _activeRequests.any((ride) => lockedStatuses.contains(ride.status));
  }

  Future<bool> _hasConfirmedServerActiveRideLock() async {
    const lockedStatuses = {'ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP'};
    try {
      final res = await DriverIdfetchCall.call(
        id: FFAppState().driverid,
        token: FFAppState().accessToken,
      );
      if (res.succeeded != true) return _driverHasActiveRideLock;

      final activeRideIdRaw =
          getJsonField(res.jsonBody, r'$.data.active_ride_id') ??
              getJsonField(res.jsonBody, r'$.data.current_ride_id') ??
              getJsonField(res.jsonBody, r'$.data.ride_id');
      final activeRideStatusRaw =
          getJsonField(res.jsonBody, r'$.data.active_ride_status') ??
              getJsonField(res.jsonBody, r'$.data.current_ride_status') ??
              getJsonField(res.jsonBody, r'$.data.ride_status');

      final activeRideId = int.tryParse('${activeRideIdRaw ?? ''}') ?? 0;
      final activeRideStatus = '${activeRideStatusRaw ?? ''}'.toUpperCase();
      final hasLock =
          activeRideId > 0 || lockedStatuses.contains(activeRideStatus);

      if (!hasLock) {
        FFAppState().activeRideId = 0;
        FFAppState().activeRideStatus = '';
      } else {
        if (activeRideId > 0) FFAppState().activeRideId = activeRideId;
        if (activeRideStatus.isNotEmpty) {
          FFAppState().activeRideStatus = activeRideStatus;
        }
      }
      return hasLock || _driverHasActiveRideLock;
    } catch (_) {
      return _driverHasActiveRideLock;
    }
  }

  // ✅ Track completed incentives to detect newly completed ones
  final Set<int> _completedIncentiveIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _isDisposed = true;
    final cb = widget.onPostRideIncentiveSuppress;
    if (cb != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => cb(false));
    }
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _searchingPollTimer?.cancel();
    _stopAlert();
    unawaited(_disposeAlertAudio());
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
      final activeRideId = FFAppState().activeRideId;

      // Fast-fail: ignore unknown statuses to prevent UI state corruption
      if (status == RideStatus.unknown) {
        return;
      }

      // If this driver already declined/ignored this ride locally, do not
      // surface it again as a SEARCHING request (overlay or in-app).
      if (status == RideStatus.searching &&
          (_locallyRejectedRideIds.contains(updatedRide.id) ||
              FFAppState().isSessionDeclinedRide(updatedRide.id))) {
        return;
      }

      final int myDriverId = FFAppState().driverid;
      final int? rideDriverId = updatedRide.driverId;

      // Remove if cancelled, rejected, expired (superseded by retry), or completed by another driver
      if (status == RideStatus.cancelled ||
          status == RideStatus.rejected ||
          status == RideStatus.expired) {
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
        if (!mounted) return;
        setState(() {
          _activeRequests[index] = updatedRide;
          if (status == RideStatus.searching) {
            _timers[updatedRide.id] = rideRequestOfferSeconds;
          }
          if (status == RideStatus.arrived &&
              !_waitTimers.containsKey(updatedRide.id)) {
            _waitTimers[updatedRide.id] = 0;
          }
        });
      } else {
        // Active ride lock: never allow additional SEARCHING rides while one is ongoing.
        if (status == RideStatus.searching && _driverHasActiveRideLock) return;

        // Uber-style exclusive ringing: never allow a new SEARCHING ride if one is already ringing.
        if (status == RideStatus.searching &&
            _activeRequests.any((r) => r.status == RideStatus.searching)) {
          return;
        }

        if (activeRideId != 0 &&
            updatedRide.id != activeRideId &&
            status != RideStatus.completed &&
            status != RideStatus.cancelled &&
            status != RideStatus.rejected) {
          return;
        }

        // Vehicle type filter: only show rides matching driver's vehicle
        if (status == RideStatus.searching &&
            !_matchesDriverVehicle(updatedRide)) {
          return;
        }

        // Zone filter: only show rides in driver's preferred city (when zone changes, don't get ride requests)
        if (status == RideStatus.searching &&
            !_matchesDriverZone(updatedRide)) {
          return;
        }

        if (!mounted) return;
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
              _timers[updatedRide.id] = rideRequestOfferSeconds;
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
          final pickupDistanceText =
              await _formatRoadPickupDistance(updatedRide);
          final dropDistanceText = await _formatRoadDropDistance(updatedRide);
          await FloatingBubbleService.showRideRequest(
            rideId: updatedRide.id,
            fareText: fare,
            pickupDistanceText: pickupDistanceText,
            dropDistanceText: dropDistanceText,
            pickupText: updatedRide.pickupAddress,
            dropText: updatedRide.dropAddress,
            paymentMethod: updatedRide.rawPaymentMode,
            isPro: updatedRide.bookingMode.toLowerCase() == 'pro',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error parsing ride: $e');
    }
  }

  Future<void> _rejectRide(int rideId, {String? reason}) async {
    if (reason == 'request_timeout') {
      _stopAlert();
    }
    final token = FFAppState().accessToken;
    final driverId = FFAppState().driverid;
    if (token.isNotEmpty && driverId > 0) {
      try {
        await RejectRideCall.call(
          token: token,
          rideId: rideId,
          driverId: driverId,
          reason: reason,
        );
      } catch (_) {
        if (kDebugMode) debugPrint('Reject ride API error');
      }
    }
    // Remember that this driver has declined this ride so future SEARCHING
    // updates for the same id are ignored (no second decline prompt).
    _locallyRejectedRideIds.add(rideId);
    FFAppState().rememberSessionDeclinedRide(rideId);
    if (mounted) {
      removeRideById(rideId);
    }
  }

  void removeRideById(int id) {
    if (!mounted) return;
    setState(() {
      _activeRequests.removeWhere((r) => r.id == id);
      _timers.remove(id);
      _waitTimers.remove(id);
      _showOtpOverlay.remove(id);
      if (_cashCollectedForRideId == id) _cashCollectedForRideId = null;
      if (_otpControllers.containsKey(id)) {
        for (var c in _otpControllers[id]!) {
          c.dispose();
        }
        _otpControllers.remove(id);
      }
    });
    if (_activeRequests.isEmpty) _stopAlert();
    if (!_isAppInForeground) {
      FloatingBubbleService.hideRideRequest();
    }
  }

  /// Driver → pickup driving distance (Directions/Matrix), like Rapido.
  Future<String> _formatRoadPickupDistance(RideRequest ride) async {
    final driverLoc = widget.driverLocation;
    if (driverLoc == null || ride.pickupLat == 0 || ride.pickupLng == 0) {
      return '--';
    }
    final km = await RouteDistanceService().getDrivingDistanceKm(
      originLat: driverLoc.latitude,
      originLng: driverLoc.longitude,
      destLat: ride.pickupLat,
      destLng: ride.pickupLng,
    );
    if (km != null && km > 0) {
      return '${km.toStringAsFixed(1)} km';
    }
    final meters = Geolocator.distanceBetween(
      driverLoc.latitude,
      driverLoc.longitude,
      ride.pickupLat,
      ride.pickupLng,
    );
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Trip leg pickup → drop (matches request card; not driver → drop).
  Future<String> _formatRoadDropDistance(RideRequest ride) async {
    if (ride.pickupLat == 0 ||
        ride.pickupLng == 0 ||
        ride.dropLat == 0 ||
        ride.dropLng == 0) {
      return '--';
    }
    final km = await RouteDistanceService().getDrivingDistanceKm(
      originLat: ride.pickupLat,
      originLng: ride.pickupLng,
      destLat: ride.dropLat,
      destLng: ride.dropLng,
    );
    if (km != null && km > 0) {
      return '${km.toStringAsFixed(1)} km';
    }
    final meters = Geolocator.distanceBetween(
      ride.pickupLat,
      ride.pickupLng,
      ride.dropLat,
      ride.dropLng,
    );
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Rapido-style: each SEARCHING offer expires after this many seconds on the driver UI.
  static const int rideRequestOfferSeconds = 30;

  void _startTickTimer() {
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final expiredSearching = <int>[];
      setState(() {
        _timers.forEach((id, val) {
          if (val <= 0) return;
          final next = val - 1;
          _timers[id] = next;
          if (next == 0 &&
              _activeRequests
                  .any((r) => r.id == id && r.status == RideStatus.searching)) {
            expiredSearching.add(id);
          }
        });
        _waitTimers.forEach((id, val) {
          _waitTimers[id] = val + 1;
        });
      });
      for (final id in expiredSearching) {
        unawaited(_rejectRide(id, reason: 'request_timeout'));
      }
    });
  }

  bool _isAlertSessionActive(int sessionId, {AudioPlayer? audioPlayer}) {
    return _isAlerting &&
        _alertSessionId == sessionId &&
        !_isDisposed &&
        (audioPlayer == null || identical(_audioPlayer, audioPlayer));
  }

  Future<AudioPlayer?> _replaceAlertAudio() async {
    final previousPlayer = _audioPlayer;
    _audioPlayer = null;
    await RideAlertAudioService.safeDisposePlayer(previousPlayer);

    await RideAlertAudioService.stopLingeringAlertAudio();
    if (_isDisposed) return null;

    final audioPlayer = RideAlertAudioService.createPlayer();
    if (_isDisposed) {
      await RideAlertAudioService.safeDisposePlayer(audioPlayer);
      return null;
    }

    _audioPlayer = audioPlayer;
    try {
      await audioPlayer.stop();
    } catch (_) {}
    try {
      await audioPlayer.release();
    } catch (_) {}
    return audioPlayer;
  }

  Future<void> _disposeAlertAudio() async {
    final audioPlayer = _audioPlayer;
    _audioPlayer = null;
    await RideAlertAudioService.safeDisposePlayer(audioPlayer);
    await RideAlertAudioService.stopLingeringAlertAudio();
  }

  void _startAlert({RideRequest? ride}) async {
    final sessionId = ++_alertSessionId;
    _isAlerting = true;
    try {
      await VoiceService().stop();
      await RideNotificationService().cancelRideNotification();
      final audioPlayer = await _replaceAlertAudio();
      if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer) ||
          audioPlayer == null) {
        _isAlerting = false;
        return;
      }
      if (ride != null &&
          _isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) {
        for (var i = 0; i < 3; i++) {
          if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) {
            return;
          }
          await _playAlertOnce(sessionId, audioPlayer);
          if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) {
            return;
          }
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
          if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) {
            return;
          }
        }
      }
      if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) return;
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) return;
      await audioPlayer.play(AssetSource('audios/ride_request.mp3'));
    } catch (_) {}
  }

  Future<void> _playAlertOnce(int sessionId, AudioPlayer audioPlayer) async {
    if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) return;
    try {
      await audioPlayer.stop();
      await audioPlayer.setReleaseMode(ReleaseMode.stop);
      if (!_isAlertSessionActive(sessionId, audioPlayer: audioPlayer)) return;
      await audioPlayer.play(AssetSource('audios/ride_request.mp3'));
      // Use take(1)+listen to avoid "Bad state: No element" when stream
      // completes without emitting (e.g. if player is stopped early)
      await audioPlayer.onPlayerComplete
          .take(1)
          .listen((_) {})
          .asFuture()
          .timeout(const Duration(seconds: 6), onTimeout: () {});
    } catch (_) {}
  }

  void _stopAlert() {
    _isAlerting = false;
    _alertSessionId++;
    unawaited(_stopAlertAudio());
  }

  Future<void> _stopAlertAudio() async {
    try {
      await _disposeAlertAudio();
    } catch (_) {}
    try {
      await RideNotificationService().cancelRideNotification();
    } catch (_) {}
    try {
      await VoiceService().stop();
    } catch (_) {}
  }

  /// Uber flow: exclusive dispatch, do not poll aggressively.
  void _startSearchingPoll() {
    // Disabled to stop "fastest finger first" ripping UI aggressively.
  }

  void _stopSearchingPoll() {
    // Disabled to stop "fastest finger first" ripping UI aggressively.
  }

  Future<void> _pollSearchingRides() async {
    // Disabled to stop "fastest finger first" ripping UI aggressively.
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
        if (rideData != null) {
          // Keep local state such as bookingMode if the API doesn't return it
          final existing = _activeRequests.firstWhere(
            (r) => r.id == rideId,
            orElse: () => RideRequest.fromJson(rideData),
          );

          final updatedRide = RideRequest.fromJson(rideData).copyWith(
            bookingMode: rideData.containsKey('booking_mode')
                ? rideData['booking_mode']?.toString().toLowerCase() ??
                    existing.bookingMode
                : existing
                    .bookingMode, // Preserve the booking mode from initial socket push if API doesn't return it
          );

          handleNewRide(
              rideData..addAll({'booking_mode': updatedRide.bookingMode}));
        }
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
    await _rejectRide(rideId);
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
        if (mounted) {
          Provider.of<RideState>(context, listen: false).clearRide();
          widget.onGhostRideCleared?.call();
        }
      }
    }
  }

  Future<void> _acceptRide(int rideId) async {
    _stopAlert();
    if (_isAcceptingRide) return;
    if (!mounted) return;
    if (_driverHasActiveRideLock && FFAppState().activeRideId != rideId) {
      final hasServerLock = await _hasConfirmedServerActiveRideLock();
      if (!hasServerLock) {
        // Stale local lock cleared from server confirmation; continue accept flow.
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete your current ride first.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    setState(() => _isAcceptingRide = true);
    try {
      final rideCheckRes = await Dio().get(
        '${Config.baseUrl}/api/rides/$rideId',
        options: Options(
            headers: {'Authorization': 'Bearer ${FFAppState().accessToken}'}),
      );
      Map<String, dynamic>? rideData;
      final raw = rideCheckRes.data;
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is Map) {
          rideData = Map<String, dynamic>.from(inner);
        } else if (inner == null && raw['ride_status'] != null) {
          // Flat ride payload (no `data` wrapper)
          rideData = Map<String, dynamic>.from(raw);
        }
      }
      final serverStatus =
          (rideData?['ride_status'] ?? '').toString().trim().toUpperCase();
      final assignedDriverId =
          int.tryParse('${rideData?['driver_id'] ?? 0}') ?? 0;
      final myId = FFAppState().driverid;
      if (myId <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Driver session invalid. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      final bookedByAnother = assignedDriverId != 0 &&
          assignedDriverId != myId &&
          serverStatus != 'COMPLETED' &&
          serverStatus != 'CANCELLED' &&
          serverStatus != 'REJECTED';
      // Empty status means we could not read the ride payload; let the accept API decide.
      if (bookedByAnother ||
          (serverStatus.isNotEmpty && serverStatus != 'SEARCHING')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This ride is already booked.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final acceptRes = await AcceptRideCall.call(
        token: FFAppState().accessToken,
        rideId: rideId,
        driverId: myId,
      );
      if (!mounted) return;
      final accepted = acceptRes.succeeded &&
          (AcceptRideCall.success(acceptRes.jsonBody) ?? true);
      if (accepted) {
        _updateRideStatus(rideId, RideStatus.accepted);
        FFAppState().activeRideId = rideId;
        VoiceService().rideAccepted();
        
        // Grab the ride from local state to get pickup coordinates
        double? pickupLat;
        double? pickupLng;
        try {
          final acceptedRide = _activeRequests.firstWhere((r) => r.id == rideId);
          pickupLat = acceptedRide.pickupLat;
          pickupLng = acceptedRide.pickupLng;
        } catch (_) {}

        // ✅ Uber-style: once one ride is accepted, stop and clear other requests
        setState(() {
          _activeRequests.removeWhere(
              (r) => r.id != rideId && r.status == RideStatus.searching);
          _timers.removeWhere((key, _) => key != rideId);
        });
        _stopAlert();

        // ✅ Uber-style: Auto-launch navigation seamlessly when accepted
        if (pickupLat != null && pickupLng != null && pickupLat != 0 && pickupLng != 0) {
          final uri = Uri.parse('google.navigation:q=$pickupLat,$pickupLng&mode=d');
          canLaunchUrl(uri).then((canLaunch) {
            if (canLaunch) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              // Fallback to standard intent URL
              launchUrl(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$pickupLat,$pickupLng&travelmode=driving'), mode: LaunchMode.externalApplication);
            }
          });
        }
      } else {
        if (mounted) {
          var apiMsg = AcceptRideCall.message(acceptRes.jsonBody)?.trim();
          if (apiMsg == null || apiMsg.isEmpty) {
            if (acceptRes.statusCode == -1) {
              apiMsg = 'Network error. Check your connection.';
            } else if (acceptRes.statusCode > 0) {
              apiMsg =
                  'Could not accept ride (HTTP ${acceptRes.statusCode}). Try again.';
            } else {
              apiMsg = 'Could not accept ride. Try again.';
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(apiMsg),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        final fallback = FFLocalizations.of(context).getText('ride0001');
        var msg = fallback.isNotEmpty
            ? fallback
            : 'Failed to accept ride. Please check your connection.';
        if (e is DioException) {
          final d = e.response?.data;
          if (d is Map && d['message'] != null) {
            final m = d['message'].toString().trim();
            if (m.isNotEmpty) msg = m;
          }
          if (kDebugMode) {
            debugPrint(
                'Accept ride error: ${e.response?.statusCode} ${e.response?.data}');
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
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
      await Dio().post('${Config.baseUrl}/api/drivers/update-ride-status',
          data: {
            'ride_id': rideId,
            'status': payload,
            'driver_id': FFAppState().driverid
          },
          options: Options(headers: {
            'Authorization': 'Bearer ${FFAppState().accessToken}'
          }));
      _updateLocalRideStatus(rideId, status);
    } catch (e) {
      if (kDebugMode) debugPrint('Status Update Error: $e');
    }
  }

  Future<void> _verifyOtp(int rideId) async {
    final controllers = _otpControllers[rideId];
    if (controllers == null) return;
    final otp = controllers.map((c) => c.text).join();

    try {
      final res = await Dio().post('${Config.baseUrl}/api/rides/verify-otp',
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(FFLocalizations.of(context).getText('ride0002'))));
        }
        for (var c in controllers) {
          c.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(FFLocalizations.of(context).getText('ride0003'))));
      }
    }
  }

  void _updateLocalRideStatus(int rideId, RideStatus status,
      {double? finalFare, PaymentMode? paymentMode}) {
    if (!mounted) return;
    setState(() {
      final idx = _activeRequests.indexWhere((r) => r.id == rideId);
      if (idx != -1) {
        var updated = _activeRequests[idx].copyWith(status: status);
        if (finalFare != null) updated = updated.copyWith(finalFare: finalFare);
        if (paymentMode != null) {
          updated = updated.copyWith(paymentMode: paymentMode);
        }
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

  void _openRideChat(RideRequest ride) {
    if (!mounted) return;
    final loc = FFLocalizations.of(context);
    final name = ride.fullName.trim().isNotEmpty
        ? ride.fullName
        : loc.getText('drv_passenger');
    context.pushNamed(
      RideChatWidget.routeName,
      queryParameters: {
        'rideId': ride.id.toString(),
        'partnerName': name,
      },
    );
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FFLocalizations.of(context).getText('ride0004')),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isCancellingRide = false);
    }
  }

  /// Fetch incentives after ride completion and add wallet reward for completed incentives
  Future<void> _fetchIncentivesAfterRideCompletion() async {
    try {
      debugPrint('🎯 Fetching incentives after ride completion...');
      final res = await DriverIncentivesCall.call(
        token: FFAppState().accessToken,
        driverId: FFAppState().driverid,
      );

      if (res.succeeded) {
        final incentives = DriverIncentivesCall.incentiveList(res.jsonBody);
        debugPrint(
            '✅ Incentives fetched successfully: ${incentives.length} incentives found');

        // Extract ride count from incentives
        if (incentives.isNotEmpty) {
          int totalCompletedRides = 0;
          double newlyCompletedRewards = 0.0;
          List<String> completedIncentiveNames = [];

          for (var incentive in incentives) {
            final incentiveId = incentive['id'] ?? 0;
            final completedRides =
                DriverIncentivesCall.itemCompletedRides(incentive);
            final status = DriverIncentivesCall.itemProgressStatus(incentive);
            final name = DriverIncentivesCall.itemIncentiveName(incentive);
            final reward = DriverIncentivesCall.itemRewardAmount(incentive);

            totalCompletedRides += completedRides;
            debugPrint('📊 Incentive: $name - '
                'Completed rides: $completedRides/${DriverIncentivesCall.itemTargetRides(incentive)} - '
                'Status: $status - Reward: ₹$reward');

            // ✅ Check if incentive just completed
            if (status == 'completed' &&
                !_completedIncentiveIds.contains(incentiveId)) {
              debugPrint(
                  '🎉 Incentive "$name" is now COMPLETED! Reward: ₹$reward');
              _completedIncentiveIds.add(incentiveId);
              newlyCompletedRewards += reward;
              completedIncentiveNames.add(name);
            }
          }

          debugPrint(
              '🎉 Total completed rides across incentives: $totalCompletedRides');

          // ✅ Add completed incentive rewards to wallet
          if (newlyCompletedRewards > 0 && mounted) {
            debugPrint(
                '💰 Adding ₹$newlyCompletedRewards to wallet for completed incentives...');
            _addIncentiveRewardToWallet(
                newlyCompletedRewards, completedIncentiveNames);
          }
        }
      } else {
        debugPrint(
            '⚠️ Failed to fetch incentives after ride completion: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching incentives after ride completion: $e');
    }
  }

  /// Add completed incentive reward to wallet
  Future<void> _addIncentiveRewardToWallet(
      double amount, List<String> incentiveNames) async {
    try {
      final res = await AddMoneyToWalletCall.call(
        driverId: FFAppState().driverid,
        amount: amount,
        currency: 'INR',
        token: FFAppState().accessToken,
      );

      if (res.succeeded) {
        debugPrint('✅ Incentive reward ₹$amount added to wallet successfully!');

        if (mounted) {
          // Show success notification
          final incentiveList = incentiveNames.join(', ');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '🎉 Incentive Complete!\n'
                '$incentiveList\n'
                '✅ ₹${amount.toStringAsFixed(2)} added to wallet',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        debugPrint(
            '⚠️ Failed to add incentive reward to wallet: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error adding incentive reward to wallet: $e');
    }
  }

  Future<void> _completeRide(
      {required int rideId,
      required int userId,
      required RideRequest ride}) async {
    if (_isCompletingRide) return;
    if (!mounted) return;

    setState(() => _isCompletingRide = true);
    try {
      final res = await CompleteRideCall.call(
        rideId: rideId,
        driverId: FFAppState().driverid,
        userId: userId,
        token: FFAppState().accessToken,
        finalFare: ride.finalFare ?? ride.estimatedFare,
      );
      if (!mounted) return;
      if (res.succeeded) {
        final fare = CompleteRideCall.finalFare(res.jsonBody);
        final pmStr = CompleteRideCall.paymentMode(res.jsonBody);
        final parsedResponsePm =
            pmStr != null ? parsePaymentMode(pmStr) : PaymentMode.unknown;

        // Preserve cash mode reliably even if completion API omits/changes payment field.
        final pm = parsedResponsePm == PaymentMode.unknown
            ? (ride.paymentMode != PaymentMode.unknown
                ? ride.paymentMode
                : parsePaymentMode(ride.rawPaymentMode))
            : parsedResponsePm;
        _updateLocalRideStatus(rideId, RideStatus.completed,
            finalFare: fare, paymentMode: pm);
        VoiceService().rideCompleted();

        // ✅ Fetch incentives immediately after ride completion
        // This ensures the incentive ride count is updated in real-time
        debugPrint(
            '🏁 Ride $rideId completed successfully. Fetching updated incentives...');
        _fetchIncentivesAfterRideCompletion();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(FFLocalizations.of(context).getText('ride0005')),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FFLocalizations.of(context).getText('ride0004')),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isCompletingRide = false);
    }
  }

  /// Shown above the pager when more than one SEARCHING ride is visible.
  Widget _multiRequestCountBadge(BuildContext context, int total) {
    if (total <= 1) return const SizedBox.shrink();
    final safeIdx = _multiRequestPageIndex.clamp(0, total - 1);
    final current = safeIdx + 1;
    final template = FFLocalizations.of(context).getText('drv_request_pager');
    final label = template.isEmpty
        ? '$current of $total'
        : template
            .replaceAll('{current}', '$current')
            .replaceAll('{total}', '$total');
    return Material(
      color: Colors.black.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guard against a race where the list becomes empty during build.
    if (_activeRequests.isEmpty) {
      _notifyPostRideIncentiveSuppress(false);
      return const SizedBox.shrink();
    }

    final searchingRides =
        _activeRequests.where((r) => r.status == RideStatus.searching).toList();
    final activeRide = _activeRequests.firstWhere(
      (r) =>
          r.status == RideStatus.accepted ||
          r.status == RideStatus.arrived ||
          r.status == RideStatus.started ||
          r.status == RideStatus.onTrip ||
          r.status == RideStatus.completed,
      orElse: () => searchingRides.isNotEmpty
          ? searchingRides.last
          : _activeRequests.last,
    );
    final RideRequest ride = activeRide;
    final RideStatus status = ride.status;

    _notifyPostRideIncentiveSuppress(
      _paymentPendingRides.contains(ride.id) || status == RideStatus.completed,
    );

    if (_showOtpOverlay.contains(ride.id)) {
      if (!_otpControllers.containsKey(ride.id)) {
        _otpControllers[ride.id] =
            List.generate(4, (_) => TextEditingController());
      }
      return Positioned.fill(
          child: SafeArea(
        child: OtpVerificationSheet(
          otpControllers: _otpControllers[ride.id]!,
          onVerify: () => _verifyOtp(ride.id),
        ),
      ));
    }

    if (_paymentPendingRides.contains(ride.id) ||
        status == RideStatus.completed) {
      void onDone() {
        if (!mounted) return;
        Provider.of<RideState>(context, listen: false).clearRide();
        setState(() {
          _paymentPendingRides.remove(ride.id);
          _activeRequests.removeWhere((r) => r.id == ride.id);
          FFAppState().activeRideId = 0;
          _cashCollectedForRideId = null;
        });
        if (widget.onRideComplete != null) widget.onRideComplete!();
      }

      // Cash flow: 1) Collect cash screen → 2) Rating screen after CASH COLLECTED tap
      if (ride.paymentMode.isCash) {
        if (_cashCollectedForRideId == ride.id) {
          // Cash collected → navigate to Review screen
          return Positioned.fill(
            child: SafeArea(
              child: Container(
                color: Colors.white,
                child: ReviewScreen(
                  ride: ride,
                  isCashPayment: true,
                  onSubmit: onDone,
                  onClose: () {},
                ),
              ),
            ),
          );
        }
        // Cash not yet collected → show collect screen
        return Positioned.fill(
          child: SafeArea(
            child: Container(
              color: Colors.white,
              child: CashPaymentScreen(
                ride: ride,
                onCollectConfirmed: () {
                  if (!mounted) return;
                  setState(() => _cashCollectedForRideId = ride.id);
                },
              ),
            ),
          ),
        );
      }
      // Online / wallet: amount added to wallet by backend → show rating screen directly
      return Positioned.fill(
        child: SafeArea(
          child: Container(
            color: Colors.white,
            child: ReviewScreen(
              ride: ride,
              isCashPayment: false,
              onSubmit: onDone,
              onClose: () {},
            ),
          ),
        ),
      );
    }

    switch (status) {
      case RideStatus.searching:
        if (searchingRides.isEmpty) {
          return const SizedBox.shrink();
        }
        if (searchingRides.length == 1) {
          return Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: NewRequestCard(
                ride: searchingRides.first,
                remainingTime: _timers[searchingRides.first.id] ?? 0,
                onAccept: _isAcceptingRide
                    ? null
                    : () => _acceptRide(searchingRides.first.id),
                onDecline: _isAcceptingRide
                    ? null
                    : () => _rejectRide(searchingRides.first.id),
                driverLocation: widget.driverLocation,
                isLoading: _isAcceptingRide,
              ),
            ),
          );
        }
        final pageHeight =
            (MediaQuery.sizeOf(context).height * 0.55).clamp(380.0, 560.0);
        final totalVisible = searchingRides.length;
        if (totalVisible > 0 && _multiRequestPageIndex >= totalVisible) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final newIdx = totalVisible - 1;
            setState(() => _multiRequestPageIndex = newIdx);
            if (!_requestPageController.hasClients) return;
            try {
              _requestPageController.jumpToPage(newIdx);
            } catch (_) {
              // PageView may be unmounted or page out of range during list changes.
            }
          });
        }
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: pageHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PageView.builder(
                    controller: _requestPageController,
                    itemCount: totalVisible,
                    onPageChanged: (i) {
                      setState(() => _multiRequestPageIndex = i);
                    },
                    itemBuilder: (context, index) {
                      final r = searchingRides[index];
                      final h = MediaQuery.sizeOf(context).height;
                      return Padding(
                        padding: EdgeInsets.only(bottom: h * 0.01),
                        child: NewRequestCard(
                          ride: r,
                          remainingTime: _timers[r.id] ?? 0,
                          onAccept:
                              _isAcceptingRide ? null : () => _acceptRide(r.id),
                          onDecline:
                              _isAcceptingRide ? null : () => _rejectRide(r.id),
                          driverLocation: widget.driverLocation,
                          isLoading: _isAcceptingRide,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _multiRequestCountBadge(
                        context,
                        totalVisible,
                      ),
                    ),
                  ),
                ],
              ),
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
            onChat: () => _openRideChat(ride),
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
            onCall: () =>
                launchUrl(Uri.parse('tel:${ride.mobileNumber ?? ''}')),
            onChat: () => _openRideChat(ride),
          ),
        );
      case RideStatus.started:
      case RideStatus.onTrip:
        return Positioned.fill(
          child: RideCompleteOverlay(
            ride: ride,
            onSwipe: _isCompletingRide
                ? null
                : () => _completeRide(
                      rideId: ride.id,
                      userId: ride.userId,
                      ride: ride,
                    ),
            isLoading: _isCompletingRide,
            onChat: () => _openRideChat(ride),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
