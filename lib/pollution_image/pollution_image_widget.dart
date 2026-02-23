import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/upload_data.dart';
import '/index.dart';
import '/services/document_verification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

import 'pollution_image_model.dart';
export 'pollution_image_model.dart';

class RCUploadWidget extends StatefulWidget {
  const RCUploadWidget({super.key});

  static String routeName = 'RC_upload';
  static String routePath = '/rCUpload';

  @override
  State<RCUploadWidget> createState() => _RCUploadWidgetState();
}

class _RCUploadWidgetState extends State<RCUploadWidget> {
  late RCUploadModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FFUploadedFile? _pollutionImage;
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => RCUploadModel());
    _loadSavedImage();
  }

  void _loadSavedImage() {
    if (FFAppState().pollutioncertificateImage?.bytes != null) {
      setState(() {
        _pollutionImage = FFAppState().pollutioncertificateImage;
        _isValid = true;
      });
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _pickPollutionPhoto() async {
    final selectedMedia = await selectMediaWithSourceBottomSheet(
      context: context,
      allowPhoto: true,
    );
    if (selectedMedia == null ||
        !selectedMedia.every((m) => validateFileFormat(m.storagePath, context))) {
      return;
    }
    final file = FFUploadedFile(
      name: selectedMedia.first.storagePath.split('/').last,
      bytes: selectedMedia.first.bytes,
      height: selectedMedia.first.dimensions?.height,
      width: selectedMedia.first.dimensions?.width,
      blurHash: selectedMedia.first.blurHash,
      originalFilename: selectedMedia.first.originalFilename,
    );
    setState(() {
      _pollutionImage = file;
      _isValid = true;
    });
    FFAppState().pollutioncertificateImage = file;
    FFAppState().pollutionBase64 =
        file.bytes != null ? base64Encode(file.bytes!) : '';
    FFAppState().update(() {});
  }

  String _toApiDate(String value) {
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

  Future<void> _submitRegistration() async {
    if (_isLoading) return;
    if (!_isValid) {
      _showSnackBar('Please upload pollution certificate', isError: true);
      return;
    }

    final verify = DocumentVerificationService.verifyAll();
    if (!verify.isValid) {
      _showSnackBar(verify.errorSummary, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final usedReferral = FFAppState().usedReferralCode.trim();
      final driverJsonData = <String, dynamic>{
        'mobile_number': FFAppState().mobileNo.toString(),
        'first_name': FFAppState().firstName,
        'last_name': FFAppState().lastName,
        'email': FFAppState().email,
        'referal_code': FFAppState().referralCode,
        'used_referral_code': usedReferral.isEmpty ? null : usedReferral,
        'preferred_city_id': FFAppState().preferredCityId > 0
            ? FFAppState().preferredCityId
            : null,
        'preferred_earning_mode': FFAppState().preferredEarningMode,
        'vehicle_image': FFAppState().vehicleImage?.name,
        'fcm_token': FFAppState().fcmToken,
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

      final vehicleJsonData = <String, dynamic>{
        'vehicle_type': FFAppState().selectvehicle.isEmpty
            ? 'auto'
            : FFAppState().selectvehicle,
      };
      if (FFAppState().adminVehicleId > 0) {
        vehicleJsonData['admin_vehicle_id'] = FFAppState().adminVehicleId;
        vehicleJsonData['vehicle_type_id'] = FFAppState().adminVehicleId;
      }
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
      if (FFAppState().insuranceNumber.isNotEmpty) {
        vehicleJsonData['insurance_number'] = FFAppState().insuranceNumber;
      }
      if (FFAppState().insuranceExpiryDate.isNotEmpty) {
        vehicleJsonData['insurance_expiry_date'] =
            _toApiDate(FFAppState().insuranceExpiryDate);
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
        insuranceImage:
            FFAppState().insurancePdf ?? FFAppState().insuranceImage,
        pollutionCertificateImage: FFAppState().pollutioncertificateImage,
        driverJson: driverJsonData,
        vehicleJson: vehicleJsonData,
        fcmToken: FFAppState().fcmToken,
      );

      if (apiResult.succeeded) {
        final jsonBody = apiResult.jsonBody;
        String? accessToken =
            getJsonField(jsonBody, r'''$.data.access_token''')?.toString();
        accessToken ??=
            getJsonField(jsonBody, r'''$.data.accessToken''')?.toString();
        accessToken ??= getJsonField(jsonBody, r'''$.data.token''')?.toString();
        accessToken ??= getJsonField(jsonBody, r'''$.access_token''')?.toString();
        accessToken ??= getJsonField(jsonBody, r'''$.accessToken''')?.toString();
        if (accessToken == 'null' || accessToken == null || accessToken.isEmpty) {
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

        if (accessToken != null && accessToken.isNotEmpty && driverId > 0) {
          FFAppState().update(() {
            FFAppState().isLoggedIn = true;
            FFAppState().isRegistered = true;
            FFAppState().driverid = driverId!;
            FFAppState().accessToken = accessToken!;
          });
          if (mounted) {
            context.pushNamedAndRemoveUntil(
              HomeWidget.routeName,
              (route) => false,
            );
          }
        } else {
          FFAppState().update(() {
            FFAppState().isLoggedIn = false;
            FFAppState().isRegistered = true;
            final id = driverId ?? 0;
            if (id > 0) FFAppState().driverid = id;
          });
          if (mounted) {
            _showSnackBar(
              'Registration complete. Please sign in to continue.',
              isError: false,
            );
            context.pushNamedAndRemoveUntil(
              LoginWidget.routeName,
              (route) => false,
            );
          }
        }
      } else {
        if (apiResult.statusCode == 409) {
          final loginRes = await LoginCall.call(
            mobile: FFAppState().mobileNo,
            fcmToken: FFAppState().fcmToken,
          );
          if (loginRes.succeeded) {
            String? accessToken = getJsonField(
              loginRes.jsonBody,
              r'''$.data.accessToken''',
            )?.toString();
            accessToken ??= getJsonField(
              loginRes.jsonBody,
              r'''$.data.access_token''',
            )?.toString();
            final driverId = castToType<int>(
                  getJsonField(loginRes.jsonBody, r'''$.data.id'''),
                ) ??
                0;
            if (accessToken != null &&
                accessToken.isNotEmpty &&
                driverId > 0) {
              FFAppState().update(() {
                FFAppState().isLoggedIn = true;
                FFAppState().isRegistered = true;
                FFAppState().driverid = driverId;
                FFAppState().accessToken = accessToken!;
              });
              if (mounted) {
                context.pushNamedAndRemoveUntil(
                  HomeWidget.routeName,
                  (route) => false,
                );
              }
              return;
            }
          }
          if (mounted) {
            _showSnackBar(
              'Driver already exists. Please sign in.',
              isError: true,
            );
            context.pushNamedAndRemoveUntil(
              LoginWidget.routeName,
              (route) => false,
            );
          }
          return;
        }
        final errorMsg =
            getJsonField(apiResult.jsonBody, r'''$.message''').toString();
        _showSnackBar(
          errorMsg.isEmpty ? 'Registration Failed' : errorMsg,
          isError: true,
        );
      }
    } catch (_) {
      _showSnackBar('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _pollutionImage?.bytes != null &&
        _pollutionImage!.bytes!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.backgroundAlt,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Pollution Certificate',
            style: GoogleFonts.interTight(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload pollution certificate',
                  style: GoogleFonts.interTight(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make sure the certificate details are visible.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.greySlate,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickPollutionPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasImage ? AppColors.primary : AppColors.greyBorder,
                        width: 1.5,
                      ),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              _pollutionImage!.bytes!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: AppColors.sectionOrangeLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Tap to upload',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.greySlate,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Finish Registration',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
