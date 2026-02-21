import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ugo_driver/services/location_geocode_service.dart';

const String _kVoiceEnabledKey = 'ff_voice_enabled';

/// Rapido-style voice announcements for ride events.
/// Supports English, Hindi, and Telugu based on user selection.
class VoiceService {
  static final VoiceService _instance = VoiceService._();
  factory VoiceService() => _instance;

  VoiceService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  String _language = 'en';
  bool _voiceEnabled = true;

  bool get voiceEnabled => _voiceEnabled;

  Future<void> setVoiceEnabled(bool enabled) async {
    if (_voiceEnabled == enabled) return;
    _voiceEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kVoiceEnabledKey, enabled);
    } catch (_) {}
  }

  Future<void> _loadVoiceEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _voiceEnabled = prefs.getBool(_kVoiceEnabledKey) ?? true;
    } catch (_) {}
  }

  /// TTS locale codes. Fallback order: en-IN -> en-US -> en (wider compatibility)
  static const Map<String, List<String>> _ttsLocaleFallbacks = {
    'en': ['en-IN', 'en-US', 'en'],
    'hi': ['hi-IN', 'hi'],
    'te': ['te-IN', 'te'],
  };

  /// Voice messages in English, Hindi, Telugu
  static const Map<String, Map<String, String>> _voiceMessages = {
    'newRideRequest': {
      'en': 'New ride request. Please check your screen.',
      'hi': 'नई राइड रिक्वेस्ट। कृपया अपनी स्क्रीन जांचें।',
      'te': 'కొత్త రైడ్ అభ్యర్థన. దయచేసి మీ స్క్రీన్ తనిఖీ చేయండి.',
    },
    'rideAccepted': {
      'en': 'Ride accepted. Navigate to pickup location.',
      'hi': 'राइड स्वीकृत। पिकअप लोकेशन पर जाएं।',
      'te': 'రైడ్ అంగీకరించబడింది. పికప్ స్థానానికి వెళ్లండి.',
    },
    'arrivedAtPickup': {
      'en': 'You have arrived. Ask the passenger for OTP to start the ride.',
      'hi': 'आप पहुंच गए। राइड शुरू करने के लिए पैसेंजर से OTP मांगें।',
      'te': 'మీరు వచ్చారు. రైడ్ ప్రారంభించడానికి ప్రయాణీకుడిని OTP అడగండి.',
    },
    'pleaseStartRide': {
      'en': 'Please enter OTP and start the ride.',
      'hi': 'कृपया OTP दर्ज करें और राइड शुरू करें।',
      'te': 'దయచేసి OTP నమోదు చేసి రైడ్ ప్రారంభించండి.',
    },
    'rideStarted': {
      'en': 'Ride started. Navigate to drop location.',
      'hi': 'राइड शुरू हो गई। ड्रॉप लोकेशन पर जाएं।',
      'te': 'రైడ్ ప్రారంభమైంది. డ్రాప్ స్థానానికి వెళ్లండి.',
    },
    'rideCompleted': {
      'en': 'Ride completed. Thank you.',
      'hi': 'राइड पूरी हुई। धन्यवाद।',
      'te': 'రైడ్ పూర్తయింది. ధన్యవాదాలు.',
    },
    'captainsNearby': {
      'en': 'captains nearby.',
      'hi': 'कैप्टन पास में।',
      'te': 'కెప్టెన్‌లు సమీపంలో.',
    },
    'captainNearby': {
      'en': 'captain nearby.',
      'hi': 'कैप्टन पास में।',
      'te': 'కెప్టెన్ సమీపంలో.',
    },
  };

  /// Set language for voice (en, hi, te). Resets init so TTS uses new language.
  void setLanguage(String lang) {
    if (['en', 'hi', 'te'].contains(lang) && lang != _language) {
      _language = lang;
      _initialized = false;
    }
  }

  String get language => _language;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    final fallbacks = _ttsLocaleFallbacks[_language] ?? ['en-US', 'en'];
    bool localeSet = false;
    for (final locale in fallbacks) {
      try {
        final available = await _tts.isLanguageAvailable(locale).timeout(
          const Duration(seconds: 2),
          onTimeout: () => false,
        );
        if (available == true) {
          await _tts.setLanguage(locale);
          localeSet = true;
          break;
        }
      } catch (_) {}
    }
    if (!localeSet) {
      try {
        await _tts.setLanguage('en-US');
      } catch (e) {
        if (kDebugMode) debugPrint('VoiceService: TTS setLanguage failed: $e');
      }
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  String _msg(String key) =>
      _voiceMessages[key]?[_language] ?? _voiceMessages[key]!['en']!;

  /// Speak text (Rapido Captain style announcements). No-op if voice disabled.
  Future<void> speak(String text) async {
    if (!_voiceEnabled) return;
    if (text.isEmpty) return;
    try {
      await _ensureInit();
      await _tts.speak(text);
    } catch (e) {
      if (kDebugMode) debugPrint('VoiceService: speak failed: $e');
    }
  }

  /// Stop any ongoing speech.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  // --- Rapido-style ride event messages ---

  Future<void> newRideRequest() async {
    await speak(_msg('newRideRequest'));
  }

  /// Rapido Captain style: price + area names (locality) for pickup and drop.
  /// Call after newRideRequest() for full announcement.
  Future<void> speakNewRideAddress({
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropLat,
    required double dropLng,
    required String dropAddress,
    double? estimatedFare,
  }) async {
    if (!_voiceEnabled) return;
    try {
      final geocode = LocationGeocodeService();
      final pickupFuture = (pickupLat != 0 || pickupLng != 0)
          ? geocode.getPincodeAndLocality(pickupLat, pickupLng)
          : Future.value((pincode: '', locality: ''));
      final dropFuture = (dropLat != 0 || dropLng != 0)
          ? geocode.getPincodeAndLocality(dropLat, dropLng)
          : Future.value((pincode: '', locality: ''));
      final pickup = await pickupFuture;
      final drop = await dropFuture;
      final pickupArea = pickup.locality.isNotEmpty ? pickup.locality : _shortAddress(pickupAddress);
      final dropArea = drop.locality.isNotEmpty ? drop.locality : _shortAddress(dropAddress);
      final fare = estimatedFare?.toInt() ?? 80;
      final text = 'Fare $fare rupees. Pickup $pickupArea. Drop $dropArea.';
      await speak(text);
    } catch (e) {
      if (kDebugMode) debugPrint('VoiceService: speakNewRideAddress failed: $e');
      final fare = estimatedFare?.toInt() ?? 80;
      final fallback = 'Fare $fare rupees. Pickup ${_shortAddress(pickupAddress)}. Drop ${_shortAddress(dropAddress)}.';
      await speak(fallback);
    }
  }

  String _shortAddress(String addr) {
    if (addr.isEmpty) return 'unknown';
    final parts = addr.split(',');
    return parts.first.trim();
  }

  Future<void> rideAccepted() async {
    await speak(_msg('rideAccepted'));
  }

  Future<void> arrivedAtPickup() async {
    await speak(_msg('arrivedAtPickup'));
  }

  Future<void> pleaseStartRide() async {
    await speak(_msg('pleaseStartRide'));
  }

  Future<void> rideStarted() async {
    await speak(_msg('rideStarted'));
  }

  Future<void> rideCompleted() async {
    await speak(_msg('rideCompleted'));
  }

  Future<void> initFromStorage() async {
    await _loadVoiceEnabled();
    try {
      await _ensureInit();
    } catch (_) {}
  }

  Future<void> captainsNearby(int count) async {
    if (count <= 0 || !_voiceEnabled) return;
    final suffix = count > 1 ? _msg('captainsNearby') : _msg('captainNearby');
    await speak('$count $suffix');
  }
}
