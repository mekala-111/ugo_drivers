import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '/components/menu_widget.dart';
import '/controllers/home_controller.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
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

import '../flutter_flow/lat_lng.dart' as latlng;

export 'home_model.dart';

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
  DateTime? _lastBackPressed;
  String? _activeRouteKey;
  bool _bubbleVisible = false;
  bool _lastOnlineState = false;
  DateTime? _lastCameraMoveTime;
  latlng.LatLng? _lastCameraCenter;
  DateTime? _lastCircleFlushTime;
  Timer? _circleFlushTimer;

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

    // Setup pulsating ripple animation (don't start yet — _controller not ready)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pulseAnim =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
    _pulseController.addListener(_updateRipple);

    // Route animated dot (don't start yet)
    _routeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _routeAnimController.addListener(_updateRouteDot);

    _controller = HomeController(
      onShowKycDialog: () async {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
                FFLocalizations.of(context).getText('drv_kyc_not_approved')),
            content: Text(FFLocalizations.of(context)
                .getText('drv_kyc_complete')
                .replaceAll('%1', FFAppState().kycStatus)),
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

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      //  getCurrentUserLocation(
      //   defaultLocation: const LatLng(0.0, 0.0),
      //   cached: true,
      // ).then((loc) => _controller.setUserLocation(loc));
      await _initLocationSafely();

      await _controller.init();
      _lastOnlineState = _controller.isOnline;
      _controller.addListener(_onControllerChange);
      // Now safe to start animations — _controller is initialized
      _pulseController.repeat();
      _syncFloatingBubble();
      _handlePendingRideFromNotification();
      _maybeShowPostLoginScreens();
    });
  }

  Future<void> _initLocationSafely() async {
    // Check if already asked
    if (FFAppState().locationPermissionAsked == true) {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _controller.setUserLocation(
        LatLng(position.latitude, position.longitude),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      FFAppState().locationPermissionAsked = true;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _controller.setUserLocation(
        LatLng(position.latitude, position.longitude),
      );
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
    final action = args['action']?.toString() ?? '';
    final rideIdRaw = args['rideId'];
    final rideId = rideIdRaw is int
        ? rideIdRaw
        : int.tryParse(rideIdRaw?.toString() ?? '');
    if (rideId == null || rideId <= 0) return;
    if (action == 'accept') {
      await _overlayKey.currentState?.acceptRideFromBubble(rideId);
    } else if (action == 'decline') {
      await _overlayKey.currentState?.declineRideFromBubble(rideId);
    }
    await FloatingBubbleService.hideRideRequest();
  }

  void _onControllerChange() {
    if (!mounted) return;

    // Auto-center map when going online
    if (_controller.isOnline && !_lastOnlineState) {
      if (_controller.currentUserLocation != null) {
        _model.googleMapsController.future.then((ctrl) {
          ctrl.animateCamera(CameraUpdate.newLatLngZoom(
              _controller.currentUserLocation!.toGoogleMaps(), 16.0));
        });
      }
      _checkAndRequestOverlayPermission();
    }

    if (!_controller.isOnline && _lastOnlineState) {
      _lastOnlineState = _controller.isOnline;
      _hideFloatingBubble();
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
    _syncFloatingBubble();
  }

  Future<void> _syncFloatingBubble() async {
    if (!mounted) return;

    final appState = WidgetsBinding.instance.lifecycleState;
    // Show bubble ONLY when (Online AND app is NOT in foreground)
    // We check if appState is null (initial state) or not resumed.
    // Usually, if it's null it means we are just starting, likely resumed soon.
    final shouldShowBubble = _controller.isOnline &&
        (appState != null && appState != AppLifecycleState.resumed);

    if (shouldShowBubble) {
      final granted = await FloatingBubbleService.checkOverlayPermission();
      if (granted) {
        if (!_bubbleVisible) {
          await FloatingBubbleService.startFloatingBubble();
          _bubbleVisible = true;
        }
      } else {
        if (_bubbleVisible) {
          await FloatingBubbleService.stopFloatingBubble();
          _bubbleVisible = false;
        }
      }
    } else {
      if (_bubbleVisible) {
        await FloatingBubbleService.stopFloatingBubble();
        _bubbleVisible = false;
      }
    }
  }

  Future<void> _checkAndRequestOverlayPermission() async {
    if (!mounted) return;
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

  void _passDataToOverlay(dynamic data) {
    if (!mounted) return;
    if (_overlayKey.currentState == null) return;

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
          status == 'DECLINED') {
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
      _overlayKey.currentState!.handleNewRide(rideData);

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
        if (hasDrop && isStarted) {
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
        if (hasDrop && isStarted) {
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
    _controller.removeListener(_onControllerChange);
    _hideFloatingBubble();
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
        final shouldShowPanels = ![
          'ACCEPTED',
          'ARRIVED',
          'STARTED',
          'ONTRIP',
          'COMPLETED',
          'FETCHING'
        ].contains(c.currentRideStatus.toUpperCase());
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
                SystemNavigator.pop();
              }
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              drawer: const Drawer(elevation: 16.0, child: MenuWidget()),
              body: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AppHeader(
                      scaffoldKey: scaffoldKey,
                      switchValue: c.isOnline,
                      isDataLoaded: c.isDataLoaded,
                      onToggleOnline: () => c.toggleOnlineStatus(),
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
                                showCaptainsPanel: shouldShowPanels,
                                onCenterCurrentLocation:
                                    c.currentUserLocation != null
                                        ? _centerMapOnCurrentLocation
                                        : null,
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
                              onGoOnline: () => c.toggleOnlineStatus(),
                            ),
                          BottomRidePanel(
                            overlayKey: _overlayKey,
                            onRideComplete: _onRideComplete,
                            driverLocation:
                                c.currentUserLocation ?? userLocation,
                          ),
                        ],
                      ),
                    ),
                    if (shouldShowPanels)
                      IncentivePanel(
                        isExpanded: _isIncentivePanelExpanded,
                        isLoadingIncentives: c.isLoadingIncentives,
                        incentiveTiers: c.incentiveTiers,
                        currentRides: c.currentRides,
                        totalIncentiveEarned: c.totalIncentiveEarned,
                        onTap: () => setState(() => _isIncentivePanelExpanded =
                            !_isIncentivePanelExpanded),
                        screenWidth: screenWidth,
                        isSmallScreen: isSmallScreen,
                      ),
                    if (shouldShowPanels)
                      EarningsSummary(
                        todayTotal: c.todayTotal,
                        teamEarnings: c.todayWallet,
                        ridesToday: c.todayRideCount,
                        lastRideEarnings: c.lastRideAmount,
                        isLoading: c.isLoadingEarnings,
                        isSmallScreen: isSmallScreen,
                        onRideCountTap: () =>
                            context.pushNamed(HistoryWidget.routeName),
                        onWalletTap: () =>
                            context.pushNamed(WalletWidget.routeName),
                        onLastRideTap: () =>
                            context.pushNamed(LastOrderWidget.routeName),
                      ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.018),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
