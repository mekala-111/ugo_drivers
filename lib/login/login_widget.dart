import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_model.dart';
export 'login_model.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  static String routeName = 'login';
  static String routePath = '/login';

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  late LoginModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // ✅ Loading State
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

    // Listen to auth changes
    authManager.handlePhoneAuthStateChanges(context);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  // 🔹 LOGIC: Handle Social Login Results
  void _handleSocialLoginSuccess(BaseAuthUser user) {
    // Uber-like Flow: Phone number is the primary identity for drivers.
    // If the social account doesn't provide a phone number, we force the user to enter it.
    if (user.phoneNumber == null || user.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification Required: Please enter your mobile number to complete registration.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Auto-focus the phone field to guide the user
      _model.textFieldFocusNode?.requestFocus();
    } else {
      // If phone is verified, proceed to Home (or Location Preference screen)
      context.goNamed(HomeWidget.routeName);
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
        ? (isTablet ? 360.0 : isSmallScreen ? 300.0 : 340.0)
        : (isTablet ? 280.0 : 200.0);
    
    final scale = isTablet ? 1.2 : isSmallScreen ? 0.85 : 1.0;
    final horizontalPadding = isTablet ? 40.0 : isSmallScreen ? 16.0 : 24.0;
    final cardPadding = isTablet ? 32.0 : isSmallScreen ? 20.0 : 24.0;
    
    final logoSize = isSmallScreen ? 80.0 : (isTablet ? 120.0 : 100.0);
    final headlineFontSize = isSmallScreen ? 28.0 : (isTablet ? 42.0 : 36.0);
    final subtitleFontSize = isSmallScreen ? 22.0 : (isTablet ? 32.0 : 28.0);
    final phoneFontSize = isSmallScreen ? 16.0 : (isTablet ? 24.0 : 20.0);
    final buttonHeight = isSmallScreen ? 50.0 : (isTablet ? 64.0 : 58.0);
    final buttonFontSize = isSmallScreen ? 16.0 : (isTablet ? 20.0 : 18.0);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: bgOffWhite,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ==========================================
              // 1️⃣ VIBRANT HEADER (Curved Bottom)
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
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        // App Icon / Logo Placeholder
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/app_launcher_icon.png',
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.local_taxi_rounded,
                                  color: Colors.white,
                                  size: logoSize * 0.4,
                                );
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            'Welcome Partner,',
                            style: GoogleFonts.inter(
                              fontSize: headlineFontSize,
                              color: Colors.white.withValues(alpha:0.9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Center(
                          child: Text(
                            "Let's get you on the road.",
                            style: GoogleFonts.interTight(
                              fontSize: subtitleFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(height: 60 * scale), // Space for card overlap
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================
              // 2️⃣ FLOATING LOGIN CARD
              // ==========================================
              Transform.translate(
                offset: Offset(0, -40 * scale),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : (isTablet ? 32.0 : 20.0)),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.08),
                          blurRadius: 20 * scale,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Mobile Number',
                            style: GoogleFonts.inter(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 12 * scale),

                          // 📱 PHONE INPUT FIELD
                          Container(
                            height: 60 * scale,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.divider,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.0 * scale),
                                  child: Row(
                                    children: [
                                      Icon(Icons.flag,
                                          color: Colors.orange, size: 20 * scale),
                                      SizedBox(width: 8 * scale),
                                      Text(
                                        '+91',
                                        style: GoogleFonts.inter(
                                          fontSize: 18 * scale,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey[300],
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _model.textController,
                                    focusNode: _model.textFieldFocusNode,
                                    autofocus: false,
                                    obscureText: false,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.phone,
                                    cursorColor: brandPrimary,
                                    style: GoogleFonts.inter(
                                      fontSize: phoneFontSize,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      letterSpacing: 1.2,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Mobile Number',
                                      hintStyle: GoogleFonts.inter(
                                        color: Colors.grey[400],
                                        fontSize: phoneFontSize,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 18 * scale,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 32 * scale),

                          // 🚀 ACTION BUTTON (GET OTP)
                          SizedBox(
                            width: double.infinity,
                            height: buttonHeight,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandPrimary,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                disabledBackgroundColor:
                                brandPrimary.withValues(alpha:0.6),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: 24 * scale,
                                width: 24 * scale,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                                  : Text(
                                'Get OTP',
                                style: GoogleFonts.interTight(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 24 * scale),

                          // 📄 LEGAL TEXT (tappable)
                          Center(
                            child: Builder(
                              builder: (context) {
                                return RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 12 * scale,
                                      color: Colors.grey[500],
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(text: 'By continuing, you agree to our\n'),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          fontSize: 12 * scale,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => context.pushNamed(TermsConditionsWidget.routeName),
                                      ),
                                      const TextSpan(text: ' & '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          fontSize: 12 * scale,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => context.pushNamed(PrivacyPolicyPageWidget.routeName),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ==========================================
              // 3️⃣ SOCIAL LOGIN (Subtle Footer)
              // ==========================================
              SizedBox(height: 10 * scale),

              Row(
                children: [
                  const Expanded(child: Divider(indent: 40, endIndent: 10)),
                  Text(
                    'Or connect with',
                    style: GoogleFonts.inter(
                      fontSize: 12 * scale,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Expanded(child: Divider(indent: 10, endIndent: 40)),
                ],
              ),
              SizedBox(height: 20 * scale),

              // 🔹 SOCIAL BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    icon: FontAwesomeIcons.google,
                    color: AppColors.googleRed,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      try {
                        final user = await authManager.signInWithGoogle(context);
                        if (user != null) {
                          _handleSocialLoginSuccess(user);
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),
                  SizedBox(width: 20 * scale),
                  _socialButton(
                    icon: Icons.apple,
                    color: Colors.black,
                    onTap: () async {
                      setState(() => _isLoading = true);
                      try {
                        final user = await authManager.signInWithApple(context);
                        if (user != null) {
                          _handleSocialLoginSuccess(user);
                        }
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 40 * scale),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 LOGIC: Send OTP
  Future<void> _handleSendOtp() async {
    final phoneText = _model.textController.text.trim();

    if (phoneText.isEmpty || phoneText.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid 10-digit mobile number.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact(); // Touch Feedback

    final phoneNumberVal = '+91$phoneText';

    await authManager.beginPhoneAuth(
      context: context,
      phoneNumber: phoneNumberVal,
      onCodeSent: (context) async {
        if (mounted) {
          setState(() => _isLoading = false);

          context.goNamedAuth(
            OtpverificationWidget.routeName,
            context.mounted,
            queryParameters: {
              'mobile': serializeParam(
                int.tryParse(phoneText),
                ParamType.int,
              ),
            }.withoutNulls,
            ignoreRedirect: true,
          );
        }
      },
    );

    // Safety timeout
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    });
  }

  // 🔹 HELPER: Social Button
  Widget _socialButton(
      {required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isTablet = size.width >= 600;
    final socialButtonSize = isSmallScreen ? 48.0 : (isTablet ? 64.0 : 55.0);
    
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: socialButtonSize,
        height: socialButtonSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: FaIcon(icon, color: color, size: 24 * (socialButtonSize / 55)),
        ),
      ),
    );
  }
}