import 'package:flutter/material.dart';
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
import 'home_model.dart';
import 'ride_request_model.dart';
import 'ride_request_overlay.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_ride_panel.dart';
import 'widgets/earnings_summary.dart';
import 'widgets/incentive_panel.dart';
import 'widgets/offline_dashboard.dart';
import 'widgets/ride_map.dart';

import '../constants/app_colors.dart';
import '../constants/responsive.dart';
import '../flutter_flow/lat_lng.dart' as latlng;

export 'home_model.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({super.key});

  static String routeName = 'home';
  static String routePath = '/home';

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> with AutomaticKeepAliveClientMixin {
  late HomeModel _model;
  late HomeController _controller;

  final GlobalKey<RideRequestOverlayState> _overlayKey = GlobalKey<RideRequestOverlayState>();
  final GlobalKey<FlutterFlowGoogleMapState> _mapKey = GlobalKey<FlutterFlowGoogleMapState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isIncentivePanelExpanded = false;
  DateTime? _lastBackPressed;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomeModel());

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FFLocalizations.of(context).getText(key)),
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
      _handlePendingRideFromNotification();
    });
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

      if (status == 'CANCELLED' || status == 'REJECTED') {
        _controller.setRideStatus('IDLE');
        final rideId = rideData['id'] != null
            ? (rideData['id'] is int ? rideData['id'] as int : int.tryParse(rideData['id'].toString()))
            : null;
        if (rideId != null) _overlayKey.currentState?.removeRideById(rideId);
        _mapKey.currentState?.updateMarkers(<FlutterFlowMarker>[]);
        return;
      }

      _controller.setRideStatus(status);
      Provider.of<RideState>(context, listen: false).updateRide(RideRequest.fromJson(rideData));
      _overlayKey.currentState!.handleNewRide(rideData);
      try {
        final rr = RideRequest.fromJson(rideData);
        final markers = <FlutterFlowMarker>[
          FlutterFlowMarker('pickup_${rr.id}', latlng.LatLng(rr.pickupLat, rr.pickupLng)),
        ];
        if (rr.dropLat != 0 && rr.dropLng != 0) {
          markers.add(FlutterFlowMarker('drop_${rr.id}', latlng.LatLng(rr.dropLat, rr.dropLng)));
        }
        _mapKey.currentState?.updateMarkers(markers);
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
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return FFLocalizations.of(context).getText('drv_good_morning');
    if (hour < 17) return FFLocalizations.of(context).getText('drv_good_afternoon');
    return FFLocalizations.of(context).getText('drv_good_evening');
  }

  @override
  void dispose() {
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
              } else if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.white,
              drawer: const Drawer(elevation: 16.0, child: MenuWidget()),
              body: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: Responsive.value(context, small: 20.0, medium: 26.0, large: 32.0)),
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
                  SizedBox(height: Responsive.value(context, small: 10.0, medium: 12.0, large: 15.0)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
