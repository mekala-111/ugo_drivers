import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/providers/ride_provider.dart';
import '/services/driver_realtime_socket_service.dart';
import '/services/floating_bubble_service.dart';
import '/services/ride_notification_service.dart';

/// One local teardown for BOTH manual logout and server-forced logout, so the
/// next driver who logs in on this phone never sees the previous driver's data
/// and no authenticated socket is left running with a dead token.
Future<void> tearDownDriverSession(BuildContext? context) async {
  debugPrint('[auth] tearing down driver session');
  DriverRealtimeSocketService.instance.dispose(); // stop socket + reconnects
  try {
    await authManager.signOut();
  } catch (_) {}
  await FFAppState().clearAppState(); // tokens (secure storage), driver id, profile, ride, KYC cache
  if (context != null && context.mounted) {
    try {
      context.read<RideState>().clearRide();
    } catch (_) {}
  }
  try {
    await RideNotificationService().cancelRideNotification();
  } catch (_) {}
  try {
    if (!kIsWeb && Platform.isAndroid) {
      await FloatingBubbleService.stopFloatingBubble();
    }
  } catch (_) {}
}
