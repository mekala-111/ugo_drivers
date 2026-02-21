import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ugo_driver/config.dart';

/// Driving distance (road) using Google Distance Matrix API.
/// Falls back to null when API key is missing or request fails.
class RouteDistanceService {
  static final RouteDistanceService _instance = RouteDistanceService._();
  factory RouteDistanceService() => _instance;

  RouteDistanceService._();

  final Map<String, _CachedDistance> _cache = {};
  final Map<String, Future<double?>> _inflight = {};

  Future<double?> getDrivingDistanceKm({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    if (originLat == 0 ||
        originLng == 0 ||
        destLat == 0 ||
        destLng == 0) {
      return null;
    }

    final key = '${originLat.toStringAsFixed(4)}_${originLng.toStringAsFixed(4)}_'
        '${destLat.toStringAsFixed(4)}_${destLng.toStringAsFixed(4)}';
    final cached = _cache[key];
    if (cached != null && !cached.isExpired) return cached.km;

    if (_inflight.containsKey(key)) return _inflight[key];

    final apiKey = Config.googleMapsApiKey;
    if (apiKey.isEmpty) return null;

    final future = () async {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$originLat,$originLng'
        '&destinations=$destLat,$destLng'
        '&mode=driving'
        '&key=$apiKey',
      );

      try {
        final res = await http.get(uri);
        if (res.statusCode != 200) return null;
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] != 'OK') return null;
        final rows = data['rows'] as List<dynamic>;
        if (rows.isEmpty) return null;
        final elements = rows.first['elements'] as List<dynamic>;
        if (elements.isEmpty) return null;
        final element = elements.first as Map<String, dynamic>;
        if (element['status'] != 'OK') return null;
        final distance = element['distance'] as Map<String, dynamic>;
        final meters = (distance['value'] as num).toDouble();
        final km = meters / 1000;
        _cache[key] = _CachedDistance(km: km);
        return km;
      } catch (_) {
        return null;
      } finally {
        _inflight.remove(key);
      }
    }();
    _inflight[key] = future;
    return future;
  }
}

class _CachedDistance {
  final double km;
  final DateTime expiresAt;

  _CachedDistance({
    required this.km,
  }) : expiresAt = DateTime.now().add(const Duration(hours: 6));

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
