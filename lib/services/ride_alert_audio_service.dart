import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class RideAlertAudioService {
  RideAlertAudioService._();

  static const String playerId = 'ride_request_alert';
  static const MethodChannel _channel = MethodChannel('xyz.luan/audioplayers');

  static AudioPlayer createPlayer() => AudioPlayer(playerId: playerId);

  /// Hot restart / engine detach can drop the native audioplayers handler before
  /// [AudioPlayer.dispose] cancels its event channel — swallow that case.
  static Future<void> safeDisposePlayer(AudioPlayer? player) async {
    if (player == null) return;
    try {
      await player.stop();
    } on MissingPluginException catch (_) {
    } catch (_) {}
    try {
      await player.dispose();
    } on MissingPluginException catch (_) {
    } catch (_) {}
  }

  static Future<void> stopLingeringAlertAudio() async {
    for (final method in ['stop', 'release', 'dispose']) {
      try {
        await _channel.invokeMethod(method, {'playerId': playerId});
      } on MissingPluginException catch (_) {
      } catch (_) {}
    }
  }
}
