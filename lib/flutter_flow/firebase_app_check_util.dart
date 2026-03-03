import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

Future initializeFirebaseAppCheck() async {
  // Temporarily skip App Check in debug mode to avoid authentication errors
  // Re-enable after registering debug token in Firebase Console
  if (kDebugMode) {
    debugPrint('⚠️ Firebase App Check DISABLED in debug mode');
    debugPrint('📋 To enable: Register device in Firebase Console > App Check > Apps > Manage debug tokens');
    return;
  }
  
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
}
