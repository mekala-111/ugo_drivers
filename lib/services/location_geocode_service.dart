import 'package:geocoding/geocoding.dart';

/// Reverse geocoding: get pincode and locality from lat/lon (not from address string).
class LocationGeocodeService {
  static final LocationGeocodeService _instance = LocationGeocodeService._();
  factory LocationGeocodeService() => _instance;

  LocationGeocodeService._();

  final Map<String, _CachedResult> _cache = {};

  static final List<({RegExp pattern, int score})> _highlightPatterns = [
    (pattern: RegExp(r'\bbridge\b', caseSensitive: false), score: 120),
    (pattern: RegExp(r'\bflyover\b', caseSensitive: false), score: 115),
    (
      pattern: RegExp(
        r'\b(highway|hwy|expressway|bypass)\b',
        caseSensitive: false,
      ),
      score: 110,
    ),
    (
      pattern: RegExp(r'\b(main\s+road|main\s+rd)\b', caseSensitive: false),
      score: 105,
    ),
    (pattern: RegExp(r'\b(road|rd)\b', caseSensitive: false), score: 100),
    (pattern: RegExp(r'\b(street|st)\b', caseSensitive: false), score: 95),
    (pattern: RegExp(r'\b(avenue|ave)\b', caseSensitive: false), score: 90),
    (pattern: RegExp(r'\b(circle|cir)\b', caseSensitive: false), score: 80),
    (
      pattern: RegExp(r'\b(junction|jn|signal)\b', caseSensitive: false),
      score: 75,
    ),
    (pattern: RegExp(r'\b(cross|lane|ln)\b', caseSensitive: false), score: 65),
  ];

  /// Get pincode and locality from coordinates. Uses cache to avoid repeated API calls.
  Future<({String pincode, String locality})> getPincodeAndLocality(
    double lat,
    double lng,
  ) async {
    if (lat == 0.0 && lng == 0.0) return (pincode: '', locality: '');
    final key = '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) {
      return (pincode: cached.pincode, locality: cached.locality);
    }
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final pincode = p?.postalCode?.trim() ?? '';
      final locality = (p?.subLocality?.trim().isNotEmpty == true
                  ? p!.subLocality
                  : p?.locality?.trim())
              ?.trim() ??
          '';
      _cache[key] = _CachedResult(
        pincode: pincode,
        locality: locality,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      return (pincode: pincode, locality: locality);
    } catch (_) {
      return (pincode: '', locality: '');
    }
  }

  String getHighlightedPrimaryLabel({
    required String address,
    String locality = '',
    String fallbackLabel = '',
  }) {
    final segments = address
        .split(',')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    String? bestSegment;
    var bestScore = 0;

    for (final segment in segments) {
      final score = _scoreSegment(segment);
      if (score > bestScore ||
          (score == bestScore &&
              score > 0 &&
              bestSegment != null &&
              segment.length < bestSegment.length)) {
        bestSegment = segment;
        bestScore = score;
      } else if (score > bestScore && bestSegment == null) {
        bestSegment = segment;
        bestScore = score;
      }
    }

    if (bestSegment != null && bestSegment.isNotEmpty) {
      return bestSegment;
    }

    for (final segment in segments) {
      if (_isMeaningfulSegment(segment)) {
        return segment;
      }
    }

    if (locality.trim().isNotEmpty) {
      return locality.trim();
    }

    if (fallbackLabel.trim().isNotEmpty) {
      return fallbackLabel.trim();
    }

    return address.trim();
  }

  String? getAddressHighlightSegment(String address) {
    final segments = address
        .split(',')
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList();

    String? bestSegment;
    var bestScore = 0;

    for (final segment in segments) {
      final score = _scoreSegment(segment);
      if (score > bestScore ||
          (score == bestScore &&
              score > 0 &&
              bestSegment != null &&
              segment.length < bestSegment.length)) {
        bestSegment = segment;
        bestScore = score;
      }
    }

    if (bestScore <= 0) {
      return null;
    }

    return bestSegment;
  }

  int _scoreSegment(String segment) {
    var score = 0;
    for (final rule in _highlightPatterns) {
      if (rule.pattern.hasMatch(segment)) {
        score = rule.score;
        break;
      }
    }
    return score;
  }

  bool _isMeaningfulSegment(String segment) {
    return !RegExp(r'^\d{5,6}$').hasMatch(segment.trim());
  }
}

class _CachedResult {
  final String pincode;
  final String locality;
  final DateTime expiresAt;

  _CachedResult({
    required this.pincode,
    required this.locality,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
