import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart'; // Ensure this exports ChooseVehicleWidget
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firstdetails_model.dart';
export 'firstdetails_model.dart';

// ✅ Ensure ChooseVehicleWidget is imported to access .routeName
import '/choose_vehicle/choose_vehicle_widget.dart';

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

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FFLocalizations.of(context).getText('nh50n2jd' /* We need your sign-in details... */),
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // First Name
                    _buildTextField(
                      context,
                      label: 'First Name',
                      controller: _model.textController1,
                      focusNode: _model.textFieldFocusNode1,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'First Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Last Name
                    _buildTextField(
                      context,
                      label: 'Last Name',
                      controller: _model.textController2,
                      focusNode: _model.textFieldFocusNode2,
                    ),
                    const SizedBox(height: 16.0),

                    // Email
                    _buildTextField(
                      context,
                      label: 'Email Address',
                      controller: _model.textController3,
                      focusNode: _model.textFieldFocusNode3,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Email is required';
                        }
                        if (!val.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // Referral Code
                    _buildTextField(
                      context,
                      label: 'Referral code (Optional)',
                      controller: _model.textController4,
                      focusNode: _model.textFieldFocusNode4,
                    ),
                    const SizedBox(height: 32.0),

                    // Continue Button
                    FFButtonWidget(
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

                        // 3. Navigate (Using Static Route Name for Safety)
                        context.pushNamed(
                          ChooseVehicleWidget.routeName, // ✅ FIXED: Safe Navigation
                          queryParameters: {
                            'mobile': serializeParam(widget.mobile, ParamType.int),
                            'firstname': serializeParam(_model.textController1.text, ParamType.String),
                            'lastname': serializeParam(_model.textController2.text, ParamType.String),
                            'email': serializeParam(_model.textController3.text, ParamType.String),
                            'referalcode': serializeParam(_model.textController4.text, ParamType.String),
                          }.withoutNulls,
                        );
                      },
                      text: FFLocalizations.of(context).getText('krnpfx67' /* Continue */),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50.0,
                        color: const Color(0xFFFF7B10),
                        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.interTight(fontWeight: FontWeight.w600),
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                        elevation: 0.0,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      BuildContext context, {
        required String label,
        required TextEditingController? controller,
        required FocusNode? focusNode,
        TextInputType? keyboardType,
        String? Function(String?)? validator,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: false,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: FlutterFlowTheme.of(context).alternate, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFF7B10), width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          style: FlutterFlowTheme.of(context).bodyLarge.override(
            font: GoogleFonts.inter(),
          ),
          validator: validator,
        ),
      ],
    );
  }
}