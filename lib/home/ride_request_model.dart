
import '../models/ride_status.dart';

class RideRequest {
  final int id;
  final int userId;
  final int? driverId;
  final RideStatus status;
  final String pickupAddress;
  final String dropAddress;

  // ✅ Added these back so the UI doesn't crash
  final String? firstName;
  final String? mobileNumber;

  // 📍 LOCATION (Coordinates)
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;

  // 💰 RIDE INFO
  final double? distance;
  final double? estimatedFare;

  RideRequest({
    required this.id,
    required this.userId,
    this.driverId,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    this.distance,
    this.estimatedFare,
    this.firstName,
    this.mobileNumber,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      driverId: json['driver_id'],
      status: RideStatusX.fromString(json['ride_status']?.toString()),

      // ✅ Name Handling: Checks 'user' object OR root level
      firstName: json['user'] != null
          ? json['user']['first_name']
          : (json['first_name'] ?? 'Passenger'),

      mobileNumber: json['user'] != null
          ? json['user']['mobile_number']
          : json['mobile_number'],

      pickupAddress: json['pickup_location_address'] ?? json['pickup_address'] ?? 'Unknown Pickup',
      dropAddress: json['drop_location_address'] ?? json['drop_address'] ?? 'Unknown Dropoff',

      // 🛡️ ROBUST COORDINATE PARSING (Checks ALL possible keys)
      // This ensures we never get 0.0 if the backend sends data
      pickupLat: _parseToDouble(json['pickup_location_latitude']) ??
          _parseToDouble(json['pickup_latitude']) ??
          0.0,

      pickupLng: _parseToDouble(json['pickup_location_longitude']) ??
          _parseToDouble(json['pickup_longitude']) ??
          0.0,

      dropLat: _parseToDouble(json['drop_location_latitude']) ??
          _parseToDouble(json['drop_latitude']) ??
          0.0,

      dropLng: _parseToDouble(json['drop_location_longitude']) ??
          _parseToDouble(json['drop_longitude']) ??
          0.0,

      distance: _parseToDouble(json['ride_distance_km']),
      estimatedFare: _parseToDouble(json['estimated_fare']),
    );
  }


  /// Provide a copy where the status can be updated either via RideStatus or raw string
  RideRequest copyWith({
    int? id,
    int? userId,
    int? driverId,
    RideStatus? status,
    String? pickupAddress,
    String? dropAddress,
    String? firstName,
    String? mobileNumber,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
    double? distance,
    double? estimatedFare,
  }) {
    return RideRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      firstName: firstName ?? this.firstName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      dropLat: dropLat ?? this.dropLat,
      dropLng: dropLng ?? this.dropLng,
      distance: distance ?? this.distance,
      estimatedFare: estimatedFare ?? this.estimatedFare,
    );
  }

  // 🔧 Helper to handle String ("17.44") or Double (17.44) safely
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty || value == "null") return null;
      return double.tryParse(value);
    }
    return null;
  }
}