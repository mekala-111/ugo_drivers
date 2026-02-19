/// Application configuration and constants.
///
/// For production builds you should supply `--dart-define=API_BASE_URL=...`.
/// During development this defaults to the value used previously.
class Config {
  static String get baseUrl {
    // dart-define has higher precedence; falls back to hardcoded.
    const defaultUrl = 'https://ugo-api.icacorp.org';
    return const String.fromEnvironment('API_BASE_URL', defaultValue: defaultUrl);
  }
}
