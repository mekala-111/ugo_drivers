import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class RideAlertAudioService {
  RideAlertAudioService._();

  static const String playerId = 'ride_request_alert';
  static const MethodChannel _channel = MethodChannel('xyz.luan/audioplayers');

  static AudioPlayer createPlayer() => AudioPlayer(playerId: playerId);

  static Future<void> stopLingeringAlertAudio() async {
    for (final method in ['stop', 'release', 'dispose']) {
      try {
        await _channel.invokeMethod(method, {'playerId': playerId});
      } catch (_) {}
    }
  }
}
