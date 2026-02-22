import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';
import '../../config.dart';

export 'api_manager.dart' show ApiCallResponse;

// 🌐 API Base URL Configuration (dynamic via dart-define or config)
String get _baseUrl => Config.baseUrl;

class LoginCall {
  static Future<ApiCallResponse> call({
    int? mobile,
    String? fcmToken,
  }) async {
    final body = <String, dynamic>{
      'mobile_number': mobile?.toString() ?? '',
      if (fcmToken != null && fcmToken.isNotEmpty) 'fcm_token': fcmToken,
    };
    final ffApiRequestBody = json.encode(body);
    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: '$_baseUrl/api/drivers/login',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic vehicleimage(dynamic response) => getJsonField(
        response,
        r'''$.data[*].vehicle_images''',
      );
  static dynamic id(dynamic response) => getJsonField(
        response,
        r'''$.data[*].id''',
      );
  static dynamic type(dynamic response) => getJsonField(
        response,
        r'''$.data[*].vehicle_type''',
      );
  static dynamic vehiclename(dynamic response) => getJsonField(
        response,
        r'''$.data[*].vehicle_name''',
      );
}

class DriverMyReferralsCall {
  static Future<ApiCallResponse> call({
    required String token,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'driverMyReferrals',
      apiUrl: '$_baseUrl/api/driver/my-referrals',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      cache: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));

  static int totalReferrals(dynamic response) =>
      castToType<int>(getJsonField(response, r'$.data.total_referrals')) ?? 0;

  static double totalEarnings(dynamic response) =>
      double.tryParse(
          getJsonField(response, r'$.data.total_earnings')?.toString() ?? '0') ??
      0.0;

  static List<dynamic> referrals(dynamic response) =>
      (getJsonField(response, r'$.data.referrals', true) as List?) ?? [];
}

class DriverLinkReferralCall {
  static Future<ApiCallResponse> call({
    required String token,
    String? referralCode,
    String? referrerMobile,
    required int referredDriverId,
  }) async {
    final body = <String, dynamic>{
      'referred_driver_id': referredDriverId,
      if (referralCode != null && referralCode.isNotEmpty)
        'referral_code': referralCode,
      if (referrerMobile != null && referrerMobile.isNotEmpty)
        'referrer_mobile': referrerMobile,
    };

    final ffApiRequestBody = json.encode(body);

    return ApiManager.instance.makeApiCall(
      callName: 'driverLinkReferral',
      apiUrl: '$_baseUrl/api/driver/referrals/link',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));

  static dynamic data(dynamic response) => getJsonField(response, r'$.data');
}

class ChoosevehicleCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'choosevehicle',
      apiUrl: '$_baseUrl/api/vehicle-types/getall-vehicle',
      callType: ApiCallType.GET,
      headers: {}, // ✅ Clear that no auth needed
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  // Keep all your existing response parsers
  static List<dynamic>? data(dynamic response) => getJsonField(
        response,
        r'$.data',
        true,
      ) as List?;

