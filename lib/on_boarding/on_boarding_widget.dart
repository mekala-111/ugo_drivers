import '/auth/login_timestamp.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/document_verification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'on_boarding_model.dart';
export 'on_boarding_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OnBoardingWidget extends StatefulWidget {
  const OnBoardingWidget({
    super.key,
    required this.mobile,
    this.firstname,
    this.lastname,
    this.email,
    this.referalcode,
    this.vehicletype,
  });

  final int mobile;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? referalcode; // Should be String to match previous screens
  final String? vehicletype;

  static String routeName = 'on_boarding';
  static String routePath = '/onBoarding';

  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  late OnBoardingModel _model;
  String? fcmToken;
  bool _isLoading = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnBoardingModel());
    // Mark current step for resume functionality
    FFAppState().registrationStep = 4;
    _initFCM();
  }

  Future<void> _initFCM() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('FCM Error: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // Helper to check uploads
  bool _isDocumentUploaded(dynamic document) {
    if (document == null) return false;
    if (document is FFUploadedFile) {
      return document.bytes != null && document.bytes!.isNotEmpty;
    }
    if (document is String) {
      return document.isNotEmpty && document != 'null';
    }
    return false;
  }

  int _calculateCompletionPercentage() {
    int completed = 0;
    int total =
        8; // License, Profile, Aadhar, Pan, Vehicle, RC, Insurance, Pollution

    final hasLicense = _isDocumentUploaded(FFAppState().imageLicense) ||
        _isDocumentUploaded(FFAppState().licenseFrontImage) ||
        _isDocumentUploaded(FFAppState().licenseBackImage);
    final hasAadhaar = _isDocumentUploaded(FFAppState().aadharImage) ||
        _isDocumentUploaded(FFAppState().aadhaarFrontImage) ||
        _isDocumentUploaded(FFAppState().aadhaarBackImage);
    final hasRC = _isDocumentUploaded(FFAppState().registrationImage) ||
        _isDocumentUploaded(FFAppState().rcFrontImage) ||
        _isDocumentUploaded(FFAppState().rcBackImage);
    final hasInsurance = _isDocumentUploaded(FFAppState().insurancePdf) ||
        _isDocumentUploaded(FFAppState().insuranceImage);
    final hasPollution =
        _isDocumentUploaded(FFAppState().pollutioncertificateImage);

    if (hasLicense) completed++;
    if (_isDocumentUploaded(FFAppState().profilePhoto)) completed++;
    if (hasAadhaar) completed++;
    if (_isDocumentUploaded(FFAppState().panImage)) completed++;
    if (_isDocumentUploaded(FFAppState().vehicleImage)) completed++;
    if (hasRC) completed++;
    if (hasInsurance) completed++;
    if (hasPollution) completed++;

    return ((completed / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    final completionPercentage = _calculateCompletionPercentage();
    final allDocsUploaded = completionPercentage == 100;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final headerHeight = (screenHeight * 0.3).clamp(200.0, 260.0);

    // 🎨 APP COLORS
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgOffWhite,
        body: Column(
          children: [
            // ==========================================
            // 1️⃣ VIBRANT HEADER
            // ==========================================
            Container(
              height: headerHeight,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [brandGradientStart, brandPrimary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          context.goNamed(
                            ChooseVehicleWidget.routeName,
                            queryParameters: {
                              'mobile':
                                  serializeParam(widget.mobile, ParamType.int),
                              'firstname': serializeParam(
                                  widget.firstname, ParamType.String),
                              'lastname': serializeParam(
                                  widget.lastname, ParamType.String),
                              'email': serializeParam(
                                  widget.email, ParamType.String),
                              'referalcode': serializeParam(
                                  widget.referalcode, ParamType.String),
                            }.withoutNulls,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                FFLocalizations.of(context).getText('ob0001'),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                FFLocalizations.of(context)
                                    .getText('ob0002')
                                    .replaceAll(
                                        '%1', completionPercentage.toString()),
                                style: GoogleFonts.interTight(
                                  fontSize: 32,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Circular Progress
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Stack(
                              children: [
                                CircularProgressIndicator(
                                  value: completionPercentage / 100,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white24,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                                Center(
                                  child: Text(
                                    '${(completionPercentage / 12.5).round()}/8',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),

            // ==========================================
            // 2️⃣ DOCUMENT LIST (Scrollable)
            // ==========================================
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FFLocalizations.of(context).getText('ob0003'),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDocItem(
                          FFLocalizations.of(context).getText('qg68530z'),
                          FFAppState().imageLicense,
                          () => context.pushNamed(DrivingDlWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          FFLocalizations.of(context).getText('k8fnkaky'),
                          FFAppState().profilePhoto,
                          () => context.pushNamed(FaceVerifyWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          FFLocalizations.of(context).getText('c0kv9v5c'),
                          FFAppState().aadharImage,
                          () => context.pushNamed(AdharUploadWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          FFLocalizations.of(context).getText('ymy7qbgz'),
                          FFAppState().panImage,
                          () => context
                              .pushNamed(PanuploadScreenWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          FFLocalizations.of(context).getText('jqs0l5w3'),
                          FFAppState().vehicleImage,
                          () => context.pushNamed(VehicleImageWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          FFLocalizations.of(context).getText('ipks4vgn'),
                          FFAppState().registrationImage,
                          () => context
                              .pushNamed(RegistrationImageWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          'Insurance PDF',
                          FFAppState().insurancePdf ??
                              FFAppState().insuranceImage,
                          () => context.pushNamed(UploadRcWidget.routeName),
                        ),
                        const SizedBox(height: 16),
                        _buildDocItem(
                          'Pollution Certificate',
                          FFAppState().pollutioncertificateImage,
                          () => context.pushNamed(RCUploadWidget.routeName),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==========================================
            // 3️⃣ ACTION BUTTON (Fixed Bottom)
            // ==========================================
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _handleContinue(allDocsUploaded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Text(
                          allDocsUploaded
                              ? FFLocalizations.of(context).getText('ob0004')
                              : FFLocalizations.of(context).getText('ad0016'),
                          style: GoogleFonts.interTight(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Custom Document List Item
  Widget _buildDocItem(String title, dynamic docState, VoidCallback onTap) {
    bool isUploaded = _isDocumentUploaded(docState);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.sectionOrangeLight
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.primary : AppColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUploaded ? AppColors.sectionOrangeLight : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUploaded ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.upload_file,
                color: isUploaded ? AppColors.primary : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUploaded
                        ? FFLocalizations.of(context).getText('ob0006')
                        : FFLocalizations.of(context).getText('ob0007'),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color:
                          isUploaded ? AppColors.primary : Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  /// Convert date to YYYY-MM-DD for API
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

  // 🔹 Logic: Handle Submit / Skip (Uber-style verification)
  Future<void> _handleContinue(bool allDocsUploaded) async {
    if (allDocsUploaded) {
      // Submit for Verification: run full document verification first
      final result = DocumentVerificationService.verifyAll();
      if (!result.isValid) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                Text(FFLocalizations.of(context).getText('ob0008')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('ob0009'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...result.errors.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(color: Colors.red)),
                            Expanded(
                                child: Text(e,
                                    style: const TextStyle(fontSize: 14))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(FFLocalizations.of(context).getText('drv_ok')),
              ),
            ],
          ),
        );
        return;
      }
    } else {
      // Skip: confirm and run minimum validation
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(FFLocalizations.of(context).getText('ob0010')),
          content: Text(
            FFLocalizations.of(context).getText('ob0011'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(FFLocalizations.of(context).getText('drv_cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                FFLocalizations.of(context).getText('ob0005'),
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
      if (confirm != true) return;

      final minResult = DocumentVerificationService.verifyMinimum();
      if (!minResult.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(minResult.errorSummary),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Prepare JSON Payload - include all collected onboarding data
      final driverJsonData = <String, dynamic>{
        'mobile_number': FFAppState().mobileNo.toString(),
        'first_name': FFAppState().firstName,
        'last_name': FFAppState().lastName,
        'email': FFAppState().email,
        'referal_code': FFAppState().referralCode,
        'used_referral_code': FFAppState().usedReferralCode.isNotEmpty
            ? FFAppState().usedReferralCode
            : null,
        'preferred_city_id': FFAppState().preferredCityId > 0
            ? FFAppState().preferredCityId
            : null,
        'preferred_earning_mode': FFAppState().preferredEarningMode,
        'vehicle_image': FFAppState().vehicleImage?.name,
        'fcmToken': fcmToken ?? '',
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
      if (FFAppState().insuranceNumber.isNotEmpty) {
        vehicleJsonData['insurance_number'] = FFAppState().insuranceNumber;
      }
      if (FFAppState().registrationDate.isNotEmpty) {
        vehicleJsonData['registration_date'] =
            _toApiDate(FFAppState().registrationDate);
      }
      if (FFAppState().insuranceExpiryDate.isNotEmpty) {
        vehicleJsonData['insurance_expiry_date'] =
            _toApiDate(FFAppState().insuranceExpiryDate);
      }
      if (FFAppState().pollutionExpiryDate.isNotEmpty) {
        vehicleJsonData['pollution_expiry_date'] =
            _toApiDate(FFAppState().pollutionExpiryDate);
      }

      // 3. API Call
      _model.apiResult7ju = await CreateDriverCall.call(
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
       pollutionImage: FFAppState().pollutioncertificateImage,
        driverJson: driverJsonData,
        vehicleJson: vehicleJsonData,
        fcmToken: fcmToken ?? '',
      );

      // 4. Handle Response
      if (_model.apiResult7ju?.succeeded ?? false) {
        final jsonBody = _model.apiResult7ju?.jsonBody;

        // Extract token (backend may use access_token, accessToken, or token)
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

        // Extract driverId (backend may use data.driver.id or data.id)
        int? driverId =
            castToType<int>(getJsonField(jsonBody, r'''$.data.driver.id'''));
        driverId ??= castToType<int>(getJsonField(jsonBody, r'''$.data.id'''));
        driverId ??=
            castToType<int>(getJsonField(jsonBody, r'''$.data.driver_id'''));
        driverId ??= 0;

        // Extract vehicle data from signup response (data.vehicle)
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

        // If createDriver didn't return a token, fetch via login API (driver now exists)
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
            FFAppState().registrationStep = 4; // Mark registration complete
            FFAppState().driverid = resolvedDriverId;
            FFAppState().accessToken = accessToken!;
            // Vehicle data from signup response already set above
          });

          if (mounted) {
            context.pushReplacementNamed(HomeWidget.routeName);
          }
        } else {
          // Token or driverId missing - redirect to login
          FFAppState().update(() {
            FFAppState().isLoggedIn = false;
            FFAppState().isRegistered = true;
            FFAppState().registrationStep = 4; // Mark registration complete
            final id = driverId ?? 0;
            if (id > 0) FFAppState().driverid = id;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(FFLocalizations.of(context).getText('ob0012')),
                backgroundColor: Colors.orange,
              ),
            );
            context.pushReplacementNamed(
                LoginWidget.routeName); // from /index.dart
          }
        }
      } else {
        // Handle known errors (e.g., driver already exists)
        final statusCode = _model.apiResult7ju?.statusCode ?? 0;
        final errorMsg =
            getJsonField(_model.apiResult7ju?.jsonBody, r'''$.message''')
                .toString();

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
                FFAppState().driverid = driverId;
                FFAppState().accessToken = accessToken!;
              });

              if (mounted) {
                context.pushReplacementNamed(HomeWidget.routeName);
              }
              return;
            }
          }
        }

        if (mounted) {
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
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}