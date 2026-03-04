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
    if (apiKey.isEmpty) {
      print('❌ Google Maps API key is EMPTY! Set via --dart-define=GOOGLE_MAPS_API_KEY=xxx');
      return null;
    }

    final future = () async {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$originLat,$originLng'
        '&destinations=$destLat,$destLng'
        '&mode=driving'
        '&key=$apiKey',
      );

      print('🌐 Calling Google Distance Matrix API: $originLat,$originLng → $destLat,$destLng');

      try {
        final res = await http.get(uri);
        print('📡 API Response Status: ${res.statusCode}');
        
        if (res.statusCode != 200) {
          print('❌ API returned non-200 status: ${res.statusCode}');
          print('Response: ${res.body}');
          return null;
        }
        
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        print('📦 API Response: ${data['status']}');
        
        if (data['status'] != 'OK') {
          print('❌ API status not OK: ${data['status']}');
          print('Error message: ${data['error_message'] ?? 'none'}');
          return null;
        }
        
        final rows = data['rows'] as List<dynamic>;
        if (rows.isEmpty) {
          print('❌ No rows in response');
          return null;
        }
        
        final elements = rows.first['elements'] as List<dynamic>;
        if (elements.isEmpty) {
          print('❌ No elements in response');
          return null;
        }
        
        final element = elements.first as Map<String, dynamic>;
        if (element['status'] != 'OK') {
          print('❌ Element status not OK: ${element['status']}');
          return null;
        }
        
        final distance = element['distance'] as Map<String, dynamic>;
        final meters = (distance['value'] as num).toDouble();
        final km = meters / 1000;
        
        print('✅ Google Maps returned: ${km.toStringAsFixed(2)}km (${meters.round()}m)');
        
        _cache[key] = _CachedDistance(km: km);
        return km;
      } catch (e) {
        print('💥 Exception calling Google Maps API: $e');
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
