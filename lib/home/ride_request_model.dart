import '../models/ride_status.dart';
import '../models/payment_mode.dart';

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
  final double? finalFare;
  final PaymentMode paymentMode;

  // 🚗 VEHICLE TYPE (to filter rides by driver vehicle)
  final String? vehicleType;
  final int? vehicleTypeId;

  /// Pickup city ID (zone) - used to filter rides by driver's preferred city
  final int? pickupCityId;

  /// 4-digit OTP for ride start verification (from backend if provided)


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
    this.finalFare,
    this.paymentMode = PaymentMode.unknown,
    this.firstName,
    this.mobileNumber,
    this.vehicleType,
    this.vehicleTypeId,
    this.pickupCityId,
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
      estimatedFare: _parseToDouble(json['estimated_fare']) ?? _parseToDouble(json['fare']),
      finalFare: _parseToDouble(json['final_fare']) ??
          _parseToDouble(json['ride_amount']) ??
          _parseToDouble(json['amount']),
      paymentMode: parsePaymentMode(
        json['payment_mode'] ?? json['payment_method'] ?? json['payment_type'],
      ),
      vehicleType: json['vehicle_type'] ??
          json['rideType'] ??
          json['ride_type'] ??
          (json['vehicle'] != null ? json['vehicle']['vehicle_type'] : null),
      vehicleTypeId: _parseToInt(json['vehicle_type_id']) ??
          _parseToInt(json['vehicleTypeId']) ??
          _parseToInt(json['admin_vehicle_id']) ??
          (json['vehicle'] != null ? _parseToInt(json['vehicle']['vehicle_type_id']) : null),
      pickupCityId: _parseToInt(json['pickup_city_id']),
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
    double? finalFare,
    PaymentMode? paymentMode,
    String? otp,
    String? vehicleType,
    int? vehicleTypeId,
    int? pickupCityId,
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
      finalFare: finalFare ?? this.finalFare,
      paymentMode: paymentMode ?? this.paymentMode,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
      pickupCityId: pickupCityId ?? this.pickupCityId,
    );
  }

  // 🔧 Helper to handle String ("17.44") or Double (17.44) safely
  static double? _parseToDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.isEmpty || value == 'null') return null;
      return double.tryParse(value);
    }
    return null;
  }

  static int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      if (value.isEmpty || value == 'null') return null;
      return int.tryParse(value);
    }
    return null;
  }
}