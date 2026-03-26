import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart' show RideByIdCall;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ride_detais_model.dart';
export 'ride_detais_model.dart';

class RideDetaisWidget extends StatefulWidget {
  const RideDetaisWidget({super.key, this.rideId});

  final int? rideId;

  @override
  State<RideDetaisWidget> createState() => _RideDetaisWidgetState();
}

class _RideDetaisWidgetState extends State<RideDetaisWidget> {
  late RideDetaisModel _model;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _ride;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RideDetaisModel());
    _loadRide();
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  int get _resolvedRideId {
    final incoming = widget.rideId ?? 0;
    if (incoming > 0) return incoming;
    return FFAppState().activeRideId;
  }

  Future<void> _loadRide() async {
    final rideId = _resolvedRideId;
    if (rideId <= 0) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'No ride selected';
        });
      }
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
        if (mounted) {
          setState(() {
            _error = 'Failed to load ride details';
            _isLoading = false;
          });
        }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.greyBorderLight),
        ),
        child: Text(
          _error!,
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

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

    final headerTitle = firstName.isNotEmpty ? firstName : 'Passenger';
    final statusLabel =
        status.isNotEmpty ? status.toUpperCase() : 'RIDE';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pushNamed(RideOverviewWidget.routeName);
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
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
                                headerTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                mobile.isNotEmpty ? mobile : 'No mobile',
                                style: GoogleFonts.inter(
                                  color: AppColors.greyVehicle,
                                  fontSize: 12,
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
                                color: AppColors.success,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.greyBorderLight),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.radio_button_checked,
                            color: AppColors.primary, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'From: ${pickup.isNotEmpty ? pickup : 'Unknown pickup'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.success, size: 14),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'To: ${drop.isNotEmpty ? drop : 'Unknown drop'}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: AppColors.textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (distanceKm != null)
                          _chip('${distanceKm.toStringAsFixed(2)} km'),
                        if (otp.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _chip('OTP $otp'),
                        ],
                        if (otpVerifiedAt.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _chip('OTP Verified'),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 200.0,
                  child: FlutterFlowGoogleMap(
                    controller: _model.googleMapsController,
                    onCameraIdle: (latLng) => _model.googleMapsCenter = latLng,
                    initialLocation: _model.googleMapsCenter ??= initialMapLocation,
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
}
