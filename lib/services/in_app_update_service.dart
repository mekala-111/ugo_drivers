import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();
  factory InAppUpdateService() => _instance;
  InAppUpdateService._internal();

  bool _isUpdateCheckInProgress = false;

  /// Check for updates via Google Play In-App Update API
  Future<void> checkForUpdate({bool forceImmediate = false}) async {
    if (kIsWeb) return;
    if (_isUpdateCheckInProgress) return;

    _isUpdateCheckInProgress = true;
    try {
      debugPrint('UGO_OTA: Checking for Google Play updates...');
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (forceImmediate || info.immediateUpdateAllowed) {
          debugPrint('UGO_OTA: Performing Immediate Update...');
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          debugPrint('UGO_OTA: Performing Flexible Update...');
          await InAppUpdate.startFlexibleUpdate();
          // After downloading, prompt the user to install
          await InAppUpdate.completeFlexibleUpdate();
        }
      } else {
        debugPrint('UGO_OTA: No update available via Play Store API');
      }
    } catch (e) {
      debugPrint('UGO_OTA_ERROR: Failed to check for in-app update: $e');
    } finally {
      _isUpdateCheckInProgress = false;
    }
  }

  /// Check and handle updates that were previously downloaded but not installed
  Future<void> checkRemainingUpdate() async {
    if (kIsWeb) return;
    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.installStatus == InstallStatus.downloaded) {
        debugPrint('UGO_OTA: Completing previously downloaded update...');
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      debugPrint('UGO_OTA_ERROR: Failed to check remaining update: $e');
    }
  }
}
