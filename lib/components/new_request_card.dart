import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/constants/responsive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import '../home/ride_request_model.dart';

class NewRequestCard extends StatelessWidget {
  final RideRequest ride;
  final int remainingTime;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final LatLng? driverLocation;
  final bool isLoading;

  const NewRequestCard({
    super.key,
    required this.ride,
    required this.remainingTime,
    this.onAccept,
    this.onDecline,
    this.driverLocation,
    this.isLoading = false,
  });

  // --- Colors ---
  static const Color ugoOrange = AppColors.primary;
  static const Color ugoGreen = AppColors.success;
  static const Color ugoRed = AppColors.error;
  static const Color ugoBlue = AppColors.infoDark;

  /// Extract 6-digit pincode from address.
  static String _extractPincode(String address) {
    final match = RegExp(r'\b\d{6}\b').firstMatch(address);
    return match?.group(0) ?? '';
  }

  /// Compute pickup distance from driver to pickup (km).
  static double? _pickupDistanceKm(LatLng? driver, RideRequest ride) {
    if (driver == null || ride.pickupLat == 0 || ride.pickupLng == 0) return null;
    final m = Geolocator.distanceBetween(
      driver.latitude, driver.longitude,
      ride.pickupLat, ride.pickupLng,
    );
    return m / 1000;
  }

  @override
  Widget build(BuildContext context) {
    final margin = Responsive.value(context, small: 8.0, medium: 10.0, large: 12.0);
    final pad = Responsive.horizontalPadding(context);
    final pickupKm = _pickupDistanceKm(driverLocation, ride);
    final pickupDistStr = pickupKm != null
        ? '${pickupKm < 1 ? (pickupKm * 1000).round() : pickupKm.toStringAsFixed(1)}${pickupKm < 1 ? 'm' : 'Km'}'
        : '--';
    final dropDistStr = ride.distance != null
        ? (ride.distance! >= 1
            ? '${ride.distance!.toStringAsFixed(1)}Km'
            : '${(ride.distance! * 1000).round()}m')
        : '--';
    final pickupPin = _extractPincode(ride.pickupAddress);
    final dropPin = _extractPincode(ride.dropAddress);
    return Container(
      margin: EdgeInsets.all(margin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
        border: Border.all(color: ugoOrange, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: pad, vertical: Responsive.verticalSpacing(context)),
            decoration: const BoxDecoration(
                color: ugoGreen,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(FFLocalizations.of(context).getText('drv_new_request'),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 16))),
                Text('${remainingTime}s',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 16))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDistanceInfo(context, FFLocalizations.of(context).getText('drv_pickup_distance'), pickupDistStr),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(height: 1, color: Colors.grey[300]),
                          const Icon(Icons.arrow_forward, size: 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 25.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[400]!)),
                              child: Column(children: [
                                Text('Fare',
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 10)),
                                Text('₹${ride.estimatedFare?.toInt() ?? 80}',
                                    style: const TextStyle(
                                        color: ugoBlue,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDistanceInfo(context,
                        FFLocalizations.of(context).getText('drv_drop_distance'), dropDistStr,
                        alignRight: true),
                  ],
                ),
                const SizedBox(height: 20),
                _buildAddressRow(context,
                    color: ugoRed,
                    label: FFLocalizations.of(context).getText('drv_drop'),
                    code: dropPin.isEmpty ? '--' : dropPin,
                    address: ride.dropAddress),
                SizedBox(height: Responsive.verticalSpacing(context)),
                _buildAddressRow(context,
                    color: ugoGreen,
                    label: FFLocalizations.of(context).getText('drv_pickup'),
                    code: pickupPin.isEmpty ? '--' : pickupPin,
                    address: ride.pickupAddress),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                        child: _buildButton(
                            context,
                            FFLocalizations.of(context).getText('drv_decline'), ugoRed, isLoading ? null : onDecline)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ugoGreen,
                                    ),
                                  ),
                                ),
                              )
                            : _buildButton(context, FFLocalizations.of(context).getText('drv_accept'), ugoGreen, onAccept)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(BuildContext context, String label, String value,
      {bool alignRight = false}) {
    return Column(
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: Responsive.fontSize(context, 12))),
          Text(value,
              style: TextStyle(
                  color: ugoBlue,
                  fontSize: Responsive.fontSize(context, 20),
                  fontWeight: FontWeight.bold))
        ]);
  }

  Widget _buildAddressRow(BuildContext context,
      {required Color color,
      required String label,
      required String code,
      required String address}) {
    final boxSz = Responsive.value(context, small: 42.0, medium: 45.0, large: 48.0);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          width: boxSz,
          height: boxSz,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha:0.5))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.location_on, color: color, size: Responsive.iconSize(context, base: 20)),
            Text(label,
                style: TextStyle(fontSize: Responsive.fontSize(context, 10), color: Colors.grey))
          ])),
      SizedBox(width: Responsive.verticalSpacing(context)),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(code,
            style: TextStyle(
                color: ugoOrange,
                fontWeight: FontWeight.bold,
                fontSize: Responsive.fontSize(context, 14))),
        Text(address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey[700], fontSize: Responsive.fontSize(context, 13)))
      ])),
    ]);
  }

  Widget _buildButton(BuildContext context, String text, Color bg, VoidCallback? onTap) {
    final btnH = Responsive.buttonHeight(context, base: 48);
    return SizedBox(
      height: btnH,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: Responsive.fontSize(context, 15),
          ),
        ),
      ),
    );
  }
}
