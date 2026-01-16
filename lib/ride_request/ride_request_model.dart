// lib/models/ride_request_model.dart

class RideRequest {
  final int id;
  final int userId;
  final int? driverId;
  final String status;
  final String pickupAddress;
  final String dropAddress;
  final double? distance;
  final double? estimatedFare;
  final DateTime? createdAt;

  RideRequest({
    required this.id,
    required this.userId,
    this.driverId,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    this.distance,
    this.estimatedFare,
    this.createdAt,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      driverId: json['driver_id'],
      status: json['ride_status'] ?? 'SEARCHING',
      pickupAddress: json['pickup_location_address'] ?? 'Unknown Pickup',
      dropAddress: json['drop_location_address'] ?? 'Unknown Dropoff',

      // 🛡️ SAFELY PARSE NUMBERS (Fixes your crash)
      distance: _parseToDouble(json['ride_distance_km']),
      estimatedFare: _parseToDouble(json['estimated_fare']),

      createdAt:
          DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? ''),
    );
  }

  // 🔧 HELPER: Handles both "80.00" (String) and 80.00 (Double)
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
