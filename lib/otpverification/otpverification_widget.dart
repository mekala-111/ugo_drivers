import 'package:firebase_messaging/firebase_messaging.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'otpverification_model.dart';
export 'otpverification_model.dart';

/// OTP Verification Screen
class OtpverificationWidget extends StatefulWidget {
  const OtpverificationWidget({
    super.key,
    required this.mobile,
  });

  final int? mobile;
  static String routeName = 'otpverification';
  static String routePath = '/otpverification';

  @override
  State<OtpverificationWidget> createState() => _OtpverificationWidgetState();
}

class _OtpverificationWidgetState extends State<OtpverificationWidget> {
  late OtpverificationModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtpverificationModel());

    _model.pinCodeFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  // ✅ Helper to safely get FCM Token - PREVENTS CRASH
  Future<String> _getSafeFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      return token ?? "temp_token_${DateTime.now().millisecondsSinceEpoch}";
    } catch (e) {
      print("FCM Token Error: $e");
      return "error_token";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFF7B10), // Consistent Orange
          automaticallyImplyLeading: false,
          title: Text(
            FFLocalizations.of(context).getText(
              'duko62qy' /* Verification */,
            ),
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.interTight(
                    fontWeight: FontWeight.w600,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    FFLocalizations.of(context).getText(
                      'ujhimmtb' /* Enter the OTP to continue. */,
                    ),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          font: GoogleFonts.interTight(
                            fontWeight: FontWeight.w600,
                          ),
                          color: Colors.black,
                          fontSize: 24.0,
                        ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText(
                      'xupvugn4' /* We've sent you a 6-digit code ... */,
                    ),
                    textAlign: TextAlign.center,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.inter(),
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                  ),
                  PinCodeTextField(
                    autoDisposeControllers: false,
                    appContext: context,
                    length: 6,
                    textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    enableActiveFill: false,
                    autoFocus: true,
                    focusNode: _model.pinCodeFocusNode,
                    enablePinAutofill: true, // Enabled for better UX
                    errorTextSpace: 16.0,
                    showCursor: true,
                    cursorColor: const Color(0xFFFF7B10),
                    obscureText: false,
                    hintCharacter: '●',
                    keyboardType: TextInputType.number,
                    pinTheme: PinTheme(
                      fieldHeight: 44.0,
                      fieldWidth: 44.0,
                      borderWidth: 2.0,
                      borderRadius: BorderRadius.circular(12.0),
                      shape: PinCodeFieldShape.box,
                      activeColor: const Color(0xFFFF7B10),
                      inactiveColor: FlutterFlowTheme.of(context).alternate,
                      selectedColor: const Color(0xFFFF7B10),
                    ),
                    controller: _model.pinCodeController,
                    onChanged: (_) {},
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length < 6) {
                        return 'Enter 6 digits';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: FFButtonWidget(
                          onPressed: () {
                            print('Resend OTP pressed ...');
                            // Implement Resend Logic Here
                          },
                          text: FFLocalizations.of(context).getText(
                            'f9214evl' /* RESEND OTP */,
                          ),
                          options: FFButtonOptions(
                            height: 40.0,
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            color: Colors.transparent,
                            textStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: const Color(0xFFFF7B10),
                                  fontSize: 14.0,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: const Color(0xFFFF7B10),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      final smsCodeVal = _model.pinCodeController!.text;
                      if (smsCodeVal.isEmpty || smsCodeVal.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please enter valid 6-digit OTP.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      try {
                        // 1. Firebase Auth Verification
                        GoRouter.of(context).prepareAuthEvent();
                        final phoneVerifiedUser =
                            await authManager.verifySmsCode(
                          context: context,
                          smsCode: smsCodeVal,
                        );

                        if (phoneVerifiedUser == null) {
                          return; // Auth failed (User likely cancelled or error shown)
                        }

                        // 2. Get Safe FCM Token
                        final fcmToken = await _getSafeFcmToken();
                        FFAppState().fcmToken = fcmToken;
                        FFAppState().mobileNo = widget.mobile!;

                        // 3. Login API Call
                        _model.apiResultk3y = await LoginCall.call(
                          mobile: widget.mobile,
                        );

                        FFAppState().isLoggedIn = true;

                        if ((_model.apiResultk3y?.succeeded ?? false)) {
                          // ✅ CASE: User Found (Login Success)
                          FFAppState().isRegistered = true;
                          FFAppState().driverid = getJsonField(
                            (_model.apiResultk3y?.jsonBody ?? ''),
                            r'''$.data.id''',
                          );
                          FFAppState().accessToken = getJsonField(
                            (_model.apiResultk3y?.jsonBody ?? ''),
                            r'''$.data.accessToken''',
                          ).toString();

                          if (context.mounted) {
                            context.goNamedAuth(
                              HomeWidget.routeName,
                              context.mounted,
                            );
                          }
                        } else {
                          // ❌ CASE: User Not Found (Go to Registration)
                          // Assuming any failure here means "User needs to register"
                          // Ideally check for specific 404 status code if possible

                          FFAppState().isRegistered = false;
                          if (context.mounted) {
                            context.pushNamedAuth(
                              'firstdetails', // Ensure this route name matches your FirstdetailsWidget
                              context.mounted,
                              queryParameters: {
                                'mobile': serializeParam(
                                  widget.mobile,
                                  ParamType.int,
                                ),
                              }.withoutNulls,
                            );
                          }
                        }
                      } catch (e) {
                        print("Error during OTP processing: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('An error occurred. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      safeSetState(() {});
                    },
                    text: FFLocalizations.of(context).getText(
                      'k9o36d8i' /* VERIFY */,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      padding: EdgeInsets.all(8.0),
                      color: Color(0xFFFF7B10),
                      textStyle:
                          FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.interTight(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: Colors.white,
                                fontSize: 18.0,
                              ),
                      elevation: 2.0,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ]
                    .divide(SizedBox(height: 32.0))
                    .addToStart(SizedBox(height: 60.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
