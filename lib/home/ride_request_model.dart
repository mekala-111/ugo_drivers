// // lib/models/ride_request_model.dart

// class RideRequest {
//   final int id;
//   final int userId;
//   final int? driverId;
//   final String status;
//   final String pickupAddress;
//   final String dropAddress;
//   final double? distance;
//   final double? estimatedFare;
//   final DateTime? createdAt;

//   RideRequest({
//     required this.id,
//     required this.userId,
//     this.driverId,
//     required this.status,
//     required this.pickupAddress,
//     required this.dropAddress,
//     this.distance,
//     this.estimatedFare,
//     this.createdAt,
//   });

//   factory RideRequest.fromJson(Map<String, dynamic> json) {
//     return RideRequest(
//       id: json['id'],
//       userId: json['user_id'] ?? 0,
//       driverId: json['driver_id'],
//       status: json['ride_status'] ?? 'SEARCHING',
//       pickupAddress: json['pickup_location_address'] ?? 'Unknown Pickup',
//       dropAddress: json['drop_location_address'] ?? 'Unknown Dropoff',

//       // 🛡️ SAFELY PARSE NUMBERS (Fixes your crash)
//       distance: _parseToDouble(json['ride_distance_km']),
//       estimatedFare: _parseToDouble(json['estimated_fare']),

//       createdAt:
//           DateTime.tryParse(json['created_at'] ?? json['createdAt'] ?? ''),
//     );
//   }

//   // 🔧 HELPER: Handles both "80.00" (String) and 80.00 (Double)
//   static double? _parseToDouble(dynamic value) {
//     if (value == null) return null;
//     if (value is num) return value.toDouble();
//     if (value is String) return double.tryParse(value);
//     return null;
//   }
// }

// lib/models/ride_request_model.dart
class RideRequest {
  final int id;
  final int userId;
  final int? driverId;
  final String status;

  final String pickupAddress;
  final String dropAddress;

  // 📍 LOCATION
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;

  // 💰 RIDE INFO
  final double? distance;
  final double? estimatedFare;

  // ⏱ TIME
  final DateTime? createdAt;

  // 🔐 OTP (if already added)
  final String? otp;
  final String? otpHash;
  final DateTime? otpExpiresAt;
  final int otpAttempts;
  final DateTime? otpVerifiedAt;

  // ✅ UI-ONLY STATE (NEW)
  final bool isAtPickup;

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
    this.createdAt,

    // OTP
    this.otp,
    this.otpHash,
    this.otpExpiresAt,
    this.otpAttempts = 0,
    this.otpVerifiedAt,

    // UI-only
    this.isAtPickup = false, // ✅ DEFAULT
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      driverId: json['driver_id'],
      status: json['ride_status'] ?? 'SEARCHING',

      pickupAddress: json['pickup_location_address'] ?? 'Unknown Pickup',
      dropAddress: json['drop_location_address'] ?? 'Unknown Dropoff',

      pickupLat: _parseToDouble(json['pickup_latitude']) ?? 0.0,
      pickupLng: _parseToDouble(json['pickup_longitude']) ?? 0.0,
      dropLat: _parseToDouble(json['drop_latitude']) ?? 0.0,
      dropLng: _parseToDouble(json['drop_longitude']) ?? 0.0,

      distance: _parseToDouble(json['ride_distance_km']),
      estimatedFare: _parseToDouble(json['estimated_fare']),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),

      // OTP
      otp: json['otp']?.toString(),
      otpHash: json['otp_hash']?.toString(),
      otpExpiresAt: DateTime.tryParse(json['otp_expires_at'] ?? ''),
      otpAttempts: json['otp_attempts'] ?? 0,
      otpVerifiedAt: DateTime.tryParse(json['otp_verified_at'] ?? ''),

      // ⚠️ NOT from backend
      isAtPickup: false,
    );
  }

  // 🛡 SAFE PARSER
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ✅ STRONGLY RECOMMENDED (for updates)
  RideRequest copyWith({
    String? status,
    bool? isAtPickup,
  }) {
    return RideRequest(
      id: id,
      userId: userId,
      driverId: driverId,
      status: status ?? this.status,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
      distance: distance,
      estimatedFare: estimatedFare,
      createdAt: createdAt,
      otp: otp,
      otpHash: otpHash,
      otpExpiresAt: otpExpiresAt,
      otpAttempts: otpAttempts,
      otpVerifiedAt: otpVerifiedAt,
      isAtPickup: isAtPickup ?? this.isAtPickup,
    );
  }
}

