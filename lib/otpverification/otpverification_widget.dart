import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
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

  // ✅ Loading State
  bool _isLoading = false;

  // ✅ Timer State
  Timer? _resendTimer;
  int _timerSeconds = 30; // 30 Second Cool-down
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OtpverificationModel());
    _model.pinCodeFocusNode ??= FocusNode();

    // Start the timer immediately when screen loads
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _resendTimer = null;
    _model.dispose();
    super.dispose();
  }

  // ✅ Start Countdown Timer
  void _startResendTimer() {
    if (!mounted) return;
    setState(() {
      _timerSeconds = 30;
      _canResend = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timerSeconds > 0) {
        if (mounted) setState(() => _timerSeconds--);
      } else {
        if (mounted) setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  // ✅ Helper to safely get FCM Token
  Future<String> _getSafeFcmToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      return token ?? 'temp_token_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      if (kDebugMode) debugPrint('FCM Token Error: $e');
      return 'error_token';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 DRIVER APP COLORS
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;

    // 📐 RESPONSIVE SIZING
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    final isPortrait = size.height > size.width;

    final headerHeight = isPortrait
        ? (isTablet
            ? 320.0
            : isSmallScreen
                ? 260.0
                : 300.0)
        : (isTablet ? 240.0 : 200.0);
    final scale = isTablet
        ? 1.15
        : isSmallScreen
            ? 0.9
            : 1.0;
    final horizontalPadding = isTablet
        ? 40.0
        : isSmallScreen
            ? 16.0
            : 24.0;
    final cardPadding = isTablet
        ? 32.0
        : isSmallScreen
            ? 18.0
            : 24.0;
    final headerTopGap = isSmallScreen ? 12.0 * scale : 20.0 * scale;
    final headerBottomGap =
        (isSmallScreen || !isPortrait) ? 32.0 * scale : 60.0 * scale;

    final headerTitleSize = isSmallScreen ? 26.0 : (isTablet ? 36.0 : 30.0);
    final headerSubtitleSize = isSmallScreen ? 22.0 : (isTablet ? 30.0 : 26.0);
    final descriptionSize = isSmallScreen ? 13.0 : (isTablet ? 16.0 : 14.0);
    final pinTextSize = isSmallScreen ? 20.0 : (isTablet ? 26.0 : 22.0);
    final pinBoxHeight = isSmallScreen ? 44.0 : (isTablet ? 58.0 : 50.0);
    final pinBoxWidth = isSmallScreen ? 40.0 : (isTablet ? 52.0 : 45.0);
    final buttonHeight = isSmallScreen ? 50.0 : (isTablet ? 64.0 : 56.0);
    final buttonFontSize = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 18.0);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgOffWhite,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
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
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
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
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: headerTopGap),
                              const Spacer(),
                              Center(
                                child: Text(
                                  FFLocalizations.of(context)
                                      .getText('duko62qy'),
                                  style: TextStyle(
                                    fontSize: headerTitleSize,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Center(
                                child: Text(
                                  FFLocalizations.of(context)
                                      .getText('otpv0001'),
                                  style: TextStyle(
                                    fontSize: headerSubtitleSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: headerBottomGap),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ==========================================
                    // 2️⃣ FLOATING CARD
                    // ==========================================
                    Transform.translate(
                      offset: Offset(0, -40 * scale),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              isSmallScreen ? 16.0 : (isTablet ? 32.0 : 20.0),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(cardPadding),
                            child: Column(
                              children: [
                                Text(
                                  '${FFLocalizations.of(context).getText('otpv0002')}\n+91 ${widget.mobile}',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: descriptionSize,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 28 * scale),

                                // 🔢 PIN CODE FIELD
                                PinCodeTextField(
                                  appContext: context,
                                  length: 6,
                                  textStyle: GoogleFonts.inter(
                                    fontSize: pinTextSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  enableActiveFill: true,
                                  autoFocus: true,
                                  enablePinAutofill: true,
                                  errorTextSpace: 16,
                                  showCursor: true,
                                  cursorColor: brandPrimary,
                                  obscureText: false,
                                  keyboardType: TextInputType.number,
                                  pinTheme: PinTheme(
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(12),
                                    fieldHeight: pinBoxHeight,
                                    fieldWidth: pinBoxWidth,
                                    borderWidth: 1.5,
                                    activeColor: brandPrimary,
                                    inactiveColor: Colors.grey[200]!,
                                    selectedColor: brandPrimary,
                                    activeFillColor: Colors.white,
                                    selectedFillColor: AppColors.sectionOrange,
                                    inactiveFillColor: AppColors.backgroundCard,
                                  ),
                                  controller: _model.pinCodeController,
                                  onChanged: (_) {},
                                  onCompleted: (_) => _handleVerify(),
                                ),

                                SizedBox(height: 20 * scale),

                                // 🚀 VERIFY BUTTON
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _handleVerify,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: brandPrimary,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      disabledBackgroundColor:
                                          brandPrimary.withValues(alpha: 0.6),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            FFLocalizations.of(context)
                                                .getText('otpv0003'),
                                            style: GoogleFonts.interTight(
                                              fontSize: buttonFontSize,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(height: 20 * scale),

                                // 🔄 RESEND OTP WITH TIMER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${FFLocalizations.of(context).getText('otpv0004')} ',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          _canResend ? _handleResendOtp : null,
                                      child: Text(
                                        _canResend
                                            ? FFLocalizations.of(context)
                                                .getText('otpv0005')
                                            : '${FFLocalizations.of(context).getText('otpv0006')} $_timerSeconds s',
                                        style: TextStyle(
                                          color: _canResend
                                              ? brandPrimary
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🔹 LOGIC: Resend OTP
  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);

    try {
      // Trigger Firebase Phone Auth again
      await authManager.beginPhoneAuth(
        context: context,
        phoneNumber: '+91${widget.mobile}',
        onCodeSent: (context) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(FFLocalizations.of(context).getText('otpv0007')),
                backgroundColor: Colors.green,
              ),
            );
            _startResendTimer(); // Restart the 30s timer
            setState(() => _isLoading = false);
          }
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Resend Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(FFLocalizations.of(context).getText('otpv0008')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔹 LOGIC: Verify OTP & Navigate
  Future<void> _handleVerify() async {
    final smsCodeVal = _model.pinCodeController!.text;

    if (smsCodeVal.isEmpty || smsCodeVal.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FFLocalizations.of(context).getText('otpv0009')),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Verify with Firebase Auth
      final phoneVerifiedUser = await authManager.verifySmsCode(
        context: context,
        smsCode: smsCodeVal,
      );

      if (phoneVerifiedUser == null) {
        setState(() => _isLoading = false);
        return; // Auth failed
      }

      // 2. Get FCM Token
      final fcmToken = await _getSafeFcmToken();
      FFAppState().fcmToken = fcmToken;
      FFAppState().mobileNo = widget.mobile!;

      // 3. Call Backend to Check User Existence (include FCM token for push notifications)
      _model.apiResultk3y = await LoginCall.call(
        mobile: widget.mobile,
        fcmToken: fcmToken,
      );

      // 4. Navigate Based on Response
      // Assuming a success status (200-299) means the user exists.
      if (_model.apiResultk3y?.succeeded ?? false) {
        // ✅ EXISTING USER -> Go to Home
        FFAppState().isLoggedIn = true;
        FFAppState().isRegistered = true;

        // Safely extract Data (Assuming JSON structure: { "data": { "id": 123, "accessToken": "xyz" } })
        final jsonResponse = _model.apiResultk3y?.jsonBody ?? '';

        FFAppState().driverid = getJsonField(
          jsonResponse,
          r'''$.data.id''',
        );

        FFAppState().accessToken = getJsonField(
              jsonResponse,
              r'''$.data.accessToken''',
            )?.toString() ??
            '';

        if (mounted) {
          context.goNamedAuth(
            HomeWidget.routeName,
            context.mounted,
          );
        }
      } else {
        // ❌ NEW USER -> Go to Registration (First Details)
        FFAppState().isLoggedIn = true;
        FFAppState().isRegistered = false;
        FFAppState().registrationStep = 0;

        if (mounted) {
          // Changed from pushNamedAuth to goNamedAuth to prevent back navigation
          context.goNamedAuth(
            'firstdetails',
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
      if (kDebugMode) debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${FFLocalizations.of(context).getText('otpv0010')} ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
