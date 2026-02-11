import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
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
  final int? referalcode;
  final String? vehicletype;

  static String routeName = 'on_boarding';
  static String routePath = '/onBoarding';

  @override
  State<OnBoardingWidget> createState() => _OnBoardingWidgetState();
}

class _OnBoardingWidgetState extends State<OnBoardingWidget> {
  late OnBoardingModel _model;
  String? fcm_token;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnBoardingModel());
    _initFCM();
  }

  Future<void> _initFCM() async {
    try {
      fcm_token = await FirebaseMessaging.instance.getToken();
      if (fcm_token != null) {
        FFAppState().fcmToken = fcm_token!;
      }
    } catch (e) {
      print('FCM Error: $e');
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _isDocumentUploaded(dynamic document) {
    if (document == null) return false;
    if (document is FFUploadedFile) {
      return document.name != null &&
          document.name!.isNotEmpty &&
          document.bytes != null &&
          document.bytes!.isNotEmpty;
    }
    if (document is String) {
      return document.isNotEmpty;
    }
    return false;
  }

  int _calculateCompletionPercentage() {
    int completed = 0;
    int total = 6;

    if (_isDocumentUploaded(FFAppState().imageLicense)) completed++;
    if (_isDocumentUploaded(FFAppState().profilePhoto)) completed++;
    if (_isDocumentUploaded(FFAppState().aadharImage)) completed++;
    if (_isDocumentUploaded(FFAppState().panImage)) completed++;
    if (_isDocumentUploaded(FFAppState().vehicleImage)) completed++;
    if (_isDocumentUploaded(FFAppState().registrationImage)) completed++;

    return ((completed / total) * 100).round();
  }

  bool _areAllDocumentsUploaded() {
    // Check if required docs are uploaded (Add back images if mandatory)
    return _isDocumentUploaded(FFAppState().imageLicense) &&
        _isDocumentUploaded(FFAppState().profilePhoto) &&
        _isDocumentUploaded(FFAppState().aadharImage) &&
        _isDocumentUploaded(FFAppState().panImage) &&
        _isDocumentUploaded(FFAppState().vehicleImage) &&
        _isDocumentUploaded(FFAppState().registrationImage);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final completionPercentage = _calculateCompletionPercentage();
    final allDocsUploaded = _areAllDocumentsUploaded();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7B10),
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30.0),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText('1zwx91lm' /* UGO */),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
              color: Colors.white,
              fontSize: 22.0,
            ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${widget.firstname ?? "Driver"}',
                          style: FlutterFlowTheme.of(context).headlineLarge.override(
                            font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 28.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          FFLocalizations.of(context).getText('gymcdncw' /* Complete steps... */),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 15.0,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        // Progress Bar
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Documents Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('$completionPercentage%', style: TextStyle(color: Color(0xFFFF7B10), fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.grey[200],
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: completionPercentage / 100,
                                    child: Container(color: Color(0xFFFF7B10)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Steps
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                  child: Column(
                    children: [
                      _buildStepItem(context: context, title: 'Driving License', subtitle: _isDocumentUploaded(FFAppState().imageLicense) ? 'Uploaded' : 'Required', onTap: () => context.pushNamed(DrivingDlWidget.routeName), isUploaded: _isDocumentUploaded(FFAppState().imageLicense)),
                      const SizedBox(height: 12.0),
                      _buildStepItem(context: context, title: 'Profile Picture', subtitle: _isDocumentUploaded(FFAppState().profilePhoto) ? 'Uploaded' : 'Required', onTap: () => context.pushNamed(FaceVerifyWidget.routeName), isUploaded: _isDocumentUploaded(FFAppState().profilePhoto)),
                      const SizedBox(height: 12.0),
                      _buildStepItem(context: context, title: 'Aadhaar Card', subtitle: _isDocumentUploaded(FFAppState().aadharImage) ? 'Uploaded' : 'Required', onTap: () => context.pushNamed(AdharUploadWidget.routeName), isUploaded: _isDocumentUploaded(FFAppState().aadharImage)),
                      const SizedBox(height: 12.0),
                      _buildStepItem(context: context, title: 'Pan Card', subtitle: _isDocumentUploaded(FFAppState().panImage) ? 'Uploaded' : 'Required', onTap: () => context.pushNamed(PanuploadScreenWidget.routeName), isUploaded: _isDocumentUploaded(FFAppState().panImage)),
                      const SizedBox(height: 12.0),
                      _buildStepItem(context: context, title: 'Vehicle Photo', subtitle: _isDocumentUploaded(FFAppState().vehicleImage) ? 'Uploaded' : 'Required', onTap: () => context.pushNamed(VehicleImageWidget.routeName), isUploaded: _isDocumentUploaded(FFAppState().vehicleImage)),
                      const SizedBox(height: 12.0),
                      _buildStepItem(context: context, title: 'RC (Registration)', subtitle: _isDocumentUploaded(FFAppState().registrationImage) ? 'Uploaded' : 'Required', onTap: () => context.pushNamed(RegistrationImageWidget.routeName), isUploaded: _isDocumentUploaded(FFAppState().registrationImage)),
                    ],
                  ),
                ),

                // COMPLETE REGISTRATION BUTTON
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      if (!allDocsUploaded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please upload all required documents first.')),
                        );
                        return;
                      }

                      final driverJsonData = {
                        'mobile_number': widget.mobile, // Use widget param directly as it is int
                        'first_name': widget.firstname ?? '',
                        'last_name': widget.lastname ?? '',
                        'email': widget.email ?? '',
                        'referal_code': widget.referalcode?.toString() ?? '',
                        'fcm_token': fcm_token ?? '',
                      };

                      final vehicleJsonData = {
                        'vehicle_type': widget.vehicletype ?? 'auto',
                      };

                      // 1. Attempt Registration
                      _model.apiResult7ju = await CreateDriverCall.call(
                        profileimage: FFAppState().profilePhoto,

                        // Pass specific front/back images if available in AppState, else fallbacks
                        licenseFrontImage: FFAppState().imageLicense,
                        licenseBackImage: FFAppState().licenseBackImage,
                        aadhaarFrontImage: FFAppState().aadharImage,
                        aadhaarBackImage: FFAppState().aadharBackImage,
                        rcFrontImage: FFAppState().registrationImage,
                        rcBackImage: FFAppState().rcBackImage,

                        // Legacy/Generic fields
                        licenseimage: FFAppState().imageLicense,
                        aadhaarimage: FFAppState().aadharImage,
                        panimage: FFAppState().panImage,
                        vehicleImage: FFAppState().vehicleImage,
                        registrationImage: FFAppState().registrationImage,

                        driverJson: driverJsonData,
                        vehicleJson: vehicleJsonData,
                        fcmToken: fcm_token ?? '',
                      );

                      // 2. Handle Response
                      if ((_model.apiResult7ju?.succeeded ?? false)) {
                        // SUCCESS: New Driver Created
                        final driverId = getJsonField((_model.apiResult7ju?.jsonBody ?? ''), r'''$.data.driver.id''');
                        final token = getJsonField((_model.apiResult7ju?.jsonBody ?? ''), r'''$.data.access_token''').toString();

                        FFAppState().update(() {
                          FFAppState().isLoggedIn = true;
                          FFAppState().driverid = driverId;
                          FFAppState().accessToken = token;
                        });

                        context.goNamedAuth(HomeWidget.routeName, context.mounted);
                      }
                      // 3. Handle 409 (Already Exists)
                      else if (_model.apiResult7ju?.statusCode == 409) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account already exists. Logging in...'), backgroundColor: Colors.orange),
                        );

                        // 4. Attempt Auto-Login
                        final loginResult = await LoginCall.call(mobile: widget.mobile);

                        if (loginResult.succeeded) {
                          final driverId = getJsonField(loginResult.jsonBody, r'''$.data.id''');
                          final token = getJsonField(loginResult.jsonBody, r'''$.data.accessToken''').toString();

                          if (driverId != null && token.isNotEmpty) {
                            FFAppState().update(() {
                              FFAppState().isLoggedIn = true;
                              FFAppState().driverid = driverId;
                              FFAppState().accessToken = token;
                            });
                            context.goNamedAuth(HomeWidget.routeName, context.mounted);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login failed: Invalid data received.'), backgroundColor: Colors.red),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login failed. Please verify your number.'), backgroundColor: Colors.red),
                          );
                        }
                      }
                      // 4. Other Errors
                      else {
                        final errorMsg = getJsonField((_model.apiResult7ju?.jsonBody ?? ''), r'''$.message''') ?? 'Registration Failed';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(errorMsg.toString()), backgroundColor: Colors.red),
                        );
                      }
                    },
                    text: 'Complete Registration',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      color: allDocsUploaded ? const Color(0xFF10B981) : Colors.grey,
                      textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.bold),
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
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

  Widget _buildStepItem({required BuildContext context, required String title, String? subtitle, required VoidCallback onTap, bool isUploaded = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isUploaded ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Icon(isUploaded ? Icons.check_circle : Icons.upload_file, color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFFF7B10)),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
                  if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}