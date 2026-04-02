import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '/auth/login_timestamp.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/notifications/ride_chat_in_app_banner.dart';
import '/services/document_verification_service.dart';

/// Submits driver signup after profile/vehicle/city/earning preferences, without
/// requiring the legacy onboarding screen. Documents can be completed later from Home.
class DriverSignupSubmitService {
  DriverSignupSubmitService._();

  /// Public for other callers (e.g. [UpdateDriverCall] multipart date fields).
  static String formatDateForApi(String value) => _toApiDate(value);

  static String _toApiDate(String value) {
    final v = value.trim();
    if (v.isEmpty) return v;
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(v);
    if (m != null) {
      final d = m.group(1)!.padLeft(2, '0');
      final mo = m.group(2)!.padLeft(2, '0');
      final y = m.group(3)!;
      return '$y-$mo-$d';
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v)) return v;
    return v;
  }

  static Future<String?> _resolveFcmToken() async {
    if (FFAppState().fcmToken.isNotEmpty) {
      return FFAppState().fcmToken;
    }
    try {
      final t = await FirebaseMessaging.instance.getToken();
      if (t != null && t.isNotEmpty) {
        FFAppState().fcmToken = t;
        return t;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DriverSignupSubmitService FCM: $e');
    }
    return '';
  }

  /// Returns `null` on success, or an error message for the UI.
  static Future<String?> submitAfterPreferences() async {
    final minResult = DocumentVerificationService.verifyMinimum();
    if (!minResult.isValid) {
      return minResult.errorSummary;
    }

    final fcmToken = await _resolveFcmToken();

    String referrerCode = FFAppState().referralCode.trim();
    if (referrerCode.isEmpty) {
      referrerCode = FFAppState().usedReferralCode.trim();
    }

    final driverJsonData = <String, dynamic>{
      'mobile_number': FFAppState().mobileNo.toString(),
      'first_name': FFAppState().firstName,
      'last_name': FFAppState().lastName,
      'email': FFAppState().email,
      'referral_code': referrerCode.isNotEmpty ? referrerCode : null,
      'preferred_city_id': FFAppState().preferredCityId > 0
          ? FFAppState().preferredCityId
          : null,
      'preferred_earning_mode': FFAppState().preferredEarningMode,
      'vehicle_image': FFAppState().vehicleImage?.name,
      'fcm_token': fcmToken ?? '',
    };
    if (FFAppState().licenseNumber.isNotEmpty) {
      driverJsonData['license_number'] = FFAppState().licenseNumber;
    }
    if (FFAppState().licenseExpiryDate.isNotEmpty) {
      driverJsonData['license_expiry_date'] =
          _toApiDate(FFAppState().licenseExpiryDate);
    }
    if (FFAppState().aadharNumber.isNotEmpty) {
      driverJsonData['aadhaar_number'] = FFAppState().aadharNumber;
    }
    if (FFAppState().panNumber.isNotEmpty) {
      driverJsonData['pan_number'] = FFAppState().panNumber;
    }
    if (FFAppState().dateOfBirth.isNotEmpty) {
      driverJsonData['date_of_birth'] = _toApiDate(FFAppState().dateOfBirth);
    }
    if (FFAppState().address.isNotEmpty) {
      driverJsonData['address'] = FFAppState().address;
    }
    if (FFAppState().city.isNotEmpty) {
      driverJsonData['city'] = FFAppState().city;
    }
    if (FFAppState().state.isNotEmpty) {
      driverJsonData['state'] = FFAppState().state;
    }
    if (FFAppState().postalCode.isNotEmpty) {
      driverJsonData['postal_code'] = FFAppState().postalCode;
    }
    if (FFAppState().emergencyContactName.isNotEmpty) {
      driverJsonData['emergency_contact_name'] =
          FFAppState().emergencyContactName;
    }
    if (FFAppState().emergencyContactPhone.isNotEmpty) {
      driverJsonData['emergency_contact_phone'] =
          FFAppState().emergencyContactPhone;
    }
    if (FFAppState().adminVehicleId > 0) {
      driverJsonData['vehicle_type_id'] = FFAppState().adminVehicleId;
    }

    final vehicleJsonData = <String, dynamic>{
      'vehicle_type': FFAppState().selectvehicle.isEmpty
          ? 'auto'
          : FFAppState().selectvehicle,
    };
    if (FFAppState().vehicleMake.isNotEmpty) {
      vehicleJsonData['vehicle_name'] = FFAppState().vehicleMake;
    }
    if (FFAppState().vehicleModel.isNotEmpty) {
      vehicleJsonData['vehicle_model'] = FFAppState().vehicleModel;
    }
    if (FFAppState().vehicleColor.isNotEmpty) {
      vehicleJsonData['vehicle_color'] = FFAppState().vehicleColor;
    }
    if (FFAppState().licensePlate.isNotEmpty) {
      vehicleJsonData['license_plate'] = FFAppState().licensePlate;
    }
    if (FFAppState().registrationNumber.isNotEmpty) {
      vehicleJsonData['registration_number'] =
          FFAppState().registrationNumber;
    }
    if (FFAppState().registrationDate.isNotEmpty) {
      vehicleJsonData['registration_date'] =
          _toApiDate(FFAppState().registrationDate);
    }
    if (FFAppState().pollutionExpiryDate.isNotEmpty) {
      vehicleJsonData['pollution_expiry_date'] =
          _toApiDate(FFAppState().pollutionExpiryDate);
    }

    final apiResult = await CreateDriverCall.call(
      profileimage: FFAppState().profilePhoto,
      licenseimage: FFAppState().imageLicense,
      licenseFrontImage: FFAppState().licenseFrontImage,
      licenseBackImage: FFAppState().licenseBackImage,
      aadhaarimage: FFAppState().aadharImage,
      aadhaarFrontImage: FFAppState().aadhaarFrontImage,
      aadhaarBackImage: FFAppState().aadhaarBackImage,
      panimage: FFAppState().panImage,
      rcFrontImage: FFAppState().rcFrontImage,
      rcBackImage: FFAppState().rcBackImage,
      vehicleImage: FFAppState().vehicleImage,
      registrationImage: FFAppState().registrationImage,
      pollutionImage: FFAppState().pollutioncertificateImage,
      driverJson: driverJsonData,
      vehicleJson: vehicleJsonData,
      fcmToken: fcmToken ?? '',
    );

    if (apiResult.succeeded) {
      final jsonBody = apiResult.jsonBody;

      String? accessToken =
          getJsonField(jsonBody, r'''$.data.access_token''')?.toString();
      accessToken ??=
          getJsonField(jsonBody, r'''$.data.accessToken''')?.toString();
      accessToken ??= getJsonField(jsonBody, r'''$.data.token''')?.toString();
      accessToken ??=
          getJsonField(jsonBody, r'''$.access_token''')?.toString();
      accessToken ??=
          getJsonField(jsonBody, r'''$.accessToken''')?.toString();
      if (accessToken == 'null' ||
          accessToken == null ||
          accessToken.isEmpty) {
        accessToken = null;
      }

      int driverId =
          castToType<int>(getJsonField(jsonBody, r'''$.data.driver.id''')) ??
              0;
      if (driverId == 0) {
        driverId =
            castToType<int>(getJsonField(jsonBody, r'''$.data.id''')) ?? 0;
      }
      if (driverId == 0) {
        driverId = castToType<int>(
                getJsonField(jsonBody, r'''$.data.driver_id''')) ??
            0;
      }

      final vehicleData = getJsonField(jsonBody, r'''$.data.vehicle''');
      if (vehicleData != null && vehicleData is Map) {
        final vId = castToType<int>(vehicleData['id']) ?? 0;
        final vTypeId = castToType<int>(vehicleData['vehicle_type_id']) ?? 0;
        final vType = vehicleData['vehicle_type']?.toString() ?? '';
        if (vId > 0) FFAppState().vehicleId = vId;
        if (vTypeId > 0) FFAppState().adminVehicleId = vTypeId;
        if (vType.isNotEmpty) {
          FFAppState().selectvehicle = vType;
          FFAppState().vehicleType = vType;
        }
      }

      if (accessToken == null || accessToken.isEmpty) {
        final loginRes = await LoginCall.call(
          mobile: FFAppState().mobileNo,
          fcmToken: FFAppState().fcmToken.isNotEmpty
              ? FFAppState().fcmToken
              : (fcmToken ?? ''),
        );
        if (loginRes.succeeded) {
          accessToken =
              getJsonField(loginRes.jsonBody, r'''$.data.accessToken''')
                  ?.toString();
          accessToken ??=
              getJsonField(loginRes.jsonBody, r'''$.data.access_token''')
                  ?.toString();
          if (driverId == 0) {
            driverId = castToType<int>(
                  getJsonField(loginRes.jsonBody, r'''$.data.id'''),
                ) ??
                0;
          }
        }
      }

      if (accessToken != null &&
          accessToken.isNotEmpty &&
          driverId > 0) {
        lastLoginTime = DateTime.now();
        FFAppState().update(() {
          FFAppState().isLoggedIn = true;
          FFAppState().isRegistered = true;
          FFAppState().registrationStep = 4;
          FFAppState().driverid = driverId;
          FFAppState().accessToken = accessToken!;
          FFAppState().refreshToken = LoginCall.refreshToken(jsonBody) ?? '';
        });
        syncDriverRideChatFcmRegistration();
        return null;
      }

      FFAppState().update(() {
        FFAppState().isLoggedIn = false;
        FFAppState().isRegistered = true;
        FFAppState().registrationStep = 4;
        if (driverId > 0) FFAppState().driverid = driverId;
      });
      return 'Account created but sign-in failed. Please log in again.';
    }

    final statusCode = apiResult.statusCode;
    final errorMsg =
        getJsonField(apiResult.jsonBody, r'''$.message''').toString();

    if (statusCode == 409) {
      final loginRes = await LoginCall.call(
        mobile: FFAppState().mobileNo,
        fcmToken: FFAppState().fcmToken.isNotEmpty
            ? FFAppState().fcmToken
            : (fcmToken ?? ''),
      );
      if (loginRes.succeeded) {
        String? accessToken =
            getJsonField(loginRes.jsonBody, r'''$.data.accessToken''')
                ?.toString();
        accessToken ??=
            getJsonField(loginRes.jsonBody, r'''$.data.access_token''')
                ?.toString();
        final driverId = castToType<int>(
                getJsonField(loginRes.jsonBody, r'''$.data.id''')) ??
            0;

        if (accessToken != null && accessToken.isNotEmpty && driverId > 0) {
          lastLoginTime = DateTime.now();
          FFAppState().update(() {
            FFAppState().isLoggedIn = true;
            FFAppState().isRegistered = true;
            FFAppState().registrationStep = 4;
            FFAppState().driverid = driverId;
            FFAppState().accessToken = accessToken!;
            FFAppState().refreshToken =
                LoginCall.refreshToken(loginRes.jsonBody) ?? '';
          });
          syncDriverRideChatFcmRegistration();
          return null;
        }
      }
    }

    if (errorMsg.isEmpty || errorMsg == 'null') {
      return 'Registration failed. Please try again.';
    }
    return errorMsg;
  }
}
