import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

class LoginCall {
  static Future<ApiCallResponse> call({
    int? mobile,
  }) async {
    final ffApiRequestBody = '''
{
  "mobile_number": "${mobile}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: 'https://ugo-api.icacorp.org/api/drivers/login',
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

class ChoosevehicleCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'choosevehicle',
      apiUrl: 'https://ugo-api.icacorp.org/api/vehicle-types/getall-vehicle',
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

    print("🚀 CreateDriver API Request}");
    print("🚀 CreateDriver API Request");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print(
        "📍 URL: https://ugo-api.icacorp.org/api/drivers/signup-with-vehicle");
    print("📦 Body Type: ${BodyType.MULTIPART}");
    print("\n📄 FORM FIELDS:");
    print("  • driver: $driver");
    print("  • vehicle: $vehicle");
    print("  • fcm_token: $fcmToken");

    return ApiManager.instance.makeApiCall(
      callName: 'createDriver',
      apiUrl: 'https://ugo-api.icacorp.org/api/drivers/signup-with-vehicle',
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

class UpdateDriverCall {
  static Future<ApiCallResponse> call({
    int? id,
    String? token = '',
    bool? isonline,
    double? latitude,
    double? longitude,
    FFUploadedFile? profileimage,
    FFUploadedFile? licenseimage,
    FFUploadedFile? aadhaarimage,
    FFUploadedFile? panimage,
    FFUploadedFile? vehicleImage,
    FFUploadedFile? registrationImage,
    FFUploadedFile? insuranceImage,
    FFUploadedFile? pollutionCertificateImage,
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
    if (profileimage != null) {
      params['profile_image'] = profileimage;
    }

    if (licenseimage != null) {
      params['license_image'] = licenseimage;
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

    print("🚀 UpdateDriver API Request:");
    print("   URL: https://ugo-api.icacorp.org/api/drivers/$id");
    print("   Token: ${token?.substring(0, 20)}...");
    print("   Params: $params");

    final response = await ApiManager.instance.makeApiCall(
      callName: 'updateDriver',
      apiUrl: 'https://ugo-api.icacorp.org/api/drivers/$id',
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

    print("📥 UpdateDriver API Response:");
    print("   Status: ${response.statusCode}");
    print("   Success: ${response.succeeded}");
    print("   Body: ${response.jsonBody}");

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
      apiUrl: 'https://ugo-api.icacorp.org/api/drivers/${id}',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': 'Bearer ${token}',
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

  /// Get license image URL
  static String? licenseImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.license_image''',
      ));

  /// Get aadhaar image URL
  static String? aadhaarImage(dynamic response) =>
      castToType<String>(getJsonField(
        response,
        r'''$.data.aadhaar_image''',
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

  /// Get RC image URL
  static String? rcImage(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.rc_image''',
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

class PostQRcodeCall {
  static Future<ApiCallResponse> call({
    int? driverId,
    String? token = '',
  }) async {
    final ffApiRequestBody = '''
{
  "driver_id":${driverId}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'postQRcode',
      apiUrl: 'https://ugo-api.icacorp.org/api/qr-codes/generate',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': 'Bearer ${token}',
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
      apiUrl:
          'https://ugo-api.icacorp.org/api/driver/incentives/$driverId', // Update with your actual endpoint
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
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
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
