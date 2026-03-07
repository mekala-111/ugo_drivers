import '/services/firebase_remote_config_service.dart';

/// Application configuration and constants.
///
/// For production: use --dart-define for sensitive values.
/// Example: flutter run --dart-define=API_BASE_URL=https://...
class Config {
  static String get baseUrl {
    const defaultUrl = 'https://ugo-api.icacorp.org';
    // const defaultUrl = 'https://ugotaxi.icacorp.org';
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

  /// Google Maps API key - get from Firebase Remote Config (primary) or dart-define (fallback)
  /// For production: Firebase Remote Config should be initialized before this is called
  /// For development: pass via --dart-define or use local.properties
  static String get googleMapsApiKey {
    // Primary: Firebase Remote Config (used in production and after initialization)
    final firebaseKey = FirebaseRemoteConfigService().googleMapsApiKey;
    if (firebaseKey.isNotEmpty) return firebaseKey;

    // Fallback: dart-define (for development without Firebase)
    const primary = String.fromEnvironment('GOOGLE_MAPS_API_KEY',
        defaultValue: '');
    if (primary.isNotEmpty) return primary;
    return const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  }

  /// Alternative async method if Firebase hasn't initialized yet
  static Future<String> getGoogleMapsApiKey() async {
    try {
      final remoteKey = await FirebaseRemoteConfigService().googleMapsApiKeyAsync();
      if (remoteKey.isNotEmpty) return remoteKey;
    } catch (e) {
      // Fall through to dart-define if Firebase fails
    }

    // Fallback to dart-define (for development)
    const primary = String.fromEnvironment('GOOGLE_MAPS_API_KEY',
        defaultValue: '');
    if (primary.isNotEmpty) return primary;
    return const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  }

  /// Synchronous fallback (only dart-define, for immediate access before Firebase init)
  static String get googleMapsApiKeySync {
    const primary = String.fromEnvironment('GOOGLE_MAPS_API_KEY',
        defaultValue: '');
    if (primary.isNotEmpty) return primary;
    return const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  }
}