  static List<String>? vehiclename(dynamic response) => (getJsonField(
        response,
        r'$.data[:].name',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();

  static List<int>? vehicleId(dynamic response) => (getJsonField(
        response,
        r'$.data[:].id',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'$.success',
      ));

  static List<String>? createdAt(dynamic response) => (getJsonField(
        response,
        r'$.data[:].createdAt',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();

  static List<String>? updatedAt(dynamic response) => (getJsonField(
        response,
        r'$.data[:].updatedAt',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

/// Vehicle makes (brands) - e.g. Toyota, Honda, Maruti
/// API: GET /api/vehicle-makes or /api/vehicles/makes
class GetVehicleMakesCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'getVehicleMakes',
      apiUrl: '$_baseUrl/api/vehicle-makes',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? names(dynamic response) {
    final data = getJsonField(response, r'$.data', true);
    if (data is List) {
      return data
          .map((e) => e is Map ? (e['name'] ?? e['make'] ?? e['vehicle_make'])?.toString() : e?.toString())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final arr = getJsonField(response, r'$.data[:].name', true) as List?;
    return arr?.withoutNulls.map((x) => castToType<String>(x)).withoutNulls.toList();
  }
}

/// Vehicle models - e.g. Camry, Civic, Swift
/// API: GET /api/vehicle-models or /api/vehicle-models?make_id=X
class GetVehicleModelsCall {
  static Future<ApiCallResponse> call({int? makeId, String? makeName}) async {
    var url = '$_baseUrl/api/vehicle-models';
    if (makeId != null && makeId > 0) {
      url += '?make_id=$makeId';
    } else if (makeName != null && makeName.isNotEmpty) {
      url += '?make=$makeName';
    }
    return ApiManager.instance.makeApiCall(
      callName: 'getVehicleModels',
      apiUrl: url,
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: true,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? names(dynamic response) {
    final data = getJsonField(response, r'$.data', true);
    if (data is List) {
      return data
          .map((e) => e is Map ? (e['name'] ?? e['model'] ?? e['vehicle_model'])?.toString() : e?.toString())
          .whereType<String>()
          .where((s) => s.isNotEmpty)
          .toList();
    }
    final arr = getJsonField(response, r'$.data[:].name', true) as List?;
    return arr?.withoutNulls.map((x) => castToType<String>(x)).withoutNulls.toList();
  }
}

/// Get all drivers - used for showing available captains (like Rapido).
/// Filters by is_online & is_active for "available drivers".
class GetAllDriversCall {
  static Future<ApiCallResponse> call({String? token}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getAllDrivers',
      apiUrl: '$_baseUrl/api/drivers/getall',
      callType: ApiCallType.GET,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<dynamic>? data(dynamic response) =>
      getJsonField(response, r'$.data', true) as List?;

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  /// Returns drivers that are online and active (available for rides)
  static List<dynamic> availableDrivers(dynamic response) {
    final list = data(response) ?? [];
    return list
        .where((d) =>
            (d is Map && d['is_online'] == true && d['is_active'] == true))
        .toList();
  }
}

class CreateDriverCall {
  static Future<ApiCallResponse> call({
    FFUploadedFile? profileimage,
    FFUploadedFile? licenseimage,
    FFUploadedFile? licenseFrontImage,
    FFUploadedFile? licenseBackImage,
    FFUploadedFile? aadhaarimage,
    FFUploadedFile? aadhaarFrontImage,
    FFUploadedFile? aadhaarBackImage,
    FFUploadedFile? panimage,
    FFUploadedFile? rcFrontImage,
    FFUploadedFile? rcBackImage,
    dynamic driverJson,
    dynamic vehicleJson,
    FFUploadedFile? vehicleImage,
    FFUploadedFile? registrationImage,
    FFUploadedFile? insuranceImage,
    FFUploadedFile? pollutionCertificateImage,
    String? fcmToken = '',
  }) async {
    final driver = _serializeJson(driverJson);

    final vehicle = _serializeJson(vehicleJson);

    // Do not log request body - may contain PII (driver, vehicle, tokens)
    return ApiManager.instance.makeApiCall(
      callName: 'createDriver',
      apiUrl: '$_baseUrl/api/drivers/signup-with-vehicle',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'profile_image': profileimage,
        'license_image': licenseimage,
        'license_front_image': licenseFrontImage,
        'license_back_image': licenseBackImage,
        'aadhaar_image': aadhaarimage,
        'aadhaar_front_image': aadhaarFrontImage,
        'aadhaar_back_image': aadhaarBackImage,
        'pan_image': panimage,
        'rc_front_image': rcFrontImage,
        'rc_back_image': rcBackImage,
        'driver': driver,
        'vehicle': vehicle,
        'vehicle_image': vehicleImage,
        'registration_image': registrationImage,
        'insurance_image': insuranceImage,
        'pollution_certificate_image': pollutionCertificateImage,
        'fcm_token': fcmToken,
      },
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
}

class DeleteDriverCall {
  static Future<ApiCallResponse> call({
    required String token,
    required int id,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'deleteDriver',
      apiUrl: '$_baseUrl/api/drivers/$id',
      callType: ApiCallType.DELETE,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CancelRideCall {
  static Future<ApiCallResponse> call({
    required int rideId,
    String? cancellationReason,
    String? token = '',
    String? cancelledBy = 'driver',
  }) async {
    final ffApiRequestBody = '''
{
  "ride_id": $rideId,
  "cancellation_reason": "${escapeStringForJson(cancellationReason ?? '')}",
  "cancelled_by": "${escapeStringForJson(cancelledBy ?? 'driver')}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'cancelRide',
      apiUrl: '$_baseUrl/api/rides/rides/cancel',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));
}

class CompleteRideCall {
  static Future<ApiCallResponse> call({
    required int rideId,
    required int driverId,
    required int userId,
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "ride_id": $rideId,
  "driver_id": $driverId,
  "user_id": $userId
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'completeRide',
      apiUrl: '$_baseUrl/api/drivers/complete-ride',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  static dynamic data(dynamic response) => getJsonField(response, r'$.data');
  static double? finalFare(dynamic response) {
    final d = data(response);
    if (d is Map) {
      final v = d['final_fare'] ?? d['ride_amount'] ?? d['amount'] ?? d['fare'];
      if (v != null && v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
    }
    return null;
  }
  static String? paymentMode(dynamic response) {
    final d = data(response);
    if (d is Map) {
      final v = d['payment_mode'] ?? d['payment_method'] ?? d['payment_type'];
      return v?.toString();
    }
    return null;
  }
}

class UpdateDriverCall {
  static Future<ApiCallResponse> call({
    int? id,
    String? token = '',
    bool? isonline,
    double? latitude,
    double? longitude,
    String? fcmToken,
    String? firstName,
    String? lastName,
    FFUploadedFile? profileimage,
    FFUploadedFile? licenseimage,
    FFUploadedFile? licenseFrontImage,
    FFUploadedFile? licenseBackImage,
    FFUploadedFile? aadhaarimage,
    FFUploadedFile? panimage,
    FFUploadedFile? vehicleImage,
    FFUploadedFile? registrationImage,
    FFUploadedFile? insuranceImage,
    FFUploadedFile? pollutionCertificateImage,
    String? vehicleName,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    String? registrationNumber,
    String? registrationDate,
    String? insuranceNumber,
    String? insuranceExpiryDate,
    String? pollutionExpiryDate,
    int? vehicleTypeId,
  }) async {
    // Build params dynamically - only include non-null values
    final Map<String, dynamic> params = {};

    // ✅ CRITICAL FIX: Backend expects "is_online" not "isonline"
    if (isonline != null) {
      params['is_online'] = isonline; // Changed from 'isonline' to 'is_online'
    }

    if (latitude != null) {
      params['current_location_latitude'] = latitude.toString();
    }

    if (longitude != null) {
      params['current_location_longitude'] = longitude.toString();
    }

    if (fcmToken != null && fcmToken.isNotEmpty) {
      params['fcm_token'] = fcmToken;
    }
    
    if (profileimage != null) {
      params['profile_image'] = profileimage;
    }
    
    if (firstName != null) {
      params['first_name'] = firstName;
    }
    
    if (lastName != null) {
      params['last_name'] = lastName;
    }
    
    // if (email != null) {
    //   params['email'] = email;
    // }

    if (licenseimage != null) {
      params['license_image'] = licenseimage;
    }
    if (licenseFrontImage != null) {
      params['license_front_image'] = licenseFrontImage;
    }
    if (licenseBackImage != null) {
      params['license_back_image'] = licenseBackImage;
    }

    if (aadhaarimage != null) {
      params['aadhaar_image'] = aadhaarimage;
    }

    if (panimage != null) {
      params['pan_image'] = panimage;
    }

    if (vehicleImage != null) {
      params['vehicle_image'] = vehicleImage;
    }

    if (registrationImage != null) {
      params['registration_image'] = registrationImage;
    }

    if (insuranceImage != null) {
      params['insurance_image'] = insuranceImage;
    }

    if (pollutionCertificateImage != null) {
      params['pollution_certificate_image'] = pollutionCertificateImage;
    }

    if (vehicleName != null && vehicleName.isNotEmpty) params['vehicle_name'] = vehicleName;
    if (vehicleModel != null && vehicleModel.isNotEmpty) params['vehicle_model'] = vehicleModel;
    if (vehicleColor != null && vehicleColor.isNotEmpty) params['vehicle_color'] = vehicleColor;
    if (licensePlate != null && licensePlate.isNotEmpty) params['license_plate'] = licensePlate;
    if (registrationNumber != null && registrationNumber.isNotEmpty) params['registration_number'] = registrationNumber;
    if (registrationDate != null && registrationDate.isNotEmpty) params['registration_date'] = registrationDate;
    if (insuranceNumber != null && insuranceNumber.isNotEmpty) params['insurance_number'] = insuranceNumber;
    if (insuranceExpiryDate != null && insuranceExpiryDate.isNotEmpty) params['insurance_expiry_date'] = insuranceExpiryDate;
    if (pollutionExpiryDate != null && pollutionExpiryDate.isNotEmpty) params['pollution_expiry_date'] = pollutionExpiryDate;
    if (vehicleTypeId != null && vehicleTypeId > 0) params['vehicle_type_id'] = vehicleTypeId;

    print('🚀 UpdateDriver API Request:');
    print('   URL: $_baseUrl/api/drivers/$id');
    print('   Token: ${token?.substring(0, 20)}...');
    print('   Params: $params');

    final response = await ApiManager.instance.makeApiCall(
      callName: 'updateDriver',
      apiUrl: '$_baseUrl/api/drivers/$id',
      callType: ApiCallType.PUT,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: params,
      bodyType: BodyType.MULTIPART,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    return response;
  }

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));

  static bool? isOnline(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.is_online''',
      ));
}

class DriverIdfetchCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? id,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'driverIdfetch',
      apiUrl: '$_baseUrl/api/drivers/$id',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? isonline(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.is_online''',
      ));
  static String? kycstatus(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.kyc_status''',
      ));
  static dynamic driverData(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );
  static String? referralCode(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.referral_code''',
      ));

  /// Get profile image URL
  static String? profileImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.profile_image''',
      ));

  /// Get license image URL (legacy; prefer licenseFrontImage/licenseBackImage)
  static String? licenseImage(dynamic response) {
    final v = castToType<String>(getJsonField(response, r'''$.data.license_image'''));
    if (v != null && v.isNotEmpty) return v;
    return castToType<String>(getJsonField(response, r'''$.data.license_front_image'''));
  }

  /// Get license front image URL
  static String? licenseFrontImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.license_front_image''',
      ));

  /// Get license back image URL
  static String? licenseBackImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.license_back_image''',
      ));

  /// Get license number
  static String? licenseNumber(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.license_number''',
      ));

  /// Get license expiry date
  static String? licenseExpiryDate(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.license_expiry_date''',
      ));

  /// Get aadhaar image URL (legacy; prefer aadhaarFrontImage/aadhaarBackImage)
  static String? aadhaarImage(dynamic response) {
    final v = castToType<String>(getJsonField(response, r'''$.data.aadhaar_image'''));
    if (v != null && v.isNotEmpty) return v;
    return castToType<String>(getJsonField(response, r'''$.data.aadhaar_front_image'''));
  }

  /// Get aadhaar front image URL
  static String? aadhaarFrontImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.aadhaar_front_image''',
      ));

  /// Get aadhaar back image URL
  static String? aadhaarBackImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.aadhaar_back_image''',
      ));

  /// Get PAN image URL
  static String? panImage(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.pan_image''',
      ));

  /// Get vehicle image URL
  static String? vehicleImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.vehicle_image''',
      ));

  /// Get RC image URL (legacy; prefer rcFrontImage/rcBackImage)
  static String? rcImage(dynamic response) {
    final v = castToType<String>(getJsonField(response, r'''$.data.rc_image'''));
    if (v != null && v.isNotEmpty) return v;
    return castToType<String>(getJsonField(response, r'''$.data.rc_front_image'''));
  }

  /// Get RC front image URL
  static String? rcFrontImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.rc_front_image''',
      ));

  /// Get RC back image URL
  static String? rcBackImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.rc_back_image''',
      ));

  /// Get address proof image URL
  static String? addressProof(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.address_proof''',
      ));

  /// Get driver first name
  static String? firstName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.first_name''',
      ));

  /// Get driver last name
  static String? lastName(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.last_name''',
      ));

  /// Get driver email
  static String? email(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.email''',
      ));

