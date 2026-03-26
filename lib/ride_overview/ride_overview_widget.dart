import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart' show RideByIdCall;
import '/services/route_polyline_service.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:google_fonts/google_fonts.dart';
import 'ride_overview_model.dart';
export 'ride_overview_model.dart';

/// Ride Details Overview
class RideOverviewWidget extends StatefulWidget {
  const RideOverviewWidget({super.key});

  static String routeName = 'ride_overview';
  static String routePath = '/rideOverview';

  @override
  State<RideOverviewWidget> createState() => _RideOverviewWidgetState();
}

class _RideOverviewWidgetState extends State<RideOverviewWidget> {
  late RideOverviewModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FlutterFlowGoogleMapState> _mapKey =
      GlobalKey<FlutterFlowGoogleMapState>();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _ride;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RideOverviewModel());
    _loadRide();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  Future<void> _loadRide() async {
    final rideId = FFAppState().activeRideId;
    if (rideId <= 0) {
      setState(() {
        _isLoading = false;
        _error = 'No ride selected';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await RideByIdCall.call(
        token: FFAppState().accessToken,
        id: rideId,
      );
      if (!res.succeeded) {
        setState(() {
          _error = 'Failed to load ride details';
          _isLoading = false;
        });
        return;
      }

      final data = getJsonField(res.jsonBody, r'$.data');
      if (data is Map) {
        _ride = Map<String, dynamic>.from(data);
      } else {
        _error = 'Ride details unavailable';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  Future<void> _updateRoutePolyline({
    required double? pickupLat,
    required double? pickupLng,
    required double? dropLat,
    required double? dropLng,
  }) async {
    if (pickupLat == null ||
        pickupLng == null ||
        dropLat == null ||
        dropLng == null) {
      _mapKey.currentState?.updatePolylines(<Polyline>{});
      return;
    }

    final points = await RoutePolylineService().getRoutePoints(
      originLat: pickupLat,
      originLng: pickupLng,
      destLat: dropLat,
      destLng: dropLng,
    );
    if (!mounted) return;

    if (points == null || points.isEmpty) {
      _mapKey.currentState?.updatePolylines(<Polyline>{});
      return;
    }

    final googlePoints = points.map((p) => p.toGoogleMaps()).toList();
    final rideId = (_ride?['id'] ?? FFAppState().activeRideId).toString();

    final outlinePolyline = Polyline(
      polylineId: PolylineId('ride_route_outline_$rideId'),
      color: Colors.white,
      width: 13,
      points: googlePoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 0,
    );
    final routePolyline = Polyline(
      polylineId: PolylineId('ride_route_$rideId'),
      color: AppColors.primary,
      width: 8,
      points: googlePoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      zIndex: 1,
    );

    _mapKey.currentState?.updatePolylines({outlinePolyline, routePolyline});
    await _fitMapToRouteBounds(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
      routePoints: googlePoints,
    );
  }

  Future<void> _fitMapToRouteBounds({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    List<gmaps.LatLng>? routePoints,
  }) async {
    try {
      final controller = await _model.googleMapsController.future;
      if (!mounted) return;

      var minLat = pickupLat < dropLat ? pickupLat : dropLat;
      var maxLat = pickupLat > dropLat ? pickupLat : dropLat;
      var minLng = pickupLng < dropLng ? pickupLng : dropLng;
      var maxLng = pickupLng > dropLng ? pickupLng : dropLng;

      if (routePoints != null && routePoints.isNotEmpty) {
        for (final p in routePoints) {
          if (p.latitude < minLat) minLat = p.latitude;
          if (p.latitude > maxLat) maxLat = p.latitude;
          if (p.longitude < minLng) minLng = p.longitude;
          if (p.longitude > maxLng) maxLng = p.longitude;
        }
      }

      // GoogleMap can't animate bounds when NE == SW; nudge slightly.
      if ((maxLat - minLat).abs() < 0.0001) {
        maxLat += 0.0005;
        minLat -= 0.0005;
      }
      if ((maxLng - minLng).abs() < 0.0001) {
        maxLng += 0.0005;
        minLng -= 0.0005;
      }

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          gmaps.LatLngBounds(
            southwest: gmaps.LatLng(minLat, minLng),
            northeast: gmaps.LatLng(maxLat, maxLng),
          ),
          70.0,
        ),
      );
    } catch (_) {
      // Keep default map camera if fit fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = _ride ?? <String, dynamic>{};
    final firstName = (ride['first_name'] ?? '').toString().trim();
    final mobile = (ride['mobile_number'] ?? '').toString().trim();
    final status = (ride['ride_status'] ?? '').toString().trim();
    final pickup = (ride['pickup_location_address'] ?? '').toString().trim();
    final drop = (ride['drop_location_address'] ?? '').toString().trim();
    final fare = _toDouble(ride['estimated_fare']) ?? 0.0;
    final distanceKm = _toDouble(ride['ride_distance_km']);
    final otp = (ride['otp'] ?? '').toString().trim();
    final otpVerifiedAt = (ride['otp_verified_at'] ?? '').toString().trim();
    final pickupLat = _toDouble(ride['pickup_latitude']);
    final pickupLng = _toDouble(ride['pickup_longitude']);
    final dropLat = _toDouble(ride['drop_latitude']);
    final dropLng = _toDouble(ride['drop_longitude']);

    final initialMapLocation = (pickupLat != null && pickupLng != null)
        ? LatLng(pickupLat, pickupLng)
        : const LatLng(17.3850, 78.4867);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              '6b25o08x' /* Ride details */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: FlutterFlowTheme.of(context).bodyMedium,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: AppColors.sectionOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      firstName.isNotEmpty
                                          ? firstName
                                          : 'Passenger',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      mobile.isNotEmpty ? mobile : 'No mobile',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.greyMedium,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${fare.toStringAsFixed(2)}',
                                    style: GoogleFonts.interTight(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      status.isNotEmpty
                                          ? status.toUpperCase()
                                          : 'RIDE',
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            height: 220,
                            child: FlutterFlowGoogleMap(
                              key: _mapKey,
                              controller: _model.googleMapsController,
                              onCameraIdle: (latLng) =>
                                  _model.googleMapsCenter = latLng,
                              onMapCreated: (_) {
                                _updateRoutePolyline(
                                  pickupLat: pickupLat,
                                  pickupLng: pickupLng,
                                  dropLat: dropLat,
                                  dropLng: dropLng,
                                );
                              },
                              initialLocation:
                                  _model.googleMapsCenter ??= initialMapLocation,
                              markerColor: GoogleMarkerColor.orange,
                              mapType: MapType.normal,
                              style: GoogleMapStyle.standard,
                              initialZoom: 12.5,
                              allowInteraction: true,
                              allowZoom: true,
                              showZoomControls: true,
                              showLocation: true,
                              showCompass: false,
                              showMapToolbar: false,
                              showTraffic: false,
                              centerMapOnMarkerTap: true,
                              mapTakesGesturePreference: false,
                              markers: [
                                if (pickupLat != null && pickupLng != null)
                                  FlutterFlowMarker(
                                    'pickup_${ride['id']}',
                                    LatLng(pickupLat, pickupLng),
                                    null,
                                    GoogleMarkerColor.orange,
                                  ),
                                if (dropLat != null && dropLng != null)
                                  FlutterFlowMarker(
                                    'drop_${ride['id']}',
                                    LatLng(dropLat, dropLng),
                                    null,
                                    GoogleMarkerColor.green,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _infoRow(
                          icon: Icons.radio_button_checked,
                          iconColor: AppColors.primary,
                          title: 'From',
                          value:
                              pickup.isNotEmpty ? pickup : 'Unknown pickup',
                        ),
                        const SizedBox(height: 10),
                        _infoRow(
                          icon: Icons.location_on,
                          iconColor: AppColors.success,
                          title: 'To',
                          value: drop.isNotEmpty ? drop : 'Unknown drop',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (distanceKm != null)
                              _chip('${distanceKm.toStringAsFixed(2)} km'),
                            if (otp.isNotEmpty) _chip('OTP $otp'),
                            if (otpVerifiedAt.isNotEmpty)
                              _chip('OTP Verified'),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.sectionOrange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: '$title: ',
              style: GoogleFonts.inter(
                color: AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    color: AppColors.greyDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
