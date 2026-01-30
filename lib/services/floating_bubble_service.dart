import 'package:flutter/services.dart';

class FloatingBubbleService {
  static const MethodChannel _channel =
      MethodChannel('com.ugocabs.drivers/floating_bubble');

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
