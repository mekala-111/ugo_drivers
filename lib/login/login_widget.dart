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
            FFLocalizations.of(context).getText('login0010'),
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

    // 📐 RESPONSIVE SIZING (screenWidth / screenHeight media queries)
    final screenW = Responsive.screenWidth(context);
    final screenH = Responsive.screenHeight(context);
    final isTablet = Responsive.isLargeScreen(context);
    final isPortrait = screenH > screenW;

    // Header height: responsive to both width and height
    final headerHeight = Responsive.valueByHeight(
      context,
      at600: isPortrait ? 280.0 : 180.0,
      at700: isPortrait ? 320.0 : 200.0,
      at800: isPortrait ? (isTablet ? 360.0 : 340.0) : 220.0,
      defaultVal: isPortrait ? 340.0 : 200.0,
    );

    final scale = Responsive.scale(context);
    final hPad =
        Responsive.horizontalPadding(context) + (isTablet ? 16.0 : 0.0);
    final cardPadding = Responsive.valueByWidth(
      context,
      at360: 20.0,
      at600: 28.0,
      at900: 32.0,
      defaultVal: 24.0,
    );
    final cardHorizontalPad = Responsive.valueByWidth(
      context,
      at360: 16.0,
      at600: 24.0,
      at900: 40.0,
      defaultVal: 20.0,
    );

    final logoSize = Responsive.valueByWidth(
      context,
      at360: 80.0,
      at600: 110.0,
      at900: 120.0,
      defaultVal: 100.0,
    );
    final headlineFontSize = Responsive.fontSize(context, 36);
    final subtitleFontSize = Responsive.fontSize(context, 28);
    final phoneFontSize = Responsive.fontSize(context, 20);
    final buttonHeight = Responsive.buttonHeight(context, base: 56);
    final buttonFontSize = Responsive.fontSize(context, 18);
    // Max card width on tablets (centered layout)
    final maxCardWidth = Responsive.maxContentWidth(context);

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
                          padding: EdgeInsets.symmetric(horizontal: hPad),
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
                                  FFLocalizations.of(context)
                                      .getText('login0001'),
                                  style: GoogleFonts.inter(
                                    fontSize: headlineFontSize,
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8 * scale),
                              Center(
                                child: Text(
                                  FFLocalizations.of(context)
                                      .getText('login0002'),
                                  style: GoogleFonts.interTight(
                                    fontSize: subtitleFontSize,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: 60 * scale), // Space for card overlap
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ==========================================
                    // 2️⃣ FLOATING LOGIN CARD
                    // ==========================================
                    Transform.translate(
                      offset: Offset(
                          0,
                          Responsive.valueByHeight(context,
                                  at600: -32.0,
                                  at700: -36.0,
                                  at800: -40.0,
                                  defaultVal: -40.0) *
                              scale),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: cardHorizontalPad),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: maxCardWidth ?? double.infinity),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
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
                                      FFLocalizations.of(context)
                                          .getText('login0003'),
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
                                                    color: Colors.orange,
                                                    size: 20 * scale),
                                                SizedBox(width: 8 * scale),
                                                Text(
                                                  FFLocalizations.of(context)
                                                      .getText('login0012'),
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
                                            height: 24 * scale,
                                            color: Colors.grey[300],
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              controller: _model.textController,
                                              focusNode:
                                                  _model.textFieldFocusNode,
                                              autofocus: false,
                                              obscureText: false,
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType: TextInputType.phone,
                                              cursorColor: brandPrimary,
                                              style: GoogleFonts.inter(
                                                fontSize: phoneFontSize,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                                letterSpacing: 1.2,
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    10),
                                              ],
                                              decoration: InputDecoration(
                                                hintText:
                                                    FFLocalizations.of(context)
                                                        .getText('login0004'),
                                                hintStyle: GoogleFonts.inter(
                                                  color: Colors.grey[400],
                                                  fontSize: phoneFontSize,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: Responsive
                                                      .horizontalPadding(
                                                          context),
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
                                        onPressed:
                                            _isLoading ? null : _handleSendOtp,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: brandPrimary,
                                          foregroundColor: Colors.white,
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          disabledBackgroundColor: brandPrimary
                                              .withValues(alpha: 0.6),
                                        ),
                                        child: _isLoading
                                            ? SizedBox(
                                                height: 24 * scale,
                                                width: 24 * scale,
                                                child:
                                                    const CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                FFLocalizations.of(context)
                                                    .getText('login0005'),
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
                                                TextSpan(
                                                    text: FFLocalizations.of(
                                                            context)
                                                        .getText('login0006')),
                                                TextSpan(
                                                  text: FFLocalizations.of(
                                                          context)
                                                      .getText('login0007'),
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontSize: 12 * scale,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () =>
                                                        context.pushNamed(
                                                            TermsConditionsWidget
                                                                .routeName),
                                                ),
                                                TextSpan(
                                                    text: FFLocalizations.of(
                                                            context)
                                                        .getText('login0008')),
                                                TextSpan(
                                                  text: FFLocalizations.of(
                                                          context)
                                                      .getText('login0009'),
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontSize: 12 * scale,
                                                  ),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () =>
                                                        context.pushNamed(
                                                            PrivacyPolicyPageWidget
                                                                .routeName),
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
                      ),
                    ),

                    // ==========================================
                    // 3️⃣ SOCIAL LOGIN (Subtle Footer)
                    // ==========================================
                    SizedBox(height: Responsive.verticalSpacing(context)),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            indent: Responsive.valueByWidth(context,
                                at360: 24.0,
                                at600: 48.0,
                                at900: 64.0,
                                defaultVal: 40.0),
                            endIndent: Responsive.verticalSpacing(context),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: Responsive.verticalSpacing(context)),
                          child: Text(
                            FFLocalizations.of(context).getText('hczr77o0'),
                            style: GoogleFonts.inter(
                              fontSize: Responsive.fontSize(context, 12),
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            indent: Responsive.verticalSpacing(context),
                            endIndent: Responsive.valueByWidth(context,
                                at360: 24.0,
                                at600: 48.0,
                                at900: 64.0,
                                defaultVal: 40.0),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.verticalSpacing(context) * 2),

                    // 🔹 SOCIAL BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(
                          context,
                          icon: FontAwesomeIcons.google,
                          color: AppColors.googleRed,
                          onTap: () async {
                            setState(() => _isLoading = true);
                            try {
                              final user =
                                  await authManager.signInWithGoogle(context);
                              if (user != null) {
                                _handleSocialLoginSuccess(user);
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                        ),
                        SizedBox(
                            width: Responsive.verticalSpacing(context) * 2),
                        _socialButton(
                          context,
                          icon: Icons.apple,
                          color: Colors.black,
                          onTap: () async {
                            setState(() => _isLoading = true);
                            try {
                              final user =
                                  await authManager.signInWithApple(context);
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
                    SizedBox(
                        height: Responsive.valueByHeight(context,
                            at600: 24.0,
                            at700: 32.0,
                            at800: 40.0,
                            defaultVal: 40.0)),
                  ],
                ),
              ),
            );
          },
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
            FFLocalizations.of(context).getText('login0011'),
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(Responsive.horizontalPadding(context)),
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

  // 🔹 HELPER: Social Button (min 48dp touch target)
  Widget _socialButton(BuildContext context,
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    final btnSize = Responsive.buttonHeight(context, base: 56);
    final iconSize = Responsive.iconSize(context, base: 24);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: btnSize,
          height: btnSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Center(
            child: FaIcon(icon, color: color, size: iconSize),
          ),
        ),
      ),
    );
  }
}
