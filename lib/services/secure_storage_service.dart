import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for sensitive data (Aadhaar, PAN).
/// Uses platform keychain/Keystore instead of SharedPreferences.
class SecureStorageService {
  SecureStorageService._();
  static SecureStorageService? _instance;
  static SecureStorageService get instance => _instance ??= SecureStorageService._();

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  late final FlutterSecureStorage _storage;

  void init() {
    _storage = const FlutterSecureStorage(aOptions: _androidOptions);
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, String value) async {
    if (value.isEmpty) {
      await delete(key);
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {}
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }

  static const String keyAadharNumber = 'secure_ff_aadharNumber';
  static const String keyAadharFrontImageUrl = 'secure_ff_aadharFrontImageUrl';
  static const String keyAadharBackImageUrl = 'secure_ff_aadharBackImageUrl';
  static const String keyAadharFrontBase64 = 'secure_ff_aadharFrontBase64';
  static const String keyAadharBackBase64 = 'secure_ff_aadharBackBase64';
  static const String keyPanImageUrl = 'secure_ff_panImageUrl';
  static const String keyPanBase64 = 'secure_ff_panBase64';
  static const String keyPanNumber = 'secure_ff_panNumber';
  static const String keyAccessToken = 'secure_ff_accessToken';
}
