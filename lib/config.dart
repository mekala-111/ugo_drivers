import '/services/firebase_remote_config_service.dart';

class Config {
  static String get baseUrl {
    const defaultUrl = 'https://ugo-api.icacorp.org';
    //const defaultUrl = 'https://ugotaxi.icacorp.org';
    return const String.fromEnvironment('API_BASE_URL',
        defaultValue: defaultUrl);
  }

  static String? fullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    return '$baseUrl${p.startsWith('/') ? p : '/$p'}';
  }

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

  static String get googleMapsApiKey {
    // Primary: Firebase Remote Config (used in production and after initialization)
    final firebaseKey = FirebaseRemoteConfigService().googleMapsApiKey;
    if (firebaseKey.isNotEmpty) return firebaseKey;

    // Fallback: dart-define (for development without Firebase)
    const primary =
        String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    if (primary.isNotEmpty) return primary;
    return const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  }

  static Future<String> getGoogleMapsApiKey() async {
    try {
      final remoteKey =
          await FirebaseRemoteConfigService().googleMapsApiKeyAsync();
      if (remoteKey.isNotEmpty) return remoteKey;
    } catch (e) {
      // Fall through to dart-define if Firebase fails
    }

    // Fallback to dart-define (for development)
    const primary =
        String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    if (primary.isNotEmpty) return primary;
    return const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  }

  static String get googleMapsApiKeySync {
    const primary =
        String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');
    if (primary.isNotEmpty) return primary;
    return const String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
  }

  /// Play Store app URL used in referral sharing
  static String get playStoreUrl {
    final remoteUrl = FirebaseRemoteConfigService().playStoreUrl.trim();
    if (remoteUrl.isNotEmpty) return remoteUrl;
    const defaultUrl =
        'https://play.google.com/store/apps/details?id=com.ugotaxi_rajkumar.driver&hl=en_IN';
    return const String.fromEnvironment('PLAY_STORE_URL',
        defaultValue: defaultUrl);
  }
}
