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

  /// Initialize Firebase Remote Config with default values
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set config settings
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values (fallback if remote config fails)
      await _remoteConfig!.setDefaults(const {
        'razorpay_key_id': 'rzp_test_SJLRBPVJueitlX',
        'razorpay_key_secret': 'nZyMUPL3wnwdtKx2BVMyL3Ue',
        'razorpay_enabled': true,
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

  /// Get any string value from remote config
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
}
