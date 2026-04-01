import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:ugo_driver/config.dart';

/// Driving distance (road) aligned with navigation route as closely as possible.
/// Primary source: Google Directions API route legs distance.
/// Fallback: Google Distance Matrix API.
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
    if (originLat == 0 || originLng == 0 || destLat == 0 || destLng == 0) {
      return null;
    }

    // GPS jitter was changing the key every tick (4dp origin), causing a storm
    // of Directions/Matrix calls from [FutureBuilder] rebuilds on the ride card.
    // Coarser origin + finer destination keeps cache useful for "driver → point".
    final key =
        '${originLat.toStringAsFixed(3)}_${originLng.toStringAsFixed(3)}_'
        '${destLat.toStringAsFixed(4)}_${destLng.toStringAsFixed(4)}';

    final cached = _cache[key];
    if (cached != null && !cached.isExpired) return cached.km;

    if (_inflight.containsKey(key)) return _inflight[key]!;

    // Use only the key from this project: Firebase Remote Config (parameter: google_maps_api_key)
    final apiKeySync = Config.googleMapsApiKey;
    final future = () async {
      try {
        final straightM = Geolocator.distanceBetween(
          originLat,
          originLng,
          destLat,
          destLng,
        );
        // Same building / GPS jitter: no Google call; cache so rebuilds do not retry.
        if (straightM <= 120) {
          final km = straightM <= 1 ? 0.05 : straightM / 1000;
          _cache[key] = _CachedDistance(km: km);
          return km;
        }

        String apiKey = apiKeySync;
        if (apiKey.isEmpty) {
          apiKey = await Config.getGoogleMapsApiKey();
        }
        if (apiKey.isEmpty) {
          debugPrint(
              '❌ Google Maps API key is EMPTY. Set "google_maps_api_key" in Firebase Remote Config and publish.');
          final km = straightM / 1000;
          if (km > 0) {
            _cache[key] = _CachedDistance(km: km);
            return km;
          }
          return null;
        }

        final directionsKm = await _getDirectionsDistanceKm(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          apiKey: apiKey,
        );

        if (directionsKm != null && directionsKm > 0) {
          _cache[key] = _CachedDistance(km: directionsKm);
          return directionsKm;
        }

        final matrixKm = await _getDistanceMatrixKm(
          originLat: originLat,
          originLng: originLng,
          destLat: destLat,
          destLng: destLng,
          apiKey: apiKey,
        );
        if (matrixKm != null && matrixKm > 0) {
          _cache[key] = _CachedDistance(km: matrixKm);
          return matrixKm;
        }

        // APIs returned zero / OK with no usable distance — cache straight-line once.
        final km = straightM / 1000;
        if (km > 0) {
          _cache[key] = _CachedDistance(km: km);
          return km;
        }
        _cache[key] = _CachedDistance(km: 0.05);
        return 0.05;
      } catch (e) {
        debugPrint('💥 Exception calling Google Maps API: $e');
        final straightM = Geolocator.distanceBetween(
          originLat,
          originLng,
          destLat,
          destLng,
        );
        final km = straightM / 1000;
        if (km > 0) {
          _cache[key] = _CachedDistance(km: km);
          return km;
        }
        return null;
      } finally {
        _inflight.remove(key);
      }
    }();
    _inflight[key] = future;
    return future;
  }

  Future<double?> _getDirectionsDistanceKm({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String apiKey,
  }) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$originLat,$originLng'
      '&destination=$destLat,$destLng'
      '&mode=driving'
      '&departure_time=now'
      '&traffic_model=best_guess'
      '&key=$apiKey',
    );

    debugPrint(
        '🧭 Calling Google Directions API: $originLat,$originLng → $destLat,$destLng');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      debugPrint('❌ Directions non-200: ${res.statusCode}');
      return null;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') {
      debugPrint('❌ Directions status: ${data['status']}');
      if (data['error_message'] != null) {
        debugPrint('❌ Directions error: ${data['error_message']}');
      }
      return null;
    }

    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;

    final firstRoute = routes.first as Map<String, dynamic>;
    final legs = firstRoute['legs'] as List<dynamic>?;
    if (legs == null || legs.isEmpty) return null;

    double meters = 0;
    for (final leg in legs) {
      final legMap = leg as Map<String, dynamic>;
      final distance = legMap['distance'] as Map<String, dynamic>?;
      if (distance == null || distance['value'] == null) continue;
      meters += (distance['value'] as num).toDouble();
    }

    if (meters <= 0) return null;

    final km = meters / 1000;
    debugPrint(
        '✅ Directions returned: ${km.toStringAsFixed(2)}km (${meters.round()}m)');
    return km;
  }

  Future<double?> _getDistanceMatrixKm({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required String apiKey,
  }) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/distancematrix/json'
      '?origins=$originLat,$originLng'
      '&destinations=$destLat,$destLng'
      '&mode=driving'
      '&departure_time=now'
      '&traffic_model=best_guess'
      '&key=$apiKey',
    );

    debugPrint(
        '🌐 Calling Google Distance Matrix API: $originLat,$originLng → $destLat,$destLng');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      debugPrint('❌ Distance Matrix non-200: ${res.statusCode}');
      return null;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] != 'OK') {
      debugPrint('❌ Distance Matrix status: ${data['status']}');
      if (data['error_message'] != null) {
        debugPrint('❌ Distance Matrix error: ${data['error_message']}');
      }
      return null;
    }

    final rows = data['rows'] as List<dynamic>?;
    if (rows == null || rows.isEmpty) return null;

    final elements =
        (rows.first as Map<String, dynamic>)['elements'] as List<dynamic>?;
    if (elements == null || elements.isEmpty) return null;

    final element = elements.first as Map<String, dynamic>;
    if (element['status'] != 'OK') {
      if (kDebugMode) {
        debugPrint('❌ Distance Matrix element status: ${element['status']}');
      }
      return null;
    }

    final distance = element['distance'] as Map<String, dynamic>?;
    if (distance == null || distance['value'] == null) return null;

    final meters = (distance['value'] as num).toDouble();
    final km = meters / 1000;
    debugPrint(
        '✅ Distance Matrix returned: ${km.toStringAsFixed(2)}km (${meters.round()}m)');
    return km;
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
