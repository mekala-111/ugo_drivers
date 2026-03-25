import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '/flutter_flow/flutter_flow_util.dart';

class InstallReferrerService {
  static const MethodChannel _channel =
      MethodChannel('com.ugotaxi_rajkumar.driver/install_referrer');

  static Future<void> captureReferralCodeIfAvailable() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final rawReferrer =
          await _channel.invokeMethod<String>('getInstallReferrer');
      final referralCode = _extractReferralCode(rawReferrer);
      if (referralCode == null || referralCode.isEmpty) return;

      final code = referralCode.trim();
      if (code.isEmpty) return;

      if (FFAppState().usedReferralCode.trim().isEmpty) {
        FFAppState().usedReferralCode = code;
      }
      if (FFAppState().referralCode.trim().isEmpty) {
        FFAppState().referralCode = code;
      }
    } catch (e) {
      debugPrint('InstallReferrerService error: $e');
    }
  }

  static String? _extractReferralCode(String? rawReferrer) {
    if (rawReferrer == null || rawReferrer.trim().isEmpty) return null;

    final raw = rawReferrer.trim();
    final decoded = _tryDecode(raw);

    final candidates = <String>[raw, decoded];

    for (final candidate in candidates) {
      final query =
          candidate.startsWith('?') ? candidate.substring(1) : candidate;
      if (!query.contains('=')) continue;

      try {
        final params = Uri.splitQueryString(query);
        final code = params['referalcode'] ??
            params['referral_code'] ??
            params['referralCode'] ??
            params['code'];
        if (code != null && code.trim().isNotEmpty) {
          return code.trim();
        }
      } catch (_) {
        // Ignore parse failures and continue.
      }
    }

    return null;
  }

  static String _tryDecode(String input) {
    try {
      return Uri.decodeComponent(input);
    } catch (_) {
      return input;
    }
  }
}
