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

    print("\n═══════════════════════════════════════");
    print("OnBoarding Widget - InitState");
    print("═══════════════════════════════════════");
    print("📱 Mobile: ${widget.mobile}");
    print("👤 First Name: ${widget.firstname}");
    print("👤 Last Name: ${widget.lastname}");
    print("📧 Email: ${widget.email}");
    print("🎫 Referral Code: ${widget.referalcode}");
    print("🚗 Vehicle Type: ${widget.vehicletype}");
    print("═══════════════════════════════════════\n");
  }

  Future<void> _initFCM() async {
    fcm_token = await FirebaseMessaging.instance.getToken();
    print('🔔 FCM TOKEN: $fcm_token');
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
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              context.pop();
            },
          ),
          title: Text(
            FFLocalizations.of(context).getText(
              '1zwx91lm' /* UGO */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.interTight(
                fontWeight:
                FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                fontStyle:
                FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
              color: Colors.white,
              fontSize: 22.0,
              letterSpacing: 0.0,
            ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Header Section with Progress
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        24.0, 24.0, 24.0, 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FFLocalizations.of(context).getVariableText(
                            enText: 'Welcome, ${widget.firstname ?? "Driver"}',
                            hiText: 'स्वागत है, ${widget.firstname ?? "ड्राइवर"}',
                            teText: 'స్వాగతం, ${widget.firstname ?? "డ్రైవర్"}',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .headlineLarge
                              .override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.bold,
                            ),
                            color: FlutterFlowTheme.of(context).primaryText,
                            fontSize: 28.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          FFLocalizations.of(context).getText(
                            'gymcdncw' /* Complete the following steps t... */,
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                            font: GoogleFonts.inter(),
                            color: FlutterFlowTheme.of(context)
                                .secondaryText,
                            fontSize: 15.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                        SizedBox(height: 20.0),

                        // Progress Bar Container
                        Container(
                          width: double.infinity,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 16.0, 16.0, 16.0),
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1.0,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Documents Progress',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                  Text(
                                    '$completionPercentage%',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      color: completionPercentage == 100
                                          ? Color(0xFF10B981)
                                          : Color(0xFFFF7B10),
                                      fontSize: 20.0,
                                      letterSpacing: 0.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.0),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).alternate,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Stack(
                                    children: [
                                      FractionallySizedBox(
                                        widthFactor: completionPercentage / 100,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: completionPercentage == 100
                                                  ? [
                                                Color(0xFF10B981),
                                                Color(0xFF059669)
                                              ]
                                                  : [
                                                Color(0xFFFF7B10),
                                                Color(0xFFFF6B35)
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                          ),
                                        ),
                                      ),
                                    ],
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

                // Steps List Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                        16.0, 8.0, 16.0, 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'qg68530z' /* Driving License */,
                          ),
                          subtitle: _isDocumentUploaded(FFAppState().imageLicense)
                              ? 'Uploaded successfully'
                              : FFLocalizations.of(context).getText(
                            'mnqkwauk' /* Recommended next step */,
                          ),
                          onTap: () {
                            context.pushNamed(DrivingDlWidget.routeName);
                          },
                          isUploaded:
                          _isDocumentUploaded(FFAppState().imageLicense),
                          isRecommended:
                          !_isDocumentUploaded(FFAppState().imageLicense),
                        ),
                        SizedBox(height: 12.0),
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'k8fnkaky' /* Profile Picture */,
                          ),
                          subtitle: _isDocumentUploaded(FFAppState().profilePhoto)
                              ? 'Uploaded successfully'
                              : 'Required',
                          onTap: () {
                            context.pushNamed(FaceVerifyWidget.routeName);
                          },
                          isUploaded:
                          _isDocumentUploaded(FFAppState().profilePhoto),
                        ),
                        SizedBox(height: 12.0),
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'c0kv9v5c' /* Aadhaar Card */,
                          ),
                          subtitle: _isDocumentUploaded(FFAppState().aadharImage)
                              ? 'Uploaded successfully'
                              : 'Required',
                          onTap: () {
                            context.pushNamed(AdharUploadWidget.routeName);
                          },
                          isUploaded:
                          _isDocumentUploaded(FFAppState().aadharImage),
                        ),
                        SizedBox(height: 12.0),
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'ymy7qbgz' /* Pan Card */,
                          ),
                          subtitle: _isDocumentUploaded(FFAppState().panImage)
                              ? 'Uploaded successfully'
                              : 'Required',
                          onTap: () {
                            context.pushNamed(PanuploadScreenWidget.routeName);
                          },
                          isUploaded: _isDocumentUploaded(FFAppState().panImage),
                        ),
                        SizedBox(height: 12.0),
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'jqs0l5w3' /* Vehicle photo verification */,
                          ),
                          subtitle:
                          _isDocumentUploaded(FFAppState().vehicleImage)
                              ? 'Uploaded successfully'
                              : 'Required',
                          onTap: () {
                            context.pushNamed(VehicleImageWidget.routeName);
                          },
                          isUploaded:
                          _isDocumentUploaded(FFAppState().vehicleImage),
                        ),
                        SizedBox(height: 12.0),
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'ipks4vgn' /* Registration Certificate (RC) */,
                          ),
                          subtitle: _isDocumentUploaded(
                              FFAppState().registrationImage)
                              ? 'Uploaded successfully'
                              : 'Required',
                          onTap: () {
                            context.pushNamed(
                                RegistrationImageWidget.routeName);
                          },
                          isUploaded: _isDocumentUploaded(
                              FFAppState().registrationImage),
                        ),
                      ],
                    ),
                  ),
                ),

                // Register/Skip Button
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      24.0, 16.0, 24.0, 24.0),
                  child: Column(
                    children: [
                      if (!allDocsUploaded)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 12.0, 16.0, 12.0),
                          margin: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 16.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFF4E6),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: Color(0xFFFFB020),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFFFF7B10),
                                size: 20.0,
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  'Upload all documents to complete registration',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                    font: GoogleFonts.inter(),
                                    color: Color(0xFF7C5A00),
                                    fontSize: 13.0,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      FFButtonWidget(
                        onPressed: () async {
                          if (!allDocsUploaded) {
                            final shouldSkip = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Incomplete Documents'),
                                  content: Text(
                                      'You haven\'t uploaded all required documents. You can upload them later from your profile. Do you want to continue?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text('Continue'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldSkip != true) return;
                          }

                          // ============ CRITICAL FIX: CREATE JSON BEFORE API CALL ============
                          print("\n╔════════════════════════════════════════════════════════════╗");
                          print("║     BUTTON PRESSED - PREPARING API CALL DATA              ║");
                          print("╚════════════════════════════════════════════════════════════╝");

                          print("\n📋 Widget Values (BEFORE creating JSON):");
                          print("   • widget.mobile: ${widget.mobile}");
                          print("   • widget.firstname: ${widget.firstname}");
                          print("   • widget.lastname: ${widget.lastname}");
                          print("   • widget.email: ${widget.email}");
                          print("   • widget.vehicletype: ${widget.vehicletype}");
                          print("   • FFAppState().selectvehicle: ${FFAppState().selectvehicle}");
                          print("   • fcm_token: $fcm_token");

                          final driverJsonData = <String, dynamic>{
                            'mobile_number':  FFAppState().mobileNo,
                            'first_name':  FFAppState().firstName,
                            'last_name': FFAppState().lastName,
                            'email': FFAppState().email,
                            'referal_code': FFAppState().referralCode,
                            'fcm_token': fcm_token ?? '',
                          };

                          final vehicleJsonData = <String, dynamic>{
                            'vehicle_type': FFAppState().selectvehicle ?? widget.vehicletype ?? 'auto',
                          };

                          print("\n📦 Created JSON Objects:");
                          print("   • driverJsonData: $driverJsonData");
                          print("   • vehicleJsonData: $vehicleJsonData");
                          print("═══════════════════════════════════════════════════════════\n");

                          _model.apiResult7ju = await CreateDriverCall.call(
                            profileimage: FFAppState().profilePhoto,
                            licenseimage: FFAppState().imageLicense,
                            aadhaarimage: FFAppState().aadharImage,
                            panimage: FFAppState().panImage,
                            vehicleImage: FFAppState().vehicleImage,
                            registrationImage: FFAppState().registrationImage,
                            driverJson: driverJsonData,
                            vehicleJson: vehicleJsonData,
                            fcmToken: fcm_token ?? '',
                          );

                          print("\n╔════════════════════════════════════════════════════════════╗");
                          print("║              RESPONSE RECEIVED IN WIDGET                   ║");
                          print("╚════════════════════════════════════════════════════════════╝");
                          print("Status: ${_model.apiResult7ju?.statusCode}");
                          print("Success: ${_model.apiResult7ju?.succeeded}");
                          print("Body: ${_model.apiResult7ju?.jsonBody}");
                          print("═══════════════════════════════════════════════════════════\n");

                          if ((_model.apiResult7ju?.succeeded ?? false)) {
                            final driverId = getJsonField(
                              (_model.apiResult7ju?.jsonBody ?? ''),
                              r'''$.data.driver.id''',
                            );

                            final accessToken = getJsonField(
                              (_model.apiResult7ju?.jsonBody ?? ''),
                              r'''$.data.access_token''',
                            ).toString();

                            FFAppState().update(() {
                              FFAppState().isLoggedIn = true;
                              FFAppState().driverid = driverId;
                              FFAppState().accessToken = accessToken;
                            });

                            print("✅ SUCCESS - Driver Created!");
                            print("   • Driver ID: $driverId");
                            print("   • Access Token: $accessToken\n");

                            context.pushReplacementNamed(HomeWidget.routeName);
                          } else {
                            final errorMsg = getJsonField(
                              (_model.apiResult7ju?.jsonBody ?? ''),
                              r'''$.message''',
                            ).toString();

                            print("❌ ERROR: $errorMsg\n");

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMsg,
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                ),
                                duration: Duration(milliseconds: 4000),
                                backgroundColor:
                                FlutterFlowTheme.of(context).secondary,
                              ),
                            );
                          }

                          safeSetState(() {});
                        },
                        text: allDocsUploaded
                            ? FFLocalizations.of(context).getVariableText(
                          enText: 'Complete Registration',
                          hiText: 'पंजीकरण पूरा करें',
                          teText: 'రిజిస్ట్రేషన్ పూర్తి చేయండి',
                        )
                            : FFLocalizations.of(context).getVariableText(
                          enText: 'Skip for Now',
                          hiText: 'अभी छोड़ें',
                          teText: 'ఇప్పుడు స్కిప్ చేయండి',
                        ),
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 56.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconAlignment: IconAlignment.start,
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: allDocsUploaded
                              ? Color(0xFF10B981)
                              : Color(0xFFFF7B10),
                          textStyle: FlutterFlowTheme.of(context)
                              .titleMedium
                              .override(
                            font: GoogleFonts.interTight(
                              fontWeight: FontWeight.w600,
                            ),
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.0,
                          ),
                          elevation: 2.0,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isRecommended = false,
    bool isUploaded = false,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(12.0, 16.0, 12.0, 16.0),
        decoration: BoxDecoration(
          color: isUploaded
              ? Color(0xFFF0FDF4)
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isUploaded
                ? Color(0xFF10B981)
                : isRecommended
                ? Color(0xFFFF7B10)
                : FlutterFlowTheme.of(context).alternate,
            width: isUploaded || isRecommended ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: isUploaded
                    ? Color(0xFF10B981)
                    : isRecommended
                    ? Color(0xFFFF7B10).withOpacity(0.1)
                    : FlutterFlowTheme.of(context).alternate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded
                    ? Icons.check_circle
                    : isRecommended
                    ? Icons.star
                    : Icons.upload_file,
                color: isUploaded
                    ? Colors.white
                    : isRecommended
                    ? Color(0xFFFF7B10)
                    : FlutterFlowTheme.of(context).secondaryText,
                size: 20.0,
              ),
            ),
            SizedBox(width: 12.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                      font: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        if (isRecommended && !isUploaded)
                          Container(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                6.0, 2.0, 6.0, 2.0),
                            margin: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 8.0, 0.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF7B10).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                              'NEXT',
                              style: FlutterFlowTheme.of(context)
                                  .labelSmall
                                  .override(
                                font: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: Color(0xFFFF7B10),
                                fontSize: 10.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: FlutterFlowTheme.of(context)
                                .labelSmall
                                .override(
                              font: GoogleFonts.inter(),
                              color: isUploaded
                                  ? Color(0xFF10B981)
                                  : FlutterFlowTheme.of(context)
                                  .secondaryText,
                              fontSize: 13.0,
                              letterSpacing: 0.0,
                              fontWeight: isUploaded
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isUploaded
                  ? Color(0xFF10B981)
                  : FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
