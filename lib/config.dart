/// Application configuration and constants.
///
/// For production: use --dart-define for sensitive values.
/// Example: flutter run --dart-define=API_BASE_URL=https://...
class Config {
  static String get baseUrl {
    const defaultUrl = 'https://ugo-api.icacorp.org';
    return const String.fromEnvironment('API_BASE_URL', defaultValue: defaultUrl);
  }

  /// Build full URL for relative image paths from API (e.g. /uploads/licenses/...)
  static String? fullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final p = path.trim();
    if (p.startsWith('http://') || p.startsWith('https://')) return p;
    return '$baseUrl${p.startsWith('/') ? p : '/$p'}';
  }

  /// Razorpay keys - use dart-define in production. IFSC lookup is free and keyless.
  static String get razorpayKeyId =>
      const String.fromEnvironment('RAZORPAY_KEY_ID', defaultValue: '');
  static String get razorpayKeySecret =>
      const String.fromEnvironment('RAZORPAY_KEY_SECRET', defaultValue: '');
}
