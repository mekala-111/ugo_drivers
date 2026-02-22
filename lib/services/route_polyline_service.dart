import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ugo_driver/config.dart';
import 'package:ugo_driver/flutter_flow/lat_lng.dart' as latlng;

/// Fetches route polyline points from Google Directions API.
/// Returns null when API key is missing or request fails.
class RoutePolylineService {
  static final RoutePolylineService _instance = RoutePolylineService._();
  factory RoutePolylineService() => _instance;

  RoutePolylineService._();

  final Map<String, _CachedRoute> _cache = {};
  final Map<String, Future<List<latlng.LatLng>?>> _inflight = {};

  Future<List<latlng.LatLng>?> getRoutePoints({
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
    if (cached != null && !cached.isExpired) return cached.points;

    if (_inflight.containsKey(key)) return _inflight[key];

    final apiKey = Config.googleMapsApiKey;
    if (apiKey.isEmpty) return null;

    final future = () async {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$originLat,$originLng'
        '&destination=$destLat,$destLng'
        '&mode=driving'
        '&key=$apiKey',
      );

      try {
        final res = await http.get(uri);
        if (res.statusCode != 200) return null;
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] != 'OK') return null;
        final routes = data['routes'] as List<dynamic>;
        if (routes.isEmpty) return null;
        final overview = routes.first['overview_polyline'] as Map<String, dynamic>?;
        final encoded = overview?['points']?.toString();
        if (encoded == null || encoded.isEmpty) return null;
        final points = _decodePolyline(encoded);
        if (points.isEmpty) return null;
        _cache[key] = _CachedRoute(points: points);
        return points;
      } catch (_) {
        return null;
      } finally {
        _inflight.remove(key);
      }
    }();

    _inflight[key] = future;
    return future;
  }

  List<latlng.LatLng> _decodePolyline(String encoded) {
    final points = <latlng.LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(latlng.LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}

class _CachedRoute {
  final List<latlng.LatLng> points;
  final DateTime expiresAt;

  _CachedRoute({
    required this.points,
  }) : expiresAt = DateTime.now().add(const Duration(minutes: 30));

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
