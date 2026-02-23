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
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late HomeModel _model;
  late HomeController _controller;

  final GlobalKey<RideRequestOverlayState> _overlayKey = GlobalKey<RideRequestOverlayState>();
  final GlobalKey<FlutterFlowGoogleMapState> _mapKey = GlobalKey<FlutterFlowGoogleMapState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isIncentivePanelExpanded = false;
  DateTime? _lastBackPressed;
  String? _activeRouteKey;
  bool _bubbleVisible = false;
  bool _lastOnlineState = false;
  final MethodChannel _bubbleChannel =
      const MethodChannel('com.ugotaxi_rajkumar.driver/floating_bubble');

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());
    WidgetsBinding.instance.addObserver(this);
    _bubbleChannel.setMethodCallHandler(_handleBubbleMethod);

    _controller = HomeController(
      onShowKycDialog: () async {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(FFLocalizations.of(context).getText('drv_kyc_not_approved')),
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
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Agree'),
              ),
            ],
          ),
        );
        return result ?? false;
      },
      onShowPermissionDialog: () async {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(FFLocalizations.of(context).getText('drv_location_needed'),
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
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(FFLocalizations.of(context).getText('drv_open_settings')),
              ),
            ],
          ),
        );
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
      getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0), cached: true)
          .then((loc) => _controller.setUserLocation(loc));

      await _controller.init();
      _lastOnlineState = _controller.isOnline;
      _controller.addListener(_onControllerChange);
      _syncFloatingBubble();
      _handlePendingRideFromNotification();
    });
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
    if (!_controller.isOnline && _lastOnlineState) {
      _lastOnlineState = _controller.isOnline;
      _hideFloatingBubble();
      return;
    }
    if (_controller.isOnline != _lastOnlineState) {
      _lastOnlineState = _controller.isOnline;
    }
    _syncFloatingBubble();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _syncFloatingBubble();
  }

  Future<void> _syncFloatingBubble() async {
    if (!mounted) return;
    // Floating bubble disabled - always hide
    await _hideFloatingBubble();
  }

  Future<void> _hideFloatingBubble() async {
    if (!_bubbleVisible) return;
    await FloatingBubbleService.stopFloatingBubble();
    _bubbleVisible = false;
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
      final status = (rideData['ride_status'] ?? 'SEARCHING').toString().toUpperCase();

      // ✅ Driver gets rides only when online
      if (status == 'SEARCHING' && !_controller.isOnline) return;

      void clearMap() {
        _mapKey.currentState?.updateMarkers(<FlutterFlowMarker>[]);
        _mapKey.currentState?.updateCircles(<Circle>{});
        _mapKey.currentState?.updatePolylines(<Polyline>{});
        _activeRouteKey = null;
      }

      if (status == 'CANCELLED' || status == 'REJECTED' || status == 'DECLINED') {
        _controller.setRideStatus('IDLE');
        Provider.of<RideState>(context, listen: false).clearRide();
        final rideId = rideData['id'] != null
            ? (rideData['id'] is int ? rideData['id'] as int : int.tryParse(rideData['id'].toString()))
            : null;
        if (rideId != null) _overlayKey.currentState?.removeRideById(rideId);
        clearMap();
        return;
      }

      _controller.setRideStatus(status);
      Provider.of<RideState>(context, listen: false).updateRide(RideRequest.fromJson(rideData));
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

        // ✅ Highlight pickup/drop area like Rapido Captain (~350m radius circles)
        const radiusMeters = 350.0;
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
        _mapKey.currentState?.updateCircles(circles);

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
    _mapKey.currentState?.updateCircles(<Circle>{});
    _mapKey.currentState?.updatePolylines(<Polyline>{});
    _activeRouteKey = null;
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
    _activeRouteKey = routeKey;

    final points = await RoutePolylineService().getRoutePoints(
      originLat: origin.latitude,
      originLng: origin.longitude,
      destLat: destination.latitude,
      destLng: destination.longitude,
    );

    if (!mounted || _activeRouteKey != routeKey) return;

    if (points == null || points.isEmpty) {
      _mapKey.currentState?.updatePolylines(<Polyline>{});
      return;
    }

    final polylineId = isAccepted
        ? 'route_driver_pickup_${rr.id}'
        : 'route_pickup_drop_${rr.id}';
    final polyline = Polyline(
      polylineId: PolylineId(polylineId),
      color: AppColors.primary,
      width: 5,
      points: points.map((p) => p.toGoogleMaps()).toList(),
    );
    _mapKey.currentState?.updatePolylines({polyline});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return FFLocalizations.of(context).getText('drv_good_morning');
    if (hour < 17) return FFLocalizations.of(context).getText('drv_good_afternoon');
    return FFLocalizations.of(context).getText('drv_good_evening');
  }

  @override
  void dispose() {
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
        final shouldShowPanels = !['ACCEPTED', 'ARRIVED', 'STARTED', 'ONTRIP', 'COMPLETED', 'FETCHING']
            .contains(c.currentRideStatus.toUpperCase());
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
                  now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
                _lastBackPressed = now;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(FFLocalizations.of(context).getText('drv_back_exit')),
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                        AppHeader(
                          scaffoldKey: scaffoldKey,
                          switchValue: c.isOnline,
                          isDataLoaded: c.isDataLoaded,
                          onToggleOnline: () => c.toggleOnlineStatus(),
                          screenWidth: screenWidth,
                          isSmallScreen: isSmallScreen,
                          notificationCount: 0,
                        ),
                        Expanded(
                          child: Stack(
                            children: [
                              if (isOnline)
                                RideMapContainer(
                                  mapKey: _mapKey,
                                  controller: _model.googleMapsController,
                                  initialLocation: userLocation,
                                  onCameraIdle: (latLng) => _model.googleMapsCenter = latLng,
                                  mapCenter: _model.googleMapsCenter ?? userLocation,
                                  availableDriversCount: c.availableDriversCount,
                                  showCaptainsPanel: shouldShowPanels,
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
                                driverLocation: c.currentUserLocation ?? userLocation,
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
                            onTap: () => setState(() => _isIncentivePanelExpanded = !_isIncentivePanelExpanded),
                            screenWidth: screenWidth,
                            isSmallScreen: isSmallScreen,
                          ),
                        if (shouldShowPanels)
                          EarningsSummary(
                            todayTotal: c.todayTotal,
                            teamEarnings: c.todayWallet,
                            ridesToday: c.todayRideCount,
                            isLoading: c.isLoadingEarnings,
                            isSmallScreen: isSmallScreen,
                          ),
                        SizedBox(height: MediaQuery.sizeOf(context).height * 0.018),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