  /// Get driver mobile number
  static String? mobileNumber(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.mobile_number''',
      ));

  /// Get wallet balance
  static String? walletBalance(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.wallet_balance''',
      ));

  /// Get driver rating
  static String? driverRating(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.driver_rating''',
      ));

  /// Get total rides completed
  static int? totalRidesCompleted(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'''$.data.total_rides_completed''',
      ));

  /// Get total earnings
  static String? totalEarnings(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.total_earnings''',
      ));

  /// Check if driver is active
  static bool? isActive(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.data.is_active''',
      ));

  /// Get account status
  static String? accountStatus(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.account_status''',
      ));
}

class GetCitiesCall {
  static Future<ApiCallResponse> call({
    String? token,
    bool onlyActive = true,
  }) async {
    final query = onlyActive ? '?is_active=true' : '';
    return ApiManager.instance.makeApiCall(
      callName: 'getCities',
      apiUrl: '$_baseUrl/api/drivers/cities$query',
      callType: ApiCallType.GET,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      cache: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));

  static List<dynamic> cities(dynamic response) =>
      (getJsonField(response, r'$.data', true) as List?) ?? [];
}

class SetPreferredCityCall {
  static Future<ApiCallResponse> call({
    required String token,
    required int cityId,
  }) async {
    final body = json.encode({'preferred_city_id': cityId});
    return ApiManager.instance.makeApiCall(
      callName: 'setPreferredCity',
      apiUrl: '$_baseUrl/api/drivers/preferred-city',
      callType: ApiCallType.PATCH,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));
}

