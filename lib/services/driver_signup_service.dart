import '/auth/login_timestamp.dart';
import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

/// Shared driver signup (profile + optional docs) after pre-registration steps.
class DriverSignupService {
  DriverSignupService._();

  static String toApiDate(String value) {
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

  static String _resolveReferrerCode(String? referalCodeFromRoute) {
    var referrerCode = FFAppState().referralCode.trim();
    if (referrerCode.isEmpty && referalCodeFromRoute != null) {
      referrerCode = referalCodeFromRoute.trim();
    }
    return referrerCode;
  }

  /// [fcmToken] may be null; falls back to [FFAppState].fcmToken where needed.
  static Future<void> executeSignupAndNavigate(
    BuildContext context, {
    String? fcmToken,
    String? referalCodeFromRoute,
  }) async {
    final referrerCode = _resolveReferrerCode(referalCodeFromRoute);

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
          toApiDate(FFAppState().licenseExpiryDate);
    }
    if (FFAppState().aadharNumber.isNotEmpty) {
      driverJsonData['aadhaar_number'] = FFAppState().aadharNumber;
    }
    if (FFAppState().panNumber.isNotEmpty) {
      driverJsonData['pan_number'] = FFAppState().panNumber;
    }
    if (FFAppState().dateOfBirth.isNotEmpty) {
      driverJsonData['date_of_birth'] = toApiDate(FFAppState().dateOfBirth);
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
    if (FFAppState().insuranceNumber.isNotEmpty) {
      vehicleJsonData['insurance_number'] = FFAppState().insuranceNumber;
    }
    if (FFAppState().registrationDate.isNotEmpty) {
      vehicleJsonData['registration_date'] =
          toApiDate(FFAppState().registrationDate);
    }
    if (FFAppState().insuranceExpiryDate.isNotEmpty) {
      vehicleJsonData['insurance_expiry_date'] =
          toApiDate(FFAppState().insuranceExpiryDate);
    }
    if (FFAppState().pollutionExpiryDate.isNotEmpty) {
      vehicleJsonData['pollution_expiry_date'] =
          toApiDate(FFAppState().pollutionExpiryDate);
    }

    final effectiveFcm = fcmToken ??
        (FFAppState().fcmToken.isNotEmpty ? FFAppState().fcmToken : null) ??
        '';

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
      insuranceImage: FFAppState().insurancePdf ?? FFAppState().insuranceImage,
      pollutionImage: FFAppState().pollutioncertificateImage,
      driverJson: driverJsonData,
      vehicleJson: vehicleJsonData,
    );

    if (!context.mounted) return;

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

      int? driverId =
          castToType<int>(getJsonField(jsonBody, r'''$.data.driver.id'''));
      driverId ??= castToType<int>(getJsonField(jsonBody, r'''$.data.id'''));
      driverId ??=
          castToType<int>(getJsonField(jsonBody, r'''$.data.driver_id'''));
      driverId ??= 0;

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
              : effectiveFcm,
        );
        if (!context.mounted) return;
        if (loginRes.succeeded) {
          accessToken =
              getJsonField(loginRes.jsonBody, r'''$.data.accessToken''')
                  ?.toString();
          accessToken ??=
              getJsonField(loginRes.jsonBody, r'''$.data.access_token''')
                  ?.toString();
          if (driverId == 0) {
            driverId = castToType<int>(
                    getJsonField(loginRes.jsonBody, r'''$.data.id''')) ??
                0;
          }
        }
      }

      final resolvedDriverId = driverId;
      if (accessToken != null &&
          accessToken.isNotEmpty &&
          resolvedDriverId > 0) {
        lastLoginTime = DateTime.now();
        FFAppState().update(() {
          FFAppState().isLoggedIn = true;
          FFAppState().isRegistered = true;
          FFAppState().registrationStep = 4;
          FFAppState().driverid = resolvedDriverId;
          FFAppState().accessToken = accessToken!;
          FFAppState().refreshToken = LoginCall.refreshToken(jsonBody) ?? '';
        });

        if (context.mounted) {
          context.pushReplacementNamed(HomeWidget.routeName);
        }
      } else {
        FFAppState().update(() {
          FFAppState().isLoggedIn = false;
          FFAppState().isRegistered = true;
          FFAppState().registrationStep = 4;
          final id = driverId ?? 0;
          if (id > 0) FFAppState().driverid = id;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  FFLocalizations.of(context).getText('ob0012')),
              backgroundColor: Colors.orange,
            ),
          );
          context.pushReplacementNamed(LoginWidget.routeName);
        }
      }
      return;
    }

    final statusCode = apiResult.statusCode;
    final errorMsg =
        getJsonField(apiResult.jsonBody, r'''$.message''').toString();

    if (statusCode == 409) {
      final loginRes = await LoginCall.call(
        mobile: FFAppState().mobileNo,
        fcmToken: FFAppState().fcmToken.isNotEmpty
            ? FFAppState().fcmToken
            : effectiveFcm,
      );
      if (!context.mounted) return;
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
            FFAppState().driverid = driverId;
            FFAppState().accessToken = accessToken!;
            FFAppState().refreshToken =
                LoginCall.refreshToken(loginRes.jsonBody) ?? '';
          });

          if (context.mounted) {
            context.pushReplacementNamed(HomeWidget.routeName);
          }
          return;
        }
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMsg.isEmpty
                ? FFLocalizations.of(context).getText('ob0013')
                : errorMsg,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
