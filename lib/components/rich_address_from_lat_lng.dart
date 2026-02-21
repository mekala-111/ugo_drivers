import 'package:flutter/material.dart';
import 'package:ugo_driver/constants/app_colors.dart';
import 'package:ugo_driver/services/location_geocode_service.dart';

/// Pincode & locality from lat/lon (reverse geocoding), not from address string.
class RichAddressFromLatLng extends StatelessWidget {
  final double lat;
  final double lng;
  final String fallbackAddress;
  final String fallbackLabel;

  const RichAddressFromLatLng({
    super.key,
    required this.lat,
    required this.lng,
    required this.fallbackAddress,
    required this.fallbackLabel,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: (lat != 0 || lng != 0)
          ? LocationGeocodeService().getPincodeAndLocality(lat, lng)
          : Future.value((pincode: '', locality: '')),
      builder: (context, snapshot) {
        final pincode = snapshot.data?.pincode ?? '';
        final locality = snapshot.data?.locality ?? '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pincode.isNotEmpty)
              Text(
                pincode,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            Text(
              locality.isNotEmpty ? locality : fallbackLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fallbackAddress,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        );
      },
    );
  }
}
