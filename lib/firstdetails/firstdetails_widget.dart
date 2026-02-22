import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firstdetails_model.dart';
export 'firstdetails_model.dart';

// ✅ Ensure ChooseVehicleWidget is imported

class FirstdetailsWidget extends StatefulWidget {
  const FirstdetailsWidget({
    super.key,
    required this.mobile,
  });

  final int? mobile;

  static String routeName = 'firstdetails';
  static String routePath = '/firstdetails';

  @override
  State<FirstdetailsWidget> createState() => _FirstdetailsWidgetState();
}

class _FirstdetailsWidgetState extends State<FirstdetailsWidget> {
  late FirstdetailsModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FirstdetailsModel());

    // Mark current step for resume functionality
    FFAppState().registrationStep = 1;

    _model.textController1 ??=
        TextEditingController(text: FFAppState().firstName);
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??=
        TextEditingController(text: FFAppState().lastName);
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??=
        TextEditingController(text: FFAppState().email);
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??=
        TextEditingController(text: FFAppState().referralCode);
    _model.textFieldFocusNode4 ??= FocusNode();

    _model.textController1?.addListener(() {
      FFAppState().firstName = _model.textController1?.text ?? '';
    });
    _model.textController2?.addListener(() {
      FFAppState().lastName = _model.textController2?.text ?? '';
    });
    _model.textController3?.addListener(() {
      FFAppState().email = _model.textController3?.text ?? '';
    });
    _model.textController4?.addListener(() {
      FFAppState().referralCode = _model.textController4?.text ?? '';
    });
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 APP COLORS
    const Color brandPrimary = AppColors.primary;
    const Color brandGradientStart = AppColors.primaryGradientStart;
    const Color bgOffWhite = AppColors.backgroundAlt;

    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final isSmall = width < 360;
    final isTablet = width >= 600;
    final horizontalPadding = isTablet ? 48.0 : (isSmall ? 16.0 : 24.0);
    final headerHeight = (height * 0.3).clamp(220.0, 320.0);
    final titleSize = isTablet ? 34.0 : (isSmall ? 26.0 : 30.0);
    final subtitleSize = isTablet ? 26.0 : (isSmall ? 20.0 : 24.0);
    final cardPadding = isTablet ? 32.0 : 24.0;
    final buttonHeight = isSmall ? 50.0 : 56.0;
    final cardMaxWidth = isTablet ? 520.0 : double.infinity;

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
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isSmall ? 12 : 20),
                        const Spacer(),
                        Center(
                          child: Text(
                            FFLocalizations.of(context).getText('fd0001'),
                            style: GoogleFonts.inter(
                              fontSize: titleSize,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            FFLocalizations.of(context).getText('fd0002'),
                            style: GoogleFonts.interTight(
                              fontSize: subtitleSize,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmall ? 36 : 50), // Spacer for card overlap
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================
              // 2️⃣ FLOATING FORM CARD
              // ==========================================
              Transform.translate(
                offset: Offset(0, isSmall ? -28 : -40),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: cardMaxWidth),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                FFLocalizations.of(context).getText('fd0003'),
                                style: GoogleFonts.inter(
                                  fontSize: isTablet ? 26 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // FIRST NAME
                            _buildTextField(
                              context,
                              label: FFLocalizations.of(context).getText('oezel2cu'),
                              controller: _model.textController1,
                              focusNode: _model.textFieldFocusNode1,
                              icon: Icons.person_outline,
                              validator: (val) {
                                if (val == null || val.isEmpty) return FFLocalizations.of(context).getText('fd0004');
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // LAST NAME
                            _buildTextField(
                              context,
                              label: FFLocalizations.of(context).getText('9blspwgp'),
                              controller: _model.textController2,
                              focusNode: _model.textFieldFocusNode2,
                              icon: Icons.person,
                            ),
                            const SizedBox(height: 20),

                            // EMAIL
                            _buildTextField(
                              context,
                              label: FFLocalizations.of(context).getText('3xyysbhm'),
                              controller: _model.textController3,
                              focusNode: _model.textFieldFocusNode3,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.isEmpty) return FFLocalizations.of(context).getText('fd0004');
                                if (!val.contains('@')) return FFLocalizations.of(context).getText('fd0005');
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // REFERRAL CODE
                            _buildTextField(
                              context,
                              label: FFLocalizations.of(context).getText('fd0006'),
                              controller: _model.textController4,
                              focusNode: _model.textFieldFocusNode4,
                              icon: Icons.confirmation_number_outlined,
                            ),
                            const SizedBox(height: 32),

                            // CONTINUE BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: buttonHeight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // 1. Validate Form
                                  if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                                    return;
                                  }

                                  // 2. Save Data to Global State
                                  FFAppState().firstName = _model.textController1.text;
                                  FFAppState().lastName = _model.textController2.text;
                                  FFAppState().email = _model.textController3.text;
                                  FFAppState().referralCode = _model.textController4.text;

                                  // 3. Update registration step (for resume functionality)
                                  FFAppState().registrationStep = 1;

                                  // 4. Navigate to Address & Emergency step (Uber-style)
                                  context.pushNamed(
                                    AddressDetailsWidget.routeName,
                                    queryParameters: {
                                      'mobile': serializeParam(widget.mobile, ParamType.int),
                                      'firstname': serializeParam(_model.textController1.text, ParamType.String),
                                      'lastname': serializeParam(_model.textController2.text, ParamType.String),
                                      'email': serializeParam(_model.textController3.text, ParamType.String),
                                      'referalcode': serializeParam(_model.textController4.text, ParamType.String),
                                    }.withoutNulls,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandPrimary,
                                  foregroundColor: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  FFLocalizations.of(context).getText('xtbkk4x0'),
                                  style: GoogleFonts.interTight(
                                    fontSize: isTablet ? 20 : 18,
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
                ),
              ),
              const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 🔹 Custom Text Field Builder
  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required TextEditingController? controller,
        required FocusNode? focusNode,
        required IconData icon,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
            filled: true,
            fillColor: AppColors.backgroundCard,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}