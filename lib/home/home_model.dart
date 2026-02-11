import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_google_map.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'home_widget.dart' show HomeWidget;
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (driverIdfetch)] action in home widget.
  ApiCallResponse? userDetails;
  // Stores action output result for [Backend Call - API (postQRcode)] action in home widget.
  ApiCallResponse? postQR;
  // State field(s) for Switch widget.
  bool? switchValue;
  // Stores action output result for [Backend Call - API (updateDriver)] action in Switch widget.
  ApiCallResponse? updatedriver;
  // Stores action output result for [Backend Call - API (updateDriver)] action in Switch widget.
  ApiCallResponse? apiResultrv8;
  // State field(s) for GoogleMap widget.
  LatLng? googleMapsCenter;
  final googleMapsController = Completer<GoogleMapController>();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}

// --- RideRequest Model ---
class RideRequest {
  final int id;
  final String status;
  final String pickupAddress;
  final String dropAddress;
  final double? estimatedFare;
  final double? distance;
  final int? driverId;
  final String? qrCode;
  final int? rideId;
  final int? userId;
  final String? driverName;
  final String? userIdName;
  final String? first_name;
  final String ?   mobile_number;

  // ✅ Added Coordinates
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;

  RideRequest({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    this.estimatedFare,
    this.distance,
    this.driverId,
    this.qrCode,
    this.rideId,
    this.userId,
    this.driverName,
    this.userIdName,
    this.first_name,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng, this.mobile_number,
  });

  factory RideRequest.fromJson(Map<String, dynamic> json) {
    return RideRequest(
      id: json['id'] ?? 0,
      status: json['ride_status'] ?? 'SEARCHING',
      pickupAddress: json['pickup_location_address'] ?? 'Unknown Pickup',
      dropAddress: json['drop_location_address'] ?? 'Unknown Drop',
      estimatedFare: double.tryParse(json['estimated_fare']?.toString() ?? '0'),
      distance: double.tryParse(json['ride_distance_km']?.toString() ?? '0'),
      driverId: json['driver_id'],

      // ✅ Parse Name correctly (usually nested in 'user' object)
      first_name: json['user'] != null ? json['user']['first_name'] : json['first_name'],

      // ✅ Parse Coordinates
      pickupLat: double.tryParse(json['pickup_location_latitude']?.toString() ?? '0'),
      pickupLng: double.tryParse(json['pickup_location_longitude']?.toString() ?? '0'),
      dropLat: double.tryParse(json['drop_location_latitude']?.toString() ?? '0'),
      dropLng: double.tryParse(json['drop_location_longitude']?.toString() ?? '0'),
    );
  }

  RideRequest copyWith({String? status}) {
    return RideRequest(
      id: id,
      status: status ?? this.status,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      estimatedFare: estimatedFare,
      distance: distance,
      driverId: driverId,
      first_name: first_name,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
    );
  }
}