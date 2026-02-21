import 'package:geocoding/geocoding.dart';

/// Reverse geocoding: get pincode and locality from lat/lon (not from address string).
class LocationGeocodeService {
  static final LocationGeocodeService _instance = LocationGeocodeService._();
  factory LocationGeocodeService() => _instance;

  LocationGeocodeService._();

  final Map<String, _CachedResult> _cache = {};

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
