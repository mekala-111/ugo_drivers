import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class GoogleMapsNavigation {
  static Future<void> open({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    if (Platform.isAndroid) {
      // 🔥 Force Google Maps app directly (NO chooser)
      final Uri googleMapsUri = Uri.parse(
        'google.navigation:q=$destLat,$destLng&mode=d',
      );

      final bool launched = await launchUrl(
        googleMapsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Google Maps is not installed');
      }

      return;
    }

    if (Platform.isIOS) {
      // ⚠️ iOS CANNOT force Google Maps without popup
      // Apple restriction — not a Flutter limitation
      final Uri appleMapsUri = Uri.parse(
        'http://maps.apple.com/?'
        'saddr=$originLat,$originLng'
        '&daddr=$destLat,$destLng'
        '&dirflg=d',
      );

      await launchUrl(
        appleMapsUri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
