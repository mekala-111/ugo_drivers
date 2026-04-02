import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service to manage Firebase Remote Config
/// This securely stores and retrieves app configuration like payment gateway keys
class FirebaseRemoteConfigService {
  static final FirebaseRemoteConfigService _instance =
      FirebaseRemoteConfigService._internal();
  factory FirebaseRemoteConfigService() => _instance;
  FirebaseRemoteConfigService._internal();

  FirebaseRemoteConfig? _remoteConfig;
  bool _initialized = false;
  late Future<void> _initializeFuture;

  /// Initialize Firebase Remote Config with default values
  Future<void> initialize() async {
    if (_initialized) return;
    _initializeFuture = _doInitialize();
    await _initializeFuture;
  }

  Future<void> _doInitialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values (fallback if remote config fails).
      // IMPORTANT: Never put real Razorpay secret here - it goes in the APK.
      // Production keys must come from Firebase Remote Config only.
      await _remoteConfig!.setDefaults(const {
        'razorpay_key_id': '',
        'razorpay_key_secret': '',
        'razorpay_enabled': false,
        'google_maps_api_key': '',
        'play_store_url': '',
        'latest_app_version': '1.0.0',
        'min_required_version': '1.0.0',
      });

      // Fetch and activate
      await _remoteConfig!.fetchAndActivate();

      _initialized = true;
      if (kDebugMode) {
        print('✅ Firebase Remote Config initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase Remote Config initialization error: $e');
      }
      // Don't throw - app should work even if remote config fails
    }
  }

  /// Get Razorpay Key ID (Public Key)
  String get razorpayKeyId {
    try {
      return _remoteConfig?.getString('razorpay_key_id') ?? '';
    } catch (e) {
      if (kDebugMode) print('Error getting razorpay_key_id: $e');
      return '';
    }
  }

  /// Get Razorpay Key Secret (Private Key)
  String get razorpayKeySecret {
    try {
      return _remoteConfig?.getString('razorpay_key_secret') ?? '';
    } catch (e) {
      if (kDebugMode) print('Error getting razorpay_key_secret: $e');
      return '';
    }
  }

  /// Check if Razorpay is enabled
  bool get razorpayEnabled {
    try {
      return _remoteConfig?.getBool('razorpay_enabled') ?? true;
    } catch (e) {
      if (kDebugMode) print('Error getting razorpay_enabled: $e');
      return true;
    }
  }

  /// Wait for Firebase Remote Config to be initialized
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!_initialized) {
      await _initializeFuture;
    }
  }

  /// Get Google Maps API Key - waits for initialization if needed
  Future<String> googleMapsApiKeyAsync() async {
    await ensureInitialized();
    try {
      final key = _remoteConfig?.getString('google_maps_api_key') ?? '';
      if (key.isNotEmpty && kDebugMode) {
        print(
            '✅ Google Maps API Key loaded from Firebase Remote Config (length: ${key.length})');
      }
      return key;
    } catch (e) {
      if (kDebugMode) print('Error getting google_maps_api_key: $e');
      return '';
    }
  }

  /// Get Google Maps API Key (synchronous, after initialization is complete)
  String get googleMapsApiKey {
    try {
      return _remoteConfig?.getString('google_maps_api_key') ?? '';
    } catch (e) {
      if (kDebugMode) print('Error getting google_maps_api_key: $e');
      return '';
    }
  }

  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig?.getString(key) ?? defaultValue;
    } catch (e) {
      if (kDebugMode) print('Error getting $key: $e');
      return defaultValue;
    }
  }

  /// Get any bool value from remote config
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig?.getBool(key) ?? defaultValue;
    } catch (e) {
      if (kDebugMode) print('Error getting $key: $e');
      return defaultValue;
    }
  }

  /// Get any int value from remote config
  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig?.getInt(key) ?? defaultValue;
    } catch (e) {
      if (kDebugMode) print('Error getting $key: $e');
      return defaultValue;
    }
  }

  /// Get any double value from remote config
  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig?.getDouble(key) ?? defaultValue;
    } catch (e) {
      if (kDebugMode) print('Error getting $key: $e');
      return defaultValue;
    }
  }

  String get latestAppVersion =>
      getString('latest_app_version', defaultValue: '1.0.0');

  String get minRequiredVersion =>
      getString('min_required_version', defaultValue: '1.0.0');

  String get playStoreUrl => getString('play_store_url', defaultValue: '');
}
