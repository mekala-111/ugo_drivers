import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/services/document_verification_service.dart';
import '/services/driver_signup_service.dart';
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
    // Set AppState usedReferralCode: from route param, or from First details (referralCode)
    if (widget.referalcode != null && widget.referalcode!.isNotEmpty) {
      FFAppState().usedReferralCode = widget.referalcode!;
    } else if (FFAppState().usedReferralCode.isEmpty &&
        FFAppState().referralCode.trim().isNotEmpty) {
      FFAppState().usedReferralCode = FFAppState().referralCode.trim();
    }
    debugPrint('referrer_code (final): \'${FFAppState().referralCode}\'');
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
    int total = 6; // License, Profile, Aadhar, Pan, Vehicle, RC

    final hasLicense = _isDocumentUploaded(FFAppState().imageLicense) ||
        _isDocumentUploaded(FFAppState().licenseFrontImage) ||
        _isDocumentUploaded(FFAppState().licenseBackImage);
    final hasAadhaar = _isDocumentUploaded(FFAppState().aadharImage) ||
        _isDocumentUploaded(FFAppState().aadhaarFrontImage) ||
        _isDocumentUploaded(FFAppState().aadhaarBackImage);
    final hasRC = _isDocumentUploaded(FFAppState().registrationImage) ||
        _isDocumentUploaded(FFAppState().rcFrontImage) ||
        _isDocumentUploaded(FFAppState().rcBackImage);

    if (hasLicense) completed++;
    if (_isDocumentUploaded(FFAppState().profilePhoto)) completed++;
    if (hasAadhaar) completed++;
    if (_isDocumentUploaded(FFAppState().panImage)) completed++;
    if (_isDocumentUploaded(FFAppState().vehicleImage)) completed++;
    if (hasRC) completed++;

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
                  onPressed: _isLoading ? null : _handleContinue,
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
                              : FFLocalizations.of(context).getText('ad0015'),
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

  /// Register with profile (and any optional docs already in app state).
  Future<void> _handleContinue() async {
    final profileResult =
        DocumentVerificationService.verifyProfileOnlyRegistration();
    if (!profileResult.isValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileResult.errorSummary),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DriverSignupService.executeSignupAndNavigate(
        context,
        fcmToken: fcmToken,
        referalCodeFromRoute: widget.referalcode,
      );
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
