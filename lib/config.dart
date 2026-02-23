import '/services/firebase_remote_config_service.dart';

/// Application configuration and constants.
///
/// For production: use --dart-define for sensitive values.
/// Example: flutter run --dart-define=API_BASE_URL=https://...
class Config {
  static String get baseUrl {
    const defaultUrl = 'https://ugo-api.icacorp.org';
    return const String.fromEnvironment('API_BASE_URL',
        defaultValue: defaultUrl);
  }

  /// Build full URL for relative image paths from API (e.g. /uploads/licenses/...)
  static String? fullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    return '$baseUrl${p.startsWith('/') ? p : '/$p'}';
  }

  /// Razorpay keys - fetched from Firebase Remote Config (secure)
  /// Falls back to dart-define if remote config is not available
  static String get razorpayKeyId {
    // Try Firebase Remote Config first (secure)
    final remoteKey = FirebaseRemoteConfigService().razorpayKeyId;
    if (remoteKey.isNotEmpty) return remoteKey;

    // Fallback to dart-define (for development)
    return const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');
  }

  static String get razorpayKeySecret {
    // Try Firebase Remote Config first (secure)
    final remoteSecret = FirebaseRemoteConfigService().razorpayKeySecret;
    if (remoteSecret.isNotEmpty) return remoteSecret;

    // Fallback to dart-define (for development)
    return const String.fromEnvironment('RAZORPAY_KEY_SECRET',
        defaultValue: '');
  }

  /// Check if Razorpay is enabled
  static bool get razorpayEnabled {
    return FirebaseRemoteConfigService().razorpayEnabled;
  }

  /// Google Maps API key for Distance Matrix / Directions (polyline, route services).
  /// Source: android/local.properties MAPS_API_KEY, passed via --dart-define at build.
  /// Use: ./scripts/flutter_run.sh (reads from local.properties automatically)
  /// Or: flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key
  static String get googleMapsApiKey =>
      const String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
}