class SetOnlineStatusCall {
  static Future<ApiCallResponse> call({
    required String token,
    required bool isOnline,
  }) async {
    final body = json.encode({'is_online': isOnline});
    return ApiManager.instance.makeApiCall(
      callName: 'setOnlineStatus',
      apiUrl: '$_baseUrl/api/drivers/online',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));
}

class RequestPreferredCityApprovalCall {
  static Future<ApiCallResponse> call({
    required String token,
    required int requestedCityId,
  }) async {
    final body = json.encode({'requested_city_id': requestedCityId});
    return ApiManager.instance.makeApiCall(
      callName: 'requestPreferredCityApproval',
      apiUrl: '$_baseUrl/api/drivers/preferred-city/request-approval',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      body: body,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));
}

class GetWalletCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    required String token,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getWallet',
      apiUrl: '$_baseUrl/api/wallets/driver/$driverId',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
      );

  static dynamic walletBalance(dynamic response) => getJsonField(
        response,
        r'''$.data.wallet_balance''',
      );
}

class PostQRcodeCall {
  static Future<ApiCallResponse> call({
    int? driverId,
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "driver_id":$driverId
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'postQRcode',
      apiUrl: '$_baseUrl/api/qr-codes/generate',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? qrimage(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.qr_code_image''',
      ));
}

class GetDriverIncentivesCall {
  static Future<ApiCallResponse> call({
    required String token,
    required int driverId,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getDriverIncentives',
      apiUrl: '$_baseUrl/api/driver-incentives/get-incentives/$driverId',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      returnBody: true,
      cache: false,
    );
  }

  static int? currentRides(dynamic response) => castToType<int>(getJsonField(
        response,
        r'''$.data.current_rides''',
      ));

  static double? totalEarned(dynamic response) =>
      castToType<double>(getJsonField(
        response,
        r'''$.data.total_earned''',
      ));

  static List? incentiveTiers(dynamic response) => getJsonField(
        response,
        r'''$.data.incentive_tiers''',
        true,
      ) as List?;
}

class ReferralDashboardCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'referralDashboard',
      apiUrl: '$_baseUrl/api/referral-dashboard/$driverId/referral-dashboard',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static dynamic data(dynamic response) => getJsonField(
        response,
        r'$.data',
      );

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'$.success',
      ));

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'$.message',
      ));

  static dynamic totalEarnings(dynamic response) => getJsonField(
        response,
        r'$.data.total_earnings',
      );

  static dynamic totalRides(dynamic response) => getJsonField(
        response,
        r'$.data.total_rides',
      );

  static String? driverName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'$.driver_info.name',
      ));

  static int? totalProRides(dynamic response) => castToType<int>(getJsonField(
        response,
        r'$.data.my_ride_statistics.total_pro_rides',
      ));

  static int? totalNormalRides(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'$.data.my_ride_statistics.total_normal_rides',
      ));

  static dynamic totalRideEarnings(dynamic response) => getJsonField(
        response,
        r'$.data.my_ride_statistics.total_ride_earnings',
      );

  static int? totalReferredDrivers(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'$.data.referral_summary.total_referred_drivers',
      ));

  static dynamic totalReferralEarnings(dynamic response) => getJsonField(
        response,
        r'$.data.referral_summary.total_referral_earnings',
      );

  static List? referredDriversDetailed(dynamic response) => getJsonField(
        response,
        r'$.data.referred_drivers_detailed',
        true,
      ) as List?;
}

class YesterdayStatisticsCall {
  static Future<ApiCallResponse> call({
    String? driverId = '',
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'YesterdayStatistics',
      apiUrl: '$_baseUrl/api/referral-dashboard/$driverId/yesterday-statistics',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static String? driverName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'$.driver.name',
      ));

  static String? referredByName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'$.driver.referred_by.name',
      ));

  static int? referredByDriverId(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'$.driver.referred_by.driver_id',
      ));

  static int? proRidesCompleted(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'$.yesterday_statistics.my_performance.pro_rides_completed',
      ));

  static int? normalRidesCompleted(dynamic response) =>
      castToType<int>(getJsonField(
        response,
        r'$.yesterday_statistics.my_performance.normal_rides_completed',
      ));

  static dynamic rideEarnings(dynamic response) => getJsonField(
        response,
        r'$.yesterday_statistics.my_performance.ride_earnings',
      );

  static List? referrals(dynamic response) => getJsonField(
        response,
        r'$.yesterday_statistics.referrals',
        true,
      ) as List?;

  static dynamic totalCommissionEarnedYesterday(dynamic response) =>
      getJsonField(
        response,
        r'$.yesterday_statistics.total_commission_earned_yesterday',
      );
}

class NotificationHistoryCall {
  static Future<ApiCallResponse> call({
    String? token = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'notificationHistory',
      apiUrl: '$_baseUrl/api/notifications/getall',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List? notifications(dynamic response) => getJsonField(
        response,
        r'$.data.notifications',
        true,
      ) as List?;

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'$.success',
      ));

  static int? total(dynamic response) => castToType<int>(getJsonField(
        response,
        r'$.data.total',
      ));

  static int? page(dynamic response) => castToType<int>(getJsonField(
        response,
        r'$.data.page',
      ));
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print('Json serialization failed. Returning empty json.');
    }
    return isList ? '[]' : '{}';
  }
}

// 🏦 Bank Account API Call
class BankAccountCall {
  static Future<ApiCallResponse> call({
    required String driverId,
    required String token,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getBankAccount',
      apiUrl: '$_baseUrl/api/drivers/bank-account/$driverId',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  // Response parsers
  static String? bankAccountNumber(dynamic response) {
    final value = getJsonField(response, r'$.data.bank_account_number');
    return value?.toString();
  }

  static String? ifscCode(dynamic response) {
    final value = getJsonField(response, r'$.data.bank_ifsc_code');
    return value?.toString();
  }

  static String? bankName(dynamic response) {
    final value = getJsonField(response, r'$.data.bank_name');
    return value?.toString();
  }

  static String? accountHolderName(dynamic response) {
    final value = getJsonField(response, r'$.data.bank_holder_name');
    return value?.toString();
  }

  static String? fundAccountId(dynamic response) {
    final value = getJsonField(response, r'$.data.fund_account_id');
    return value?.toString();
  }

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'$.success',
      ));

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'$.message',
      ));
}

// 💸 Razorpay Payout (Withdraw) API Call
class RazorpayPayoutCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    required num amount,
    String? fundAccountId,
    required String token,
  }) async {
    final body = <String, dynamic>{
      'driver_id': driverId,
      'amount': amount,
      if (fundAccountId != null && fundAccountId.isNotEmpty)
        'fund_account_id': fundAccountId,
    };
    final ffApiRequestBody = json.encode(body);

    return ApiManager.instance.makeApiCall(
      callName: 'razorpayPayout',
      apiUrl: '$_baseUrl/api/payments/payout',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'$.success',
      ));

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'$.message',
      ));
}
class DriverEarningsCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    required String token,
    required String period,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'DriverEarnings',
      apiUrl:
          '$_baseUrl/api/drivers/earnings/driver/$driverId?period=$period',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      returnBody: true,
      cache: false,
    );
  }

  /// 🔹 Extract full data object
  static Map<String, dynamic>? data(dynamic response) =>
      getJsonField(response, r'$.data') as Map<String, dynamic>?;

  /// 🔹 Extract individual keys
  static int? totalEarnings(dynamic response) =>
      getJsonField(response, r'$.data.totalEarnings');

  static int? walletEarnings(dynamic response) =>
      getJsonField(response, r'$.data.walletEarnings');

  static int? totalRides(dynamic response) =>
      getJsonField(response, r'$.data.totalRides');

  static int? cashEarnings(dynamic response) =>
      getJsonField(response, r'$.data.cashEarnings');

  static int? onlineEarnings(dynamic response) =>
      getJsonField(response, r'$.data.onlineEarnings');

  static List<dynamic>? rides(dynamic response) =>
      getJsonField(response, r'$.data.rides', true) as List<dynamic>?;
}



// 🏦 Add Bank Account API Call (POST)
class AddBankAccountCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    required String bankAccountNumber,
    required String bankIfscCode,
    required String bankHolderName,
  }) async {
    final ffApiRequestBody = '''
{
  "driver_id": $driverId,
  "bank_account_number": "$bankAccountNumber",
  "bank_ifsc_code": "$bankIfscCode",
  "bank_holder_name": "$bankHolderName"
}''';

    // Do not log body - contains bank account details
    return ApiManager.instance.makeApiCall(
      callName: 'addBankAccount',
      apiUrl: '$_baseUrl/api/drivers/bank-account',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  // Response parsers
  static bool? success(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'$.success',
      ));

  static String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'$.message',
      ));

  static dynamic bankAccountNumber(dynamic response) => getJsonField(
        response,
        r'$.data.bank_account_number',
      );

  static dynamic ifscCode(dynamic response) => getJsonField(
        response,
        r'$.data.bank_ifsc_code',
      );

  static dynamic bankHolderName(dynamic response) => getJsonField(
        response,
        r'$.data.bank_holder_name',
      );
}

// Razorpay Bank Account Validation (IFSC lookup - no auth needed)
class RazorpayBankValidationCall {
  static Future<ApiCallResponse> call({
    String? ifscCode,
    String? accountNumber,
    String? razorpayKeyId,
    String? razorpayKeySecret,
  }) async {
    // Validate IFSC using free Razorpay IFSC API (no auth needed)
    // This will return bank details from the IFSC code
    final ifscResponse = await ApiManager.instance.makeApiCall(
      callName: 'razorpay_ifsc_lookup',
      apiUrl: 'https://ifsc.razorpay.com/${ifscCode?.toUpperCase()}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );

    // Return the IFSC validation result
    // The account number is validated locally in the widget
    return ifscResponse;
  }

  static dynamic bankName(dynamic response) =>
      getJsonField(response, r'$.BANK') ??
      getJsonField(response, r'$.bank_name') ??
      'Unknown Bank';
  static dynamic branchName(dynamic response) =>
      getJsonField(response, r'$.BRANCH');
  static dynamic ifsc(dynamic response) =>
      getJsonField(response, r'$.IFSC') ?? getJsonField(response, r'$.ifsc');
  static dynamic address(dynamic response) =>
      getJsonField(response, r'$.ADDRESS');
  static dynamic city(dynamic response) => getJsonField(response, r'$.CITY');
  static dynamic state(dynamic response) => getJsonField(response, r'$.STATE');
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}

class DriverRideHistoryCall {
  static Future<ApiCallResponse> call({
    String? token = '',
    int? id,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'driverRideHistory',
      apiUrl: '$_baseUrl/api/drivers/ride-history/$id',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
      },
      params: {},
      returnBody: true,
      cache: false,
    );
  }

  static dynamic data(dynamic response) =>
      getJsonField(response, r'''$.data''');

  /// Full data.tabs object
  static dynamic tabs(dynamic response) =>
      getJsonField(response, r'''$.data.tabs''');

  /// Completed rides: data.tabs.completed.rides
  static List<dynamic> completedRides(dynamic response) {
    final list = getJsonField(response, r'''$.data.tabs.completed.rides''');
    return list is List ? List<dynamic>.from(list) : [];
  }

  /// Cancelled rides: data.tabs.cancelled.rides
  static List<dynamic> cancelledRides(dynamic response) {
    final list = getJsonField(response, r'''$.data.tabs.cancelled.rides''');
    return list is List ? List<dynamic>.from(list) : [];
  }

  /// Missed rides: data.tabs.missed.rides
  static List<dynamic> missedRides(dynamic response) {
    final list = getJsonField(response, r'''$.data.tabs.missed.rides''');
    return list is List ? List<dynamic>.from(list) : [];
  }

  /// Summary: data.summary (totalCompletedRides, totalEarnings, etc.)
  static Map<String, dynamic>? summary(dynamic response) =>
      getJsonField(response, r'''$.data.summary''') as Map<String, dynamic>?;

  /// Total earnings from summary (INR)
  static int? totalEarnings(dynamic response) {
    final s = summary(response);
    if (s != null && s['totalEarnings'] != null) {
      final v = s['totalEarnings'];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }
    return null;
  }

  /// All rides combined (completed + cancelled + missed) - for backwards compat
  static List rides(dynamic response) {
    final completed = completedRides(response);
    final cancelled = cancelledRides(response);
    final missed = missedRides(response);
    return [...completed, ...cancelled, ...missed];
  }
}

// 📅 DAILY INCENTIVES
// GET /api/driver-incentives/daily-incentives?driver_id=X&date=YYYY-MM-DD
// ─────────────────────────────────────────────────────────────
// ============================================================
// ADD THIS CLASS TO YOUR api_calls.dart FILE
// ============================================================
// Single unified incentives API
// Base: /api/driver-incentives/daily-incentives/{driverId}
//
//   ?date=2026-02-11              → particular date
//   ?type=weekly                  → current week
//   ?type=monthly                 → current month
//   ?from=2026-02-01&to=2026-02-20 → custom range
// ============================================================

class DriverIncentivesCall {
  static Future<ApiCallResponse> call({
    required String token,
    required int driverId,
    String? date,   // particular date  "2026-02-11"
    String? type,   // "weekly" | "monthly"
    String? from,   // range start      "2026-02-01"
    String? to,     // range end        "2026-02-20"
  }) async {
    final Map<String, String> queryParams = {};
    if (date != null) queryParams['date'] = date;
    if (type != null) queryParams['type'] = type;
    if (from != null) queryParams['from'] = from;
    if (to != null) queryParams['to'] = to;

    final queryString = Uri(queryParameters: queryParams).query;
    final url =
        '$_baseUrl/api/driver-incentives/daily-incentives/$driverId'
        '${queryString.isNotEmpty ? '?$queryString' : ''}';

    debugPrint('📡 DriverIncentivesCall → $url');

    return ApiManager.instance.makeApiCall(
      callName: 'DriverIncentives',
      apiUrl: url,
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  // ── Response Parsers ──────────────────────────────────────

  static List<dynamic> incentiveList(dynamic response) =>
      (getJsonField(response, r'$.data', true) as List?) ?? [];

  static bool? success(dynamic response) =>
      castToType<bool>(getJsonField(response, r'$.success'));

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.message'));

  static String? filterStartDate(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.filter.startDate'));

  static String? filterEndDate(dynamic response) =>
      castToType<String>(getJsonField(response, r'$.filter.endDate'));

  // ── Per-item Helpers (use when iterating incentiveList) ──

  static int itemTargetRides(dynamic item) =>
      castToType<int>(getJsonField(item, r'$.target_rides')) ?? 0;

  static int itemCompletedRides(dynamic item) =>
      castToType<int>(getJsonField(item, r'$.completed_rides')) ?? 0;

  static double itemRewardAmount(dynamic item) =>
      double.tryParse(
          getJsonField(item, r'$.reward_amount')?.toString() ?? '0') ?? 0.0;

  static String itemProgressStatus(dynamic item) =>
      castToType<String>(getJsonField(item, r'$.progress_status')) ?? 'ongoing';

  static bool itemIsCompleted(dynamic item) =>
      itemProgressStatus(item) == 'completed';

  static String itemIncentiveName(dynamic item) =>
      castToType<String>(getJsonField(item, r'$.incentive.name')) ?? 'Incentive';

  static String itemRecurrenceType(dynamic item) =>
      castToType<String>(
          getJsonField(item, r'$.incentive.recurrence_type')) ?? '';

  static String itemStartTime(dynamic item) =>
      castToType<String>(getJsonField(item, r'$.incentive.start_time')) ?? '';

  static String itemEndTime(dynamic item) =>
      castToType<String>(getJsonField(item, r'$.incentive.end_time')) ?? '';

  // ── Convenience filters ──
  /// Returns true if the incentive is currently running/active (not completed/locked)
  static bool itemIsRunning(dynamic item) =>
      itemProgressStatus(item) == 'ongoing';

  /// Filters a list of incentives to return only currently running ones
  static List<dynamic> filterRunningIncentives(List<dynamic> incentives) =>
      incentives.where((item) => itemIsRunning(item)).toList();
}

class VehiclePricingCall {
  static Future<ApiCallResponse> call({
    required int driverId,
    required String token,
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'vehiclePricing',
      apiUrl:
          '$_baseUrl/api/vehicle-types/drivers/$driverId/vehicle-pricing',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      params: {},
      returnBody: true,
      cache: false,
    );
  }

  /// Full pricing object
  static dynamic pricing(dynamic response) =>
      getJsonField(response, r'''$.data.pricing''');

  /// Normal Ride
  static dynamic normal(dynamic response) =>
      getJsonField(response, r'''$.data.pricing.normal''');

  /// Pro Ride
  static dynamic pro(dynamic response) =>
      getJsonField(response, r'''$.data.pricing.pro''');

  /// Vehicle Name
  static String? vehicleName(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.vehicle_type.name''',
      ));

  /// Vehicle Image
  static String? vehicleImage(dynamic response) {
    final path = castToType<String>(getJsonField(
      response,
      r'''$.data.vehicle_type.image''',
    ));

    if (path == null) return null;

    if (path.startsWith('/')) {
      return '$_baseUrl$path';
    }

    return path;
  }


}

