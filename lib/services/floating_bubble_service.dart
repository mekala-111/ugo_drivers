import 'package:flutter/services.dart';

class FloatingBubbleService {
  static const MethodChannel _channel =
      MethodChannel('com.ugotaxi_rajkumar.driver/floating_bubble');

  /// Start the floating bubble service
  static Future<String> startFloatingBubble() async {
    try {
      final String result = await _channel.invokeMethod('startFloatingBubble');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to start floating bubble: ${e.message}';
    }
  }

  /// Stop the floating bubble service
  static Future<String> stopFloatingBubble() async {
    try {
      final String result = await _channel.invokeMethod('stopFloatingBubble');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to stop floating bubble: ${e.message}';
    }
  }

  /// Show the floating bubble
  static Future<String> showFloatingBubble() async {
    try {
      final String result = await _channel.invokeMethod('showFloatingBubble');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to show floating bubble: ${e.message}';
    }
  }

  /// Hide the floating bubble
  static Future<String> hideFloatingBubble() async {
    try {
      final String result = await _channel.invokeMethod('hideFloatingBubble');
      return result;
    } on PlatformException catch (_) {
      return 'Failed to hide floating bubble';
    }
  }

  /// Update the floating bubble content
  static Future<String> updateBubbleContent(
      String title, String subtitle) async {
    try {
      final String result = await _channel.invokeMethod('updateBubbleContent', {
        'title': title,
        'subtitle': subtitle,
      });
      return result;
    } on PlatformException catch (_) {
      return 'Failed to update bubble content';
    }
  }

  /// Show a floating ride request card
  static Future<String> showRideRequest({
    required int rideId,
    required String fareText,
    required String pickupDistanceText,
    required String dropDistanceText,
    required String pickupText,
    required String dropText,
    required String paymentMethod,
    required bool isPro,
  }) async {
    try {
      final String result = await _channel.invokeMethod('showRideRequest', {
        'rideId': rideId,
        'fare': fareText,
        'pickupDistance': pickupDistanceText,
        'dropDistance': dropDistanceText,
        'pickup': pickupText,
        'drop': dropText,
        'paymentMethod': paymentMethod,
        'isPro': isPro,
      });
      return result;
    } on PlatformException catch (_) {
      return 'Failed to show ride request';
    }
  }

  /// Hide ride request card and return to bubble
  static Future<String> hideRideRequest() async {
    try {
      final String result = await _channel.invokeMethod('hideRideRequest');
      return result;
    } on PlatformException catch (_) {
      return 'Failed to hide ride request';
    }
  }

  /// Check if overlay permission is granted
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkOverlayPermission');
      return result;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Request overlay permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (_) {
      // Handle error
    }
  }

  /// Send the task to background after overlay decline (reject already ran in Flutter).
  static Future<void> moveTaskToBack() async {
    try {
      await _channel.invokeMethod<void>('moveTaskToBack');
    } on PlatformException catch (_) {
      // Non-fatal if activity already backgrounded.
    }
  }

  /// Drop native [pendingRideAction] after Flutter handled it (prevents replay on
  /// next Activity / engine attach which would call [moveTaskToBack] again).
  static Future<void> clearPendingRideAction() async {
    try {
      await _channel.invokeMethod<void>('clearPendingRideAction');
    } on PlatformException catch (_) {}
    on MissingPluginException catch (_) {}
  }

  /// Consume one pending ride action sent by native side.
  static Future<Map<String, dynamic>?> consumePendingRideAction() async {
    try {
      final result = await _channel.invokeMethod<dynamic>('consumePendingRideAction');
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } on PlatformException catch (_) {
      return null;
    }
  }
}
