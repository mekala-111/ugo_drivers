import 'package:flutter/services.dart';

class FloatingBubbleService {
  static const MethodChannel _channel =
      MethodChannel('com.ugocabs.drivers/floating_bubble');

  static Function(String action, String rideId)? _onOverlayAction;

  static void setOverlayActionHandler(
      Function(String action, String rideId) handler) {
    _onOverlayAction = handler;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onOverlayAction') {
      final action = call.arguments['action'] as String;
      final rideId = call.arguments['rideId'] as String;
      _onOverlayAction?.call(action, rideId);
    }
  }

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
    } on PlatformException catch (e) {
      return 'Failed to hide floating bubble: ${e.message}';
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
    } on PlatformException catch (e) {
      return 'Failed to update bubble content: ${e.message}';
    }
  }

  /// Show the detailed ride request overlay
  static Future<String> showRideRequestOverlay(String pickup, String drop,
      String fare, String rideId, String accessToken, String driverId) async {
    try {
      final String result =
          await _channel.invokeMethod('showRideRequestOverlay', {
        'pickup': pickup,
        'drop': drop,
        'fare': fare,
        'rideId': rideId,
        'accessToken': accessToken,
        'driverId': driverId,
      });
      return result;
    } on PlatformException catch (e) {
      return 'Failed to show ride request overlay: ${e.message}';
    }
  }

  /// Hide the detailed ride request overlay
  static Future<String> hideRideRequestOverlay() async {
    try {
      final String result =
          await _channel.invokeMethod('hideRideRequestOverlay');
      return result;
    } on PlatformException catch (e) {
      return 'Failed to hide ride request overlay: ${e.message}';
    }
  }

  /// Check if overlay permission is granted
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkOverlayPermission');
      return result;
    } on PlatformException catch (e) {
      return false;
    }
  }

  /// Request overlay permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } on PlatformException catch (e) {
      // Handle error
    }
  }
}
