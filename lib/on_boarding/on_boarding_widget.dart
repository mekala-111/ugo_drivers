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
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.referalcode,
    required this.vehicletype,
  });

  final int? mobile;
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
  fcm_token = await FirebaseMessaging.instance.getToken();
  print('FCM TOKEN: $fcm_token');
}

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

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
                  fontWeight:
                      FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      FlutterFlowTheme.of(context).headlineMedium.fontStyle,
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
                // Header Section
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
                            enText: 'Welcome, ',
                            hiText: 'स्वागत है,',
                            teText: 'స్వాగతం,',
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
                        // Driving License Item
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'qg68530z' /* Driving License */,
                          ),
                          subtitle: FFLocalizations.of(context).getText(
                            'mnqkwauk' /* Recommended next step */,
                          ),
                          onTap: () {
                            context.pushNamed(DrivingDlWidget.routeName);
                          },
                          isRecommended: true,
                        ),

                        SizedBox(height: 4.0),
                        Divider(
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        SizedBox(height: 4.0),

                        // Profile Picture Item
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'k8fnkaky' /* Profile Picture */,
                          ),
                          onTap: () {
                            context.pushNamed(FaceVerifyWidget.routeName);
                          },
                        ),

                        SizedBox(height: 4.0),
                        Divider(
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        SizedBox(height: 4.0),

                        // Aadhaar Card Item
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'c0kv9v5c' /* Aadhaar Card */,
                          ),
                          onTap: () {
                            context.pushNamed(AdharUploadWidget.routeName);
                          },
                        ),

                        SizedBox(height: 4.0),
                        Divider(
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        SizedBox(height: 4.0),

                        // Pan Card Item
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'ymy7qbgz' /* Pan Card */,
                          ),
                          onTap: () {
                            context.pushNamed(
                                PanuploadScreenWidget.routeName);
                          },
                        ),

                        SizedBox(height: 4.0),
                        Divider(
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        SizedBox(height: 4.0),

                        // Vehicle Photo Item
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'jqs0l5w3' /* Vehicle photo verification */,
                          ),
                          onTap: () {
                            context.pushNamed(VehicleImageWidget.routeName);
                          },
                        ),

                        SizedBox(height: 4.0),
                        Divider(
                          thickness: 1.0,
                          color: FlutterFlowTheme.of(context).alternate,
                        ),
                        SizedBox(height: 4.0),

                        // Registration Certificate Item
                        _buildStepItem(
                          context: context,
                          title: FFLocalizations.of(context).getText(
                            'ipks4vgn' /* Registration Certificate (RC) */,
                          ),
                          onTap: () {
                            context.pushNamed(
                                RegistrationImageWidget.routeName);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Register Button
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                      24.0, 16.0, 24.0, 24.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      _model.apiResult7ju = await CreateDriverCall.call(
                        profileimage: FFAppState().profilePhoto,
                        licenseimage: FFAppState().imageLicense,
                        aadhaarimage: FFAppState().aadharImage,
                        panimage: FFAppState().panImage,
                        vehicleImage: FFAppState().vehicleImage,
                       registrationImage: FFAppState().registrationImage,
                        driverJson: <String, dynamic>{
                          'mobile_number': widget.mobile,
                          'first_name': widget.firstname,
                          'last_name': widget.lastname,
                          'email': widget.email,
                        },
                        vehicleJson: <String, dynamic>{
                          'vehicle_type': FFAppState().selectvehicle,
                        },
                        fcmToken: fcm_token
                      );
                      print('CreateDriver API Response: ${_model.apiResult7ju?.jsonBody}');

                      if ((_model.apiResult7ju?.succeeded ?? true)) {
                        FFAppState().update(() {
                        FFAppState().isLoggedIn = true;   // ✅ user logged in
                        FFAppState().driverid = getJsonField(
                            (_model.apiResult7ju?.jsonBody ?? ''),
                            r'''$.data.driver.id''',
                          );
                                 // ✅ example (use real id)
                        FFAppState().accessToken = getJsonField(
                            (_model.apiResult7ju?.jsonBody ?? ''),
                            r'''$.data.access_token''',
                          ).toString();
                          ; // ✅ example
                      });
                      print('Driver Created Successfully with ID: ${FFAppState().driverid} and Access Token: ${FFAppState().accessToken}');
                        context.pushReplacementNamed(HomeWidget.routeName);

                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              getJsonField(
                                (_model.apiResult7ju?.jsonBody ?? ''),
                                r'''$.message''',
                              ).toString(),
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
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
                    text: 
                    // FFLocalizations.of(context).getText(
                    //   // 'rgs1skp0',
                    // ),
                     FFLocalizations.of(context).getVariableText(
                        enText: 'Registration/Skip',
                        hiText: 'पंजीकरण/छोड़ें',
                        teText: 'రిజిస్ట్రేషన్/స్కిప్',
                      ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 0.0),
                      iconAlignment: IconAlignment.start,
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Color(0xFFFF7B10),
                      textStyle:
                          FlutterFlowTheme.of(context).titleMedium.override(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent step items
  Widget _buildStepItem({
    required BuildContext context,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isRecommended = false,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(8.0, 12.0, 8.0, 12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(
                            fontWeight: FontWeight.w500,
                          ),
                          color: FlutterFlowTheme.of(context).primaryText,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: FlutterFlowTheme.of(context).labelSmall.override(
                            font: GoogleFonts.inter(),
                            color:
                                FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}