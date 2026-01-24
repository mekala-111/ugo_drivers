class RideRequest {
  final int id;
  final int userId;
  final int? driverId;
  final String status;

  final String pickupAddress;
  final String dropAddress;

  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;

  final double? distance;
  final double? estimatedFare;
  final DateTime? createdAt;

  final String? otp;
  final String? otpHash;
  final DateTime? otpExpiresAt;
  final int otpAttempts;
  final DateTime? otpVerifiedAt;

  // USER INFO
  final String? userName;
  final String? userPhone;
  final String? userRating;
  final String? userPhoto;

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
    this.otp,
    this.otpHash,
    this.otpExpiresAt,
    this.otpAttempts = 0,
    this.otpVerifiedAt,
    this.userName,
    this.userPhone,
    this.userRating,
    this.userPhoto,
    this.isAtPickup = false,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    // Extract user data if nested
    final userData = json['user'] ?? json['passenger'] ?? {};
    
    return RideRequest(
      id: _parseInt(json['id']) ?? 0,
      userId: _parseInt(json['user_id']) ?? _parseInt(userData['id']) ?? 0,
      driverId: _parseInt(json['driver_id']),
      status: (json['ride_status'] ?? json['status'] ?? 'SEARCHING').toString().toUpperCase().trim(),

      pickupAddress: json['pickup_location_address'] ?? 'Unknown Pickup',
      dropAddress: json['drop_location_address'] ?? 'Unknown Dropoff',

      pickupLat: _parseDouble(json['pickup_latitude']) ?? 0.0,
      pickupLng: _parseDouble(json['pickup_longitude']) ?? 0.0,
      dropLat: _parseDouble(json['drop_latitude']) ?? 0.0,
      dropLng: _parseDouble(json['drop_longitude']) ?? 0.0,

      distance: _parseDouble(json['ride_distance_km']),
      estimatedFare: _parseDouble(json['estimated_fare']),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),

      otp: json['otp']?.toString(),
      otpHash: json['otp_hash']?.toString(),
      otpExpiresAt: DateTime.tryParse(json['otp_expires_at'] ?? ''),
      otpAttempts: _parseInt(json['otp_attempts']) ?? 0,
      otpVerifiedAt: DateTime.tryParse(json['otp_verified_at'] ?? ''),

      // USER FIELDS
      userName: userData['first_name'] ?? userData['name'] ?? 'Customer',
      userPhone: userData['mobile_number'] ?? userData['phone'],
      userRating: userData['rating']?.toString() ?? '4.8',
      userPhoto: userData['profile_image'],

      isAtPickup: false,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

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
      userName: userName,
      userPhone: userPhone,
      userRating: userRating,
      userPhoto: userPhoto,
      isAtPickup: isAtPickup ?? this.isAtPickup,
    );
  }
}
