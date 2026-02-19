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
  }) async {
    final ffApiRequestBody = '''
{
  "mobile_number": "${mobile}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: '\${Config.baseUrl}/api/drivers/login',
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
      apiUrl: '\${Config.baseUrl}/api/vehicle-types/getall-vehicle',
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
    print("📍 URL: $_baseUrl/api/drivers/signup-with-vehicle");
    print("📦 Body Type: ${BodyType.MULTIPART}");
    print("\n📄 FORM FIELDS:");
    print("  • driver: $driver");
    print("  • vehicle: $vehicle");
    print("  • fcm_token: $fcmToken");

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
}

class UpdateDriverCall {
  static Future<ApiCallResponse> call({
    int? id,
    String? token = '',
    bool? isonline,
    double? latitude,
    double? longitude,
    String? firstName,
    String? lastName,
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
    print("   URL: $_baseUrl/api/drivers/$id");
    print("   Token: ${token?.substring(0, 20)}...");
    print("   Params: $params");

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
      apiUrl: '$_baseUrl/api/drivers/${id}',
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
  "driver_id":${driverId}
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'postQRcode',
      apiUrl: '$_baseUrl/api/qr-codes/generate',
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
      print("Json serialization failed. Returning empty json.");
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
  "driver_id": ${driverId},
  "bank_account_number": "${bankAccountNumber}",
  "bank_ifsc_code": "${bankIfscCode}",
  "bank_holder_name": "${bankHolderName}"
}''';

    print("🚀 AddBankAccount API Request:");
    print("📍 URL: $_baseUrl/api/drivers/bank-account");
    print("📦 Body: $ffApiRequestBody");

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

// Razorpay Bank Account Validation
class RazorpayBankValidationCall {
  static Future<ApiCallResponse> call({
    String? ifscCode,
    String? accountNumber,
    String? razorpayKeyId = 'rzp_test_SAvHgTPEoPnNo7',
    String? razorpayKeySecret = 'mpSkf5lOQxSjcPAmzl4T54mv',
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

  static List rides(dynamic response) =>
      getJsonField(response, r'''$.data.rides''') ?? [];

  static String? totalEarnings(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.data.total_earnings'''));
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

    if (path.startsWith("/")) {
      return '$_baseUrl$path';
    }

    return path;
  }


}

