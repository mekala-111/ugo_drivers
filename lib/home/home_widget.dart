import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmf;
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '/components/menu_widget.dart';
import '/controllers/home_controller.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/api_requests/api_calls.dart';
import '/providers/ride_provider.dart';
import '/services/ride_notification_service.dart';
import '/services/route_polyline_service.dart';
import '/services/floating_bubble_service.dart';
import 'home_model.dart';
import 'ride_request_model.dart';
import 'ride_request_overlay.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_ride_panel.dart';
import 'widgets/earnings_summary.dart';
import 'widgets/incentive_panel.dart';
import 'widgets/offline_dashboard.dart';
import 'widgets/ride_map.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/firebase_remote_config_service.dart';
import '../services/in_app_update_service.dart';
import '../components/update_dialog.dart';
import '../account_support/documents.dart';

import '../flutter_flow/lat_lng.dart' as latlng;

export 'home_model.dart';

/// Dedupes native `ride_action` redelivery (sticky Intent / engine reattach) so
/// decline + [FloatingBubbleService.moveTaskToBack] does not run again when reopening the app.
String? _rideActionDedupeKey;
DateTime? _rideActionDedupeAt;

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget>
    with
        AutomaticKeepAliveClientMixin,
        WidgetsBindingObserver,
        TickerProviderStateMixin {
  late HomeModel _model;
  late HomeController _controller;

  final GlobalKey<RideRequestOverlayState> _overlayKey =
  GlobalKey<RideRequestOverlayState>();
  final GlobalKey<FlutterFlowGoogleMapState> _mapKey =
  GlobalKey<FlutterFlowGoogleMapState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isIncentivePanelExpanded = false;

  /// Hide incentives while cash collect / rating sheet is open (overlay).
  bool _suppressIncentiveForPostRide = false;
  DateTime? _lastBackPressed;
  String? _activeRouteKey;
  bool _bubbleVisible = false;
  String? _lastBubbleSyncKey;
  bool _lastOnlineState = false;
  int _lastDriverProfileRefreshSeq = 0;
  DateTime? _lastCameraMoveTime;
  latlng.LatLng? _lastCameraCenter;
  DateTime? _lastCircleFlushTime;
  Timer? _circleFlushTimer;
  bool _sessionKycGateDialogShown = false;

  // Pulsating ripple animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  Set<Circle> _statusCircles = {};
  Set<Circle> _rippleCircles = {};

  // Route flowing-dot animation
  late AnimationController _routeAnimController;
  List<latlng.LatLng> _routePoints = [];
  Circle? _routeDotCircle;

  final MethodChannel _bubbleChannel =
  const MethodChannel('com.ugotaxi_rajkumar.driver/floating_bubble');
  static const Duration _circleFlushInterval = Duration(milliseconds: 120);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    WidgetsBinding.instance.addObserver(this);
    _bubbleChannel.setMethodCallHandler(_handleBubbleMethod);
    unawaited(_consumePendingRideAction());

    // Setup pulsating ripple animation (don't start yet — _controller not ready)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
    _pulseController.addListener(_updateRipple);

    // ✅ CHECK FOR APP UPDATES
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVersionUpdate();
    });

    // Route animated dot (don't start yet)
    _routeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _routeAnimController.addListener(_updateRouteDot);

    _controller = HomeController(
      onDocumentsIncompleteNavigate: () async {
        if (!mounted) return;
        context.pushNamed(DocumentsScreen.routeName);
      },
      onShowKycDialog: (status, rejectionReason) async {
        if (!mounted) return;
        String title = 'Document verification required';
        String message = 'Complete documents to start earning.';
        final normalized = status.trim().toLowerCase();
        if (normalized == 'pending' ||
            normalized == 'in_review' ||
            normalized == 'under_review' ||
            normalized == 'pending_verification' ||
            normalized == 'submitted' ||
            normalized == 'awaiting_kyc') {
          title = 'Pending for verification';
          message =
          'Waiting for admin approval. Your documents are under review.';
        } else if (normalized == 'rejected' || normalized == 'declined') {
          title = 'Documents rejected';
          final reason = rejectionReason?.trim() ?? '';
          message = reason.isEmpty
              ? 'Your documents were rejected. Please re-upload clear and valid documents.'
              : 'Reason: $reason';
        }
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(FFLocalizations.of(context).getText('drv_ok')),
              )
            ],
          ),
        );
      },
      onShowLocationDisclosure: () async {
        if (!mounted) return false;
        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Access Required'),
            content: const Text(
              'Ugo Taxi Driver collects location data to show your current position on the map, match you with nearby ride requests, and provide navigation to pickup and drop-off points, even when the app is in the background during an active ride.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style:
                FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Agree'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onShowBackgroundLocationNotice: () async {
        if (!mounted) return false;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (ctx) => const BackgroundLocationNoticeWidget(),
          ),
        );
        return result == true;
      },
      onShowPermissionDialog: () async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
                FFLocalizations.of(context).getText('drv_location_needed'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text(
              FFLocalizations.of(context).getText('drv_location_body'),
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(FFLocalizations.of(context).getText('drv_not_now')),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await Geolocator.openAppSettings();
                },
                style:
                FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(
                    FFLocalizations.of(context).getText('drv_open_settings')),
              ),
            ],
          ),
        );
      },
      onShowGoOnlinePermissions: () async {
        if (!mounted) return false;
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PreLoginPermissionsScreen(
              onComplete: () {
                FFAppState().hasSeenGoOnlinePermissions = true;
                Navigator.of(context).pop(true);
              },
              onBack: () => Navigator.of(context).pop(false),
            ),
          ),
        );
        return result == true;
      },
      onShowSnackBar: (key, {isError = false}) {
        if (!mounted) return;
        final localized = FFLocalizations.of(context).getText(key);
        final message = localized.isNotEmpty ? localized : key;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      onSocketRideData: _passDataToOverlay,
      onFetchRideById: (id) => _overlayKey.currentState?.fetchRideById(id),
    );

    // ✅ Sync state immediately after controller creation to avoid flicker
    _lastOnlineState = _controller.isOnline;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      //  getCurrentUserLocation(
      //   defaultLocation: const LatLng(0.0, 0.0),
      //   cached: true,
      // ).then((loc) => _controller.setUserLocation(loc));
      await _initLocationSafely();

      await _controller.init();

      // Ensure local state is in sync with potentially updated controller status
      _lastOnlineState = _controller.isOnline;
      _controller.addListener(_onControllerChange);
      _lastDriverProfileRefreshSeq = FFAppState().driverProfileRefreshSeq;
      FFAppState().addListener(_onFfAppStateDriverProfileRefresh);
      // Now safe to start animations — _controller is initialized
      _pulseController.repeat();
      _syncFloatingBubble();
      _handlePendingRideFromNotification();
      await _maybeShowPostLoginScreens();
      await _applyKycEntryRouting();
    });
  }

  /// After profile load: Strict routing based on the 4-step logic
  Future<void> _applyKycEntryRouting() async {
    if (!mounted) return;
    final c = _controller;
    if (!c.isDataLoaded || !c.kycDocStatusFromApi) return;

    // ✅ If the driver is already approved, skip all routing — go straight to offline dashboard.
    if (c.isVerificationApproved) {
      // Only show inactive dialog if needed
      if (!c.isAccountActive && !_sessionKycGateDialogShown) {
        _sessionKycGateDialogShown = true;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Account Inactive'),
            content: const Text('Your account has been verified but is currently inactive. Please contact support to activate your profile and start earning.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(FFLocalizations.of(context).getText('drv_ok')),
              )
            ],
          ),
        );
      }
      return;
    }

    // 1. "all_uploaded": false -> Route to Documents Screen
    if (!c.allDocumentsUploaded) {
      context.pushNamed(DocumentsScreen.routeName);
      return;
    }

    // 2. "all_uploaded": true but NOT approved -> Show waiting/rejected dialog
    if (!c.isVerificationApproved && !_sessionKycGateDialogShown) {
      _sessionKycGateDialogShown = true;
      await c.promptKycStatusDialog();
      return;
    }
  }

  Future<void> _initLocationSafely() async {
    try {
      // Only CHECK permissions — never request them silently on app startup.
      // Permission requests happen in goOnline() when the driver intends to go online.
      final LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Not granted yet — the driver will be prompted when they try to go online.
        return;
      }

      // Permission already granted — get current position silently.
      FFAppState().locationPermissionAsked = true;
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 8));

      _controller.setUserLocation(
        LatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      debugPrint('UGO_HOME: Location init failed (non-fatal): $e');
    }
  }

  Set<Circle> _mergedCircles() {
    return {
      ..._statusCircles,
      ..._rippleCircles,
      if (_routeDotCircle != null) _routeDotCircle!,
    };
  }

  void _flushCircleUpdates() {
    _circleFlushTimer?.cancel();
    _circleFlushTimer = null;
    if (!mounted) return;
    _lastCircleFlushTime = DateTime.now();
    _mapKey.currentState?.updateCircles(_mergedCircles());
  }

  void _scheduleCircleUpdates({bool immediate = false}) {
    if (!mounted) return;
    final now = DateTime.now();
    final lastFlush = _lastCircleFlushTime;

    if (immediate ||
        lastFlush == null ||
        now.difference(lastFlush) >= _circleFlushInterval) {
      _flushCircleUpdates();
      return;
    }

    if (_circleFlushTimer?.isActive ?? false) return;

    final remaining = _circleFlushInterval - now.difference(lastFlush);
    _circleFlushTimer = Timer(remaining, _flushCircleUpdates);
  }

  Future<void> _handleBubbleMethod(MethodCall call) async {
    if (call.method != 'rideAction') return;
    final args = call.arguments;
    if (args is! Map) return;
    await _processRideActionPayload(Map<String, dynamic>.from(args));
  }

  Future<void> _consumePendingRideAction() async {
    final payload = await FloatingBubbleService.consumePendingRideAction();
    if (payload == null) return;
    await _processRideActionPayload(payload);
  }

  Future<void> _processRideActionPayload(Map<String, dynamic> args) async {
    final action = args['action']?.toString() ?? '';
    final rideIdRaw = args['rideId'];
    final rideId = rideIdRaw is int
        ? rideIdRaw
        : int.tryParse(rideIdRaw?.toString() ?? '');
    if (rideId == null || rideId <= 0) {
      await FloatingBubbleService.clearPendingRideAction();
      return;
    }
    if (action != 'accept' && action != 'decline') {
      await FloatingBubbleService.clearPendingRideAction();
      return;
    }

    final dedupeKey = '${action}_$rideId';
    final now = DateTime.now();
    if (_rideActionDedupeKey == dedupeKey &&
        _rideActionDedupeAt != null &&
        now.difference(_rideActionDedupeAt!) < const Duration(seconds: 10)) {
      await FloatingBubbleService.clearPendingRideAction();
      return;
    }
    _rideActionDedupeKey = dedupeKey;
    _rideActionDedupeAt = now;

    if (action == 'decline') {
      FFAppState().rememberSessionDeclinedRide(rideId);
    }

    final isBackground = args['backgroundAction'] == true;
    if (isBackground) {
      // Immediately push back to background to keep the driver's current app visible.
      FloatingBubbleService.moveTaskToBack();
    }

    try {
      if (action == 'accept') {
        await _overlayKey.currentState?.acceptRideFromBubble(rideId);
      } else {
        final overlay = _overlayKey.currentState;
        if (overlay != null) {
          await overlay.declineRideFromBubble(rideId);
        } else {
          FFAppState().rememberSessionDeclinedRide(rideId);
          final token = FFAppState().accessToken;
          final driverId = FFAppState().driverid;
          if (token.isNotEmpty && driverId > 0) {
            try {
              await RejectRideCall.call(
                token: token,
                rideId: rideId,
                driverId: driverId,
              );
            } catch (_) {}
          }
        }
      }
      await FloatingBubbleService.hideRideRequest();
      if (action == 'decline') {
        await FloatingBubbleService.moveTaskToBack();
      }
    } finally {
      await FloatingBubbleService.clearPendingRideAction();
    }
  }

  void _onFfAppStateDriverProfileRefresh() {
    if (!mounted) return;
    final seq = FFAppState().driverProfileRefreshSeq;
    if (seq == _lastDriverProfileRefreshSeq) return;
    _lastDriverProfileRefreshSeq = seq;
    unawaited(_controller.refreshDriverProfile());
  }

  void _onControllerChange() {
    if (!mounted) return;
    final c = _controller;
    if (c.isVerificationApproved) {
      _sessionKycGateDialogShown = false;
    }

    // Auto-center map when going online
    if (c.isOnline && !_lastOnlineState) {
      if (c.currentUserLocation != null) {
        _model.googleMapsController.future.then((ctrl) {
          ctrl.animateCamera(CameraUpdate.newLatLngZoom(
              c.currentUserLocation!.toGoogleMaps(), 16.0));
        });
      }
      _checkAndRequestOverlayPermission();
    }

    if (!_controller.isOnline && _lastOnlineState) {
      _lastOnlineState = _controller.isOnline;
      _lastBubbleSyncKey = null;
      _hideFloatingBubble();
      _syncFloatingBubble(force: true);
      return;
    }

    if (_controller.isOnline != _lastOnlineState) {
      _lastOnlineState = _controller.isOnline;
    }

    // Continuously update map center to driver's location if no ride is actively being handled
    // and if we have a valid location. This gives the Uber-like continuous tracking effect
    // but we throttle updates by time + distance to avoid lag.
    if (_controller.isOnline && _controller.currentUserLocation != null) {
      final now = DateTime.now();
      final currentLoc = _controller.currentUserLocation!;

      // Throttle: at most once every 400ms
      if (_lastCameraMoveTime != null &&
          now.difference(_lastCameraMoveTime!) <
              const Duration(milliseconds: 400)) {
        // Too soon since last move; skip this update.
      } else {
        // Throttle also by distance: only move if we shifted > ~10m.
        final lastCenter = _lastCameraCenter;
        final movedFarEnough = lastCenter == null ||
            Geolocator.distanceBetween(
              lastCenter.latitude,
              lastCenter.longitude,
              currentLoc.latitude,
              currentLoc.longitude,
            ) >
                10.0;

        if (movedFarEnough) {
          _lastCameraMoveTime = now;
          _lastCameraCenter = currentLoc;

          _model.googleMapsController.future.then((ctrl) {
            // Only safely update camera if we haven't actively locked it to a pickup/drop point
            if (_controller.currentRideStatus.toUpperCase() == 'IDLE' ||
                _controller.currentRideStatus.toUpperCase() == 'SEARCHING') {
              ctrl.animateCamera(
                CameraUpdate.newCameraPosition(CameraPosition(
                  target: currentLoc.toGoogleMaps(),
                  bearing: _controller.driverHeading,
                  tilt: 45.0,
                  zoom: 17.5,
                )),
              );
            }
          });
        }
      }
    }

    setState(() {});
    _syncFloatingBubble();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Avoid calling MethodChannel/plugins during detach where FlutterJNI may
    // already be gone (prevents background-resume blank screens / plugin NPEs).
    if (state == AppLifecycleState.detached) return;
    _syncFloatingBubble(force: true);
    if (state == AppLifecycleState.resumed) {
      _controller.onAppResumed();
    }
  }

  Future<void> _syncFloatingBubble({bool force = false}) async {
    if (!mounted) return;
    if (kIsWeb || !Platform.isAndroid) return;

    final appState = WidgetsBinding.instance.lifecycleState;
    final inForeground =
        appState == null || appState == AppLifecycleState.resumed;

    final syncKey = '${_controller.isOnline}_$inForeground';
    if (!force && _lastBubbleSyncKey == syncKey) {
      return;
    }
    _lastBubbleSyncKey = syncKey;

    if (_controller.isOnline) {
      final granted = await FloatingBubbleService.checkOverlayPermission();
      if (granted) {
        await RideNotificationService().hideOnlineNotification();
        final running = await FloatingBubbleService.isBubbleServiceRunning();
        if (!running) {
          await FloatingBubbleService.startFloatingBubble(
            overlaySuppressedInitially: inForeground,
          );
        }
        await FloatingBubbleService.setBubbleOverlaySuppressed(inForeground);
        _bubbleVisible = true;
      } else {
        if (await FloatingBubbleService.isBubbleServiceRunning()) {
          await FloatingBubbleService.stopFloatingBubble();
        }
        _bubbleVisible = false;
        await RideNotificationService().showOnlineNotification();
      }
    } else {
      await RideNotificationService().hideOnlineNotification();
      if (await FloatingBubbleService.isBubbleServiceRunning()) {
        await FloatingBubbleService.stopFloatingBubble();
      }
      _bubbleVisible = false;
    }
  }

  Future<void> _checkAndRequestOverlayPermission() async {
    if (!mounted) return;
    // Only nag once per app session. If the driver already dismissed the dialog
    // (granted or denied), we respect their choice until the next app launch.
    if (_controller.hasPromptedOverlayThisSession) return;
    _controller.hasPromptedOverlayThisSession = true;

    final granted = await FloatingBubbleService.checkOverlayPermission();
    if (!granted && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Overlay Permission Required'),
          content: const Text(
            'The Captain Bubble needs permission to display over other apps so you can see ride requests while using navigation or other apps.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      );

      if (proceed == true) {
        await FloatingBubbleService.requestOverlayPermission();
      }
    }
  }

  Future<void> _hideFloatingBubble() async {
    if (!_bubbleVisible) return;
    await FloatingBubbleService.stopFloatingBubble();
    _bubbleVisible = false;
  }

  Future<void> _maybeShowPostLoginScreens() async {
    if (!mounted) return;
    if (FFAppState().hasSeenPostLoginScreens) return;

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PreLoginGoogleMapsScreen(
          onAgree: () => Navigator.of(context).pop(),
        ),
      ),
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PostLoginTermsDialog(
        onGotIt: () {
          FFAppState().hasSeenPostLoginScreens = true;
        },
      ),
    );
    if (mounted) FFAppState().hasSeenPostLoginScreens = true;
  }

  void _handlePendingRideFromNotification() {
    final rideId = FFAppState().pendingRideIdFromNotification;
    if (rideId <= 0 || !mounted) return;
    FFAppState().pendingRideIdFromNotification = 0;
    RideNotificationService().cancelRideNotification();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.handlePendingRideFromNotification(rideId);
    });
  }

  void _passDataToOverlay(dynamic data, {int attempt = 0}) {
    if (!mounted) return;
    // Overlay may not be attached for a few frames after login / route swap.
    // Dropping socket events here made the map look "dead" until restart.
    if (_overlayKey.currentState == null) {
      if (attempt >= 12) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _passDataToOverlay(data, attempt: attempt + 1);
      });
      return;
    }

    Map<String, dynamic>? unwrap(dynamic d) {
      if (d is Map<String, dynamic>) {
        if (d.containsKey('ride_status') && d.containsKey('id')) return d;
        if (d['data'] is Map) return d['data'] as Map<String, dynamic>;
        if (d['ride'] is Map) return d['ride'] as Map<String, dynamic>;
      }
      return null;
    }

    void process(Map<String, dynamic> rideData) {
      final status =
      (rideData['ride_status'] ?? 'SEARCHING').toString().toUpperCase();

      // ✅ Driver gets rides only when online
      if (status == 'SEARCHING' && !_controller.isOnline) return;

      void clearMap() {
        _mapKey.currentState?.updateMarkers(<FlutterFlowMarker>[]);
        _statusCircles = {};
        _routePoints = [];
        _routeDotCircle = null;
        _routeAnimController.stop();
        _scheduleCircleUpdates(immediate: true);
        _mapKey.currentState?.updatePolylines(<Polyline>{});
        _activeRouteKey = null;
      }

      if (status == 'CANCELLED' ||
          status == 'REJECTED' ||
          status == 'DECLINED' ||
          status == 'EXPIRED') {
        _controller.setRideStatus('IDLE');
        Provider.of<RideState>(context, listen: false).clearRide();
        final rideId = rideData['id'] != null
            ? (rideData['id'] is int
            ? rideData['id'] as int
            : int.tryParse(rideData['id'].toString()))
            : null;
        if (rideId != null) _overlayKey.currentState?.removeRideById(rideId);
        clearMap();
        return;
      }

      _controller.setRideStatus(status);
      Provider.of<RideState>(context, listen: false)
          .updateRide(RideRequest.fromJson(rideData));
      _overlayKey.currentState?.handleNewRide(rideData);

      if (status == 'SEARCHING') {
        clearMap();
        return;
      }

      try {
        final rr = RideRequest.fromJson(rideData);
        final hasPickup = rr.pickupLat != 0 && rr.pickupLng != 0;
        final hasDrop = rr.dropLat != 0 && rr.dropLng != 0;
        final isAccepted = status == 'ACCEPTED' || status == 'ARRIVED';
        final isStarted = status == 'STARTED' || status == 'ONTRIP';

        final markers = <FlutterFlowMarker>[];
        if (hasPickup && (isAccepted || isStarted)) {
          markers.add(FlutterFlowMarker(
            'pickup_${rr.id}',
            latlng.LatLng(rr.pickupLat, rr.pickupLng),
            null,
            GoogleMarkerColor.green,
          ));
        }
        // Show drop once ride is accepted so refresh / fit-bounds matches rider view.
        if (hasDrop && (isAccepted || isStarted)) {
          markers.add(FlutterFlowMarker(
            'drop_${rr.id}',
            latlng.LatLng(rr.dropLat, rr.dropLng),
            null,
            GoogleMarkerColor.red,
          ));
        }
        _mapKey.currentState?.updateMarkers(markers);

        // ✅ Highlight pickup/drop area like Rapido C
        // aptain (~350m radius circles)
        const radiusMeters = 351.0;
        final circles = <Circle>{};
        if (hasPickup && (isAccepted || isStarted)) {
          circles.add(Circle(
            circleId: CircleId('pickup_circle_${rr.id}'),
            center: latlng.LatLng(rr.pickupLat, rr.pickupLng).toGoogleMaps(),
            radius: radiusMeters,
            fillColor: AppColors.success.withValues(alpha: 0.2),
            strokeColor: AppColors.success,
            strokeWidth: 2,
          ));
        }
        if (hasDrop && (isAccepted || isStarted)) {
          circles.add(Circle(
            circleId: CircleId('drop_circle_${rr.id}'),
            center: latlng.LatLng(rr.dropLat, rr.dropLng).toGoogleMaps(),
            radius: radiusMeters,
            fillColor: AppColors.error.withValues(alpha: 0.2),
            strokeColor: AppColors.error,
            strokeWidth: 2,
          ));
        }
        _statusCircles = circles;
        _scheduleCircleUpdates(immediate: true);

        if (isAccepted || isStarted) {
          _updateRoutePolyline(rr: rr, status: status);
        } else {
          _mapKey.currentState?.updatePolylines(<Polyline>{});
          _activeRouteKey = null;
        }
      } catch (_) {}
    }

    if (data is List) {
      for (final ride in data) {
        final m = ride is Map<String, dynamic> ? ride : unwrap(ride);
        if (m != null) process(m);
      }
    } else {
      final m = unwrap(data);
      if (m != null) process(m);
    }
  }

  void _onRideComplete() {
    if (!mounted) return;
    _controller.onRideComplete();
    _mapKey.currentState?.updateMarkers(<FlutterFlowMarker>[]);
    _statusCircles = {};
    _routePoints = [];
    _routeDotCircle = null;
    _routeAnimController.stop();
    _scheduleCircleUpdates(immediate: true);
    _mapKey.currentState?.updatePolylines(<Polyline>{});
    _activeRouteKey = null;
  }

  Future<void> _centerMapOnCurrentLocation() async {
    final currentLoc = _controller.currentUserLocation;
    if (currentLoc == null) return;

    final ctrl = await _model.googleMapsController.future;
    if (!mounted) return;

    _lastCameraCenter = currentLoc;
    _lastCameraMoveTime = DateTime.now();
    await ctrl.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLoc.toGoogleMaps(),
          zoom: 16.0,
          tilt: 0.0,
          bearing: 0.0,
        ),
      ),
    );
    _model.googleMapsCenter = currentLoc;
  }

  bool _isValidMapCoord(double lat, double lng) {
    if (lat == 0 && lng == 0) return false;
    if (lat.abs() > 90 || lng.abs() > 180) return false;
    return true;
  }

  /// Matches UGO_USER `auto_book_widget.dart` `_fitMapToRideContext` status rules.
  static const double _kMinBoundsSpanDriver = 0.004;

  String _normalizedDriverRideStatus() =>
      _controller.currentRideStatus.trim().toUpperCase().replaceAll('_', '');

  bool _isPrePickupPhaseDriver(String n) {
    return n == 'ACCEPTED' ||
        n == 'ARRIVED' ||
        n == 'QRSCANNED' ||
        n == 'DRIVERASSIGNED' ||
        n == 'FETCHING';
  }

  bool _isOnTripPhaseDriver(String n) {
    return n == 'STARTED' ||
        n == 'ONTRIP' ||
        n == 'PICKEDUP' ||
        n == 'INPROGRESS';
  }

  Future<void> _driverAnimateCameraToBounds(
      List<gmf.LatLng> points,
      double paddingPx,
      ) async {
    final ctrl = await _model.googleMapsController.future;
    if (!mounted) return;

    final valid = points
        .where((p) => p.latitude.abs() > 1e-6 || p.longitude.abs() > 1e-6)
        .toList();
    if (valid.isEmpty) {
      await _centerMapOnCurrentLocation();
      return;
    }

    if (valid.length == 1) {
      _lastCameraCenter =
          latlng.LatLng(valid.first.latitude, valid.first.longitude);
      _lastCameraMoveTime = DateTime.now();
      await ctrl.animateCamera(
        gmf.CameraUpdate.newLatLngZoom(valid.first, 15.0),
      );
      _model.googleMapsCenter = _lastCameraCenter;
      return;
    }

    var minLat = valid.first.latitude;
    var maxLat = valid.first.latitude;
    var minLng = valid.first.longitude;
    var maxLng = valid.first.longitude;
    for (final point in valid) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    var latPad = (maxLat - minLat) * 0.15;
    var lngPad = (maxLng - minLng) * 0.15;
    if (maxLat - minLat < _kMinBoundsSpanDriver) {
      latPad = _kMinBoundsSpanDriver / 2;
      minLat -= latPad;
      maxLat += latPad;
    } else {
      minLat -= latPad;
      maxLat += latPad;
    }
    if (maxLng - minLng < _kMinBoundsSpanDriver) {
      lngPad = _kMinBoundsSpanDriver / 2;
      minLng -= lngPad;
      maxLng += lngPad;
    } else {
      minLng -= lngPad;
      maxLng += lngPad;
    }

    try {
      await ctrl.animateCamera(
        gmf.CameraUpdate.newLatLngBounds(
          gmf.LatLngBounds(
            southwest: gmf.LatLng(minLat, minLng),
            northeast: gmf.LatLng(maxLat, maxLng),
          ),
          paddingPx,
        ),
      );
    } catch (e) {
      debugPrint('UGO_HOME: camera bounds failed, zoom fallback: $e');
      await ctrl.animateCamera(
        gmf.CameraUpdate.newLatLngZoom(
          gmf.LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2),
          12.0,
        ),
      );
    }

    _lastCameraCenter = latlng.LatLng(
      (minLat + maxLat) / 2,
      (minLng + maxLng) / 2,
    );
    _lastCameraMoveTime = DateTime.now();
    _model.googleMapsCenter = _lastCameraCenter;
  }

  /// Same framing as UGO_USER `AutoBookWidget._fitMapToRideContext`.
  Future<void> _fitMapToRideContextLikeUser() async {
    if (!mounted) return;

    final ride = Provider.of<RideState>(context, listen: false).currentRide;
    final n = _normalizedDriverRideStatus();
    final pts = <gmf.LatLng>[];

    void addPickup() {
      if (ride == null) return;
      if (_isValidMapCoord(ride.pickupLat, ride.pickupLng)) {
        pts.add(gmf.LatLng(ride.pickupLat, ride.pickupLng));
      }
    }

    void addDrop() {
      if (ride == null) return;
      if (_isValidMapCoord(ride.dropLat, ride.dropLng)) {
        pts.add(gmf.LatLng(ride.dropLat, ride.dropLng));
      }
    }

    void addDriver() {
      final d = _controller.currentUserLocation;
      if (d != null) {
        pts.add(gmf.LatLng(d.latitude, d.longitude));
      }
    }

    if (n == 'SEARCHING' || n == 'IDLE') {
      addPickup();
      addDrop();
    } else if (_isPrePickupPhaseDriver(n)) {
      addDriver();
      addPickup();
    } else if (_isOnTripPhaseDriver(n)) {
      addPickup();
      addDrop();
      addDriver();
    } else {
      addPickup();
      addDrop();
      addDriver();
    }

    if (pts.isEmpty) {
      await _centerMapOnCurrentLocation();
      return;
    }

    final bottomInset = MediaQuery.sizeOf(context).height * 0.35;
    final paddingPx = 72.0 + bottomInset * 0.15;
    await _driverAnimateCameraToBounds(pts, paddingPx);
  }

  /// UGO_USER parity: refresh polyline then fit (or center when no active ride).
  Future<void> _onMapPrimaryActionLikeUser() async {
    if (!mounted) return;
    final ride = Provider.of<RideState>(context, listen: false).currentRide;
    if (ride != null) {
      try {
        await _updateRoutePolyline(
          rr: ride,
          status: _controller.currentRideStatus,
        );
      } catch (e) {
        debugPrint('UGO_HOME: map primary action polyline: $e');
      }
      if (mounted) await _fitMapToRideContextLikeUser();
      return;
    }
    await _centerMapOnCurrentLocation();
  }

  Future<void> _updateRoutePolyline({
    required RideRequest rr,
    required String status,
  }) async {
    final hasPickup = rr.pickupLat != 0 && rr.pickupLng != 0;
    final hasDrop = rr.dropLat != 0 && rr.dropLng != 0;
    final isAccepted = status == 'ACCEPTED' || status == 'ARRIVED';
    final isStarted = status == 'STARTED' || status == 'ONTRIP';

    if ((!isAccepted && !isStarted) || !hasPickup || (isStarted && !hasDrop)) {
      _routeAnimController.stop();
      _routePoints = [];
      _routeDotCircle = null;
      _scheduleCircleUpdates(immediate: true);
      _mapKey.currentState?.updatePolylines(<Polyline>{});
      _activeRouteKey = null;
      return;
    }

    final origin = isAccepted
        ? _controller.currentUserLocation
        : latlng.LatLng(rr.pickupLat, rr.pickupLng);
    final destination = isAccepted
        ? latlng.LatLng(rr.pickupLat, rr.pickupLng)
        : latlng.LatLng(rr.dropLat, rr.dropLng);

    if (origin == null) {
      _mapKey.currentState?.updatePolylines(<Polyline>{});
      _activeRouteKey = null;
      return;
    }

    final routeKey = '${rr.id}_${status}_'
        '${origin.latitude.toStringAsFixed(4)}_${origin.longitude.toStringAsFixed(4)}_'
        '${destination.latitude.toStringAsFixed(4)}_${destination.longitude.toStringAsFixed(4)}';

    if (_activeRouteKey == routeKey && _routePoints.isNotEmpty) return;

    _activeRouteKey = routeKey;

    final points = await RoutePolylineService().getRoutePoints(
      originLat: origin.latitude,
      originLng: origin.longitude,
      destLat: destination.latitude,
      destLng: destination.longitude,
    );

    if (!mounted || _activeRouteKey != routeKey) return;

    if (points == null || points.isEmpty) {
      _routeAnimController.stop();
      _mapKey.currentState?.updatePolylines(<Polyline>{});
      _routePoints = [];
      _routeDotCircle = null;
      _scheduleCircleUpdates(immediate: true);
      return;
    }

    // Store route points for the animated dot
    _routePoints = points.toList(); // List<latlng.LatLng>

    final googlePoints = points.map((p) => p.toGoogleMaps()).toList();
    final polylineId = isAccepted
        ? 'route_driver_pickup_${rr.id}'
        : 'route_pickup_drop_${rr.id}';

    // White outline layer (drawn underneath)
    final outlinePolyline = Polyline(
      polylineId: PolylineId('${polylineId}_outline'),
      color: Colors.white,
      width: 14,
      points: googlePoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 0,
    );
    // Orange route layer on top
    final routePolyline = Polyline(
      polylineId: PolylineId(polylineId),
      color: AppColors.primary,
      width: 8,
      points: googlePoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 1,
    );
    _mapKey.currentState?.updatePolylines({outlinePolyline, routePolyline});
    // Restart the dot animation from 0
    _routeAnimController.forward(from: 0.0);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return FFLocalizations.of(context).getText('drv_good_morning');
    }
    if (hour < 17) {
      return FFLocalizations.of(context).getText('drv_good_afternoon');
    }
    return FFLocalizations.of(context).getText('drv_good_evening');
  }

  void _updateRipple() {
    final loc = _controller.currentUserLocation;
    if (!mounted || loc == null || !_controller.isOnline) {
      if (_rippleCircles.isNotEmpty) {
        _rippleCircles = {};
        _scheduleCircleUpdates(immediate: true);
      }
      return;
    }
    final radius =
        _pulseAnim.value * 80.0; // Starts at 0 (icon center) and grows to 80m
    final opacity = 1.0 - _pulseAnim.value; // Fades out as it expands

    // Inner icon-sized solid circle — pulses in opposite phase (breathes)
    final innerRadius =
        12.0 + (_pulseAnim.value * 6.0); // 12m → 18m (subtle breathing)
    final innerOpacity = 0.8 - (_pulseAnim.value * 0.5); // Stays mostly visible

    _rippleCircles = {
      // Outer expanding ring
      Circle(
        circleId: const CircleId('driver_pulse_outer'),
        center: loc.toGoogleMaps(),
        radius: radius,
        fillColor: Colors.orange.withValues(alpha: opacity * 0.2),
        strokeColor: Colors.orange.withValues(alpha: opacity * 0.8),
        strokeWidth: 2,
      ),
      // Inner solid icon-sized dot that also pulses
      Circle(
        circleId: const CircleId('driver_pulse_inner'),
        center: loc.toGoogleMaps(),
        radius: innerRadius,
        fillColor: Colors.orange.withValues(alpha: innerOpacity * 0.6),
        strokeColor: Colors.orange.withValues(alpha: innerOpacity),
        strokeWidth: 3,
      ),
    };
    _scheduleCircleUpdates();
  }

  void _updateRouteDot() {
    if (!mounted || _routePoints.length < 2) {
      if (_routeDotCircle != null) {
        _routeDotCircle = null;
        _scheduleCircleUpdates(immediate: true);
      }
      return;
    }
    final t = _routeAnimController.value; // 0.0 → 1.0
    final totalSegments = _routePoints.length - 1;
    final scaledT = t * totalSegments;
    final segmentIndex = scaledT.floor().clamp(0, totalSegments - 1);
    final segmentT = scaledT - segmentIndex;
    final from = _routePoints[segmentIndex];
    final to = _routePoints[segmentIndex + 1];
    final lat = from.latitude + (to.latitude - from.latitude) * segmentT;
    final lng = from.longitude + (to.longitude - from.longitude) * segmentT;
    _routeDotCircle = Circle(
      circleId: const CircleId('route_dot'),
      center: latlng.LatLng(lat, lng).toGoogleMaps(),
      radius: 8.0,
      fillColor: Colors.white,
      strokeColor: AppColors.primary,
      strokeWidth: 3,
      zIndex: 10,
    );
    _scheduleCircleUpdates();
  }

  @override
  void dispose() {
    _circleFlushTimer?.cancel();
    _pulseController.dispose();
    _routeAnimController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _bubbleChannel.setMethodCallHandler(null);
    FFAppState().removeListener(_onFfAppStateDriverProfileRefresh);
    _controller.removeListener(_onControllerChange);
    try {
      FloatingBubbleService.stopFloatingBubble();
    } catch (_) {}
    _bubbleVisible = false;
    _model.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isSmallScreen = Responsive.isSmallPhone(context);
        final c = _controller;
        final isOnline = c.isOnline;

        // Ensure "Account Inactive" logic perfectly follows the 4-step strict pipeline
        final accountInactive = c.allDocumentsUploaded && c.isVerificationApproved && !c.isAccountActive;

        final canShowInteractiveToggle =
            !accountInactive; // Always show the ON/OFF toggle unless account is inactive.
            // (toggle will be greyed/disabled while !isDataLoaded via OnlineToggle's canInteract)
        final isRideLocked = c.isActiveRideBlockingOffline;
        // Only hide panels while a ride is actively running.
        final shouldShowPanels = !c.isActiveRideBlockingOffline;
        final hasIncomingRequest =
            c.currentRideStatus.trim().toUpperCase() == 'SEARCHING';
        final showIncentivePanel =
            shouldShowPanels &&
                !_suppressIncentiveForPostRide &&
                !hasIncomingRequest;
        final showSummaryPanel =
            shouldShowPanels &&
                !_suppressIncentiveForPostRide &&
                !hasIncomingRequest;
        // Use fallback location when unavailable - avoid blocking home screen
        final userLocation = c.currentUserLocation ??
            const LatLng(17.3850, 78.4867); // Default: Hyderabad

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              final now = DateTime.now();
              if (_lastBackPressed == null ||
                  now.difference(_lastBackPressed!) >
                      const Duration(seconds: 2)) {
                _lastBackPressed = now;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      FFLocalizations.of(context).getText('drv_back_exit')),
                  duration: const Duration(seconds: 2),
                ));
              } else {
                // "Uber-like" back: background the task without finishing the Activity.
                // We trigger a native method via our existing MethodChannel so this
                // works even if 3rd party plugins are not registered.
                try {
                  await _bubbleChannel.invokeMethod('moveTaskToBack');
                } catch (_) {}
              }
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              drawer: isRideLocked
                  ? null
                  : const Drawer(elevation: 16.0, child: MenuWidget()),
              body: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AppHeader(
                      scaffoldKey: scaffoldKey,
                      switchValue: accountInactive ? false : c.isOnline,
                      isDataLoaded: c.isDataLoaded,
                      onToggleOnline: () => c.toggleOnlineStatus(),
                      showOnlineToggle: canShowInteractiveToggle,
                      accountInactive: accountInactive,
                      isRideLocked: isRideLocked,
                      preventGoingOffline:
                      c.isActiveRideBlockingOffline && isOnline,
                      screenWidth: screenWidth,
                      isSmallScreen: isSmallScreen,
                      notificationCount: c.notificationUnreadCount,
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          // Map kept mounted when offline (hidden) to avoid GlobalKey/Completer
                          // reuse issues when toggling online; markers/polylines need _mapKey.
                          Opacity(
                            opacity: isOnline ? 1.0 : 0.0,
                            child: IgnorePointer(
                              ignoring: !isOnline,
                              child: RideMapContainer(
                                mapKey: _mapKey,
                                controller: _model.googleMapsController,
                                initialLocation:
                                c.currentUserLocation ?? userLocation,
                                onCameraIdle: (latLng) =>
                                _model.googleMapsCenter = latLng,
                                mapCenter: c.currentUserLocation,
                                availableDriversCount: c.availableDriversCount,
                                showDriversPanel: shouldShowPanels,
                                onMapPrimaryAction: _onMapPrimaryActionLikeUser,
                                // Inject custom driver marker
                                markers: (c.currentUserLocation != null &&
                                    isOnline)
                                    ? [
                                  FlutterFlowMarker(
                                      'driver_current_location',
                                      c.currentUserLocation!,
                                      null,
                                      null,
                                      null, // image
                                      const MarkerIcon(
                                        icon: Icons.navigation,
                                        color: Colors.white,
                                        backgroundColor: Colors.orange,
                                        borderColor: Colors.white,
                                        size: 20.0,
                                      ))
                                ]
                                    : [],
                              ),
                            ),
                          ),
                          if (!isOnline)
                            OfflineDashboard(
                              driverName: c.driverName,
                              greeting: _getGreeting(),
                              isDataLoaded: c.isDataLoaded,
                              verificationStatus: c.verificationStatus,
                              rejectionReason: c.verificationRejectionReason,
                              canGoOnline: c.canGoOnline,
                              accountInactive: accountInactive,
                              documentsIncomplete: c.kycDocStatusFromApi &&
                                  !c.allDocumentsUploaded,
                              onGoOnline: () => c.toggleOnlineStatus(),
                              onOpenDocuments: () async {
                                await Navigator.push<void>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DocumentsScreen(),
                                  ),
                                );
                                if (!mounted) return;
                                await _controller.refreshDriverProfile();
                                if (!mounted) return;
                                if (_controller.kycDocStatusFromApi &&
                                    !_controller.allDocumentsUploaded) {
                                  context.goNamed(DocumentsScreen.routeName);
                                }
                              },
                            ),
                          BottomRidePanel(
                            overlayKey: _overlayKey,
                            onRideComplete: _onRideComplete,
                            onGhostRideCleared: _onRideComplete,
                            driverLocation:
                            c.currentUserLocation ?? userLocation,
                            onPostRideIncentiveSuppress: (suppress) {
                              if (!mounted) return;
                              setState(() =>
                              _suppressIncentiveForPostRide = suppress);
                            },
                          ),
                          if (showSummaryPanel)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(18),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: SafeArea(
                                  top: false,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      8,
                                      12,
                                      10,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (showIncentivePanel)
                                          IncentivePanel(
                                            isExpanded:
                                            _isIncentivePanelExpanded,
                                            isLoadingIncentives:
                                            c.isLoadingIncentives,
                                            incentiveTiers: c.incentiveTiers,
                                            totalIncentiveEarned:
                                            c.totalIncentiveEarned,
                                            potentialBonusTotal:
                                            c.incentivePotentialBonus,
                                            onTap: () => setState(() =>
                                            _isIncentivePanelExpanded =
                                            !_isIncentivePanelExpanded),
                                            screenWidth: screenWidth,
                                            isSmallScreen: isSmallScreen,
                                          ),
                                        EarningsSummary(
                                          todayTotal: c.todayTotal,
                                          teamEarnings: c.todayWallet,
                                          ridesToday: c.todayRideCount,
                                          lastRideEarnings: c.lastRideAmount,
                                          isLoading: c.isLoadingEarnings,
                                          isSmallScreen: isSmallScreen,
                                          onRideCountTap: () =>
                                              context.pushNamed(
                                                  HistoryWidget.routeName),
                                          onWalletTap: () => context.pushNamed(
                                              WalletWidget.routeName),
                                          onLastRideTap: () =>
                                              context.pushNamed(
                                                  LastOrderWidget.routeName),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Version Update Logic ──────────────────────────────────

  Future<void> _checkVersionUpdate() async {
    // 1. Check for Play Store In-App Updates (OTA)
    final remoteConfig = FirebaseRemoteConfigService();
    await remoteConfig.ensureInitialized();
    final isMandatory =
    remoteConfig.getBool('is_update_mandatory', defaultValue: false);

    // Complete any previously downloaded flexible update first.
    await InAppUpdateService().checkRemainingUpdate();

    // Try native API first (for true OTA experience)
    await InAppUpdateService().checkForUpdate(forceImmediate: isMandatory);

    // 2. Fallback: Check Remote Config versions manually
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final String latestVersion = remoteConfig.latestAppVersion;
      final String minRequiredVersion = remoteConfig.minRequiredVersion;

      debugPrint(
          'UGO_UPDATE: Current=$currentVersion, Latest=$latestVersion, Min=$minRequiredVersion');

      // Mandatory Update (Blocker)
      if (_isVersionLower(currentVersion, minRequiredVersion)) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UpdateDialog(
            latestVersion: latestVersion,
            isMandatory: true,
          ),
        );
        return;
      }

      // Optional Update (Dismissible)
      if (_isVersionLower(currentVersion, latestVersion)) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => UpdateDialog(
            latestVersion: latestVersion,
            isMandatory: false,
          ),
        );
      }
    } catch (e) {
      debugPrint('UGO_UPDATE_ERROR: Manual version check failed: $e');
    }
  }

  bool _isVersionLower(String current, String target) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final targetParts = target.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        final c = i < currentParts.length ? currentParts[i] : 0;
        final t = i < targetParts.length ? targetParts[i] : 0;
        if (c < t) return true;
        if (c > t) return false;
      }
    } catch (e) {
      debugPrint('UGO_VERSION_PARSE_ERROR: $e');
    }
    return false;
  }
}