import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Added for custom auth
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoginModel());
    _model.mobileNoTextController ??= TextEditingController();
    _model.mobileNoFocusNode ??= FocusNode();
    authManager.handlePhoneAuthStateChanges(context);
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
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FFLocalizations.of(context).getText('0wqdgogt'),
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'InterTight',
                      color: Colors.black,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w600,
                      lineHeight: 1.5,
                    ),
                  ),
                  Text(
                    FFLocalizations.of(context).getText('lu0ku0g6'),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Inter',
                      color: Colors.black,
                      fontSize: 16.0,
                      lineHeight: 1.5,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FFLocalizations.of(context).getText('kd9srmop'),
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.transparent, // Hidden text per your code
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: TextFormField(
                          controller: _model.mobileNoTextController,
                          focusNode: _model.mobileNoFocusNode,
                          autofocus: false,
                          textInputAction: TextInputAction.send,
                          obscureText: false,
                          decoration: InputDecoration(
                            hintText: FFLocalizations.of(context).getText('398um26d'),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xC7000000), width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFFF7B10), width: 2.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            filled: true,
                            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                            contentPadding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
                          ),
                          style: FlutterFlowTheme.of(context).bodyMedium.override(color: Colors.black),
                          keyboardType: TextInputType.phone,
                          validator: _model.mobileNoTextControllerValidator.asValidator(context),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                        ),
                      ),
                    ].divide(SizedBox(height: 16.0)),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      final phoneNumberVal = '+91${_model.mobileNoTextController.text}';
                      if (phoneNumberVal.isEmpty || !phoneNumberVal.startsWith('+')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Phone Number is required and has to start with +.')),
                        );
                        return;
                      }
                      await authManager.beginPhoneAuth(
                        context: context,
                        phoneNumber: phoneNumberVal,
                        onCodeSent: (context) async {
                          context.goNamedAuth(
                            OtpverificationWidget.routeName,
                            context.mounted,
                            queryParameters: {
                              'mobile': serializeParam(
                                int.tryParse(_model.mobileNoTextController.text),
                                ParamType.int,
                              ),
                            }.withoutNulls,
                            ignoreRedirect: true,
                          );
                        },
                      );
                    },
                    text: FFLocalizations.of(context).getText('m21mv0lk'),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 56.0,
                      color: Color(0xFFFF7B10),
                      textStyle: FlutterFlowTheme.of(context).titleMedium.override(
                        fontFamily: 'InterTight',
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 24.0,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),

                  // 🔥 SOCIAL LOGIN SECTION - DRIVER APP
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1.0,
                        decoration: BoxDecoration(color: Color(0x00CCCCCC)), // Note: Color is transparent in your snippet
                      ),
                      Text(
                        FFLocalizations.of(context).getText('hczr77o0'),
                        textAlign: TextAlign.center,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Colors.black,
                          fontSize: 16.0,
                          lineHeight: 1.2,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🟢 GOOGLE (Driver)
                          GestureDetector(
                            onTap: () async {
                              try {
                                GoRouter.of(context).prepareAuthEvent();
                                final user = await authManager.signInWithGoogle(context);
                                if (user != null && mounted) {
                                  context.goNamedAuth('HomePage', context.mounted); // Check route name
                                }
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google failed: $e')));
                              }
                            },
                            child: Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFFEFAFA),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Color(0xFFCCCCCC), width: 1.0),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: FaIcon(
                                  FontAwesomeIcons.google, // Fixed icon
                                  color: Color(0xFF4285F4),
                                  size: 25.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16.0),

                          // 🔵 FACEBOOK (Driver)
                          GestureDetector(
                            onTap: () async {
                              try {
                                final userCredential = await FirebaseAuth.instance.signInWithPopup(
                                  FacebookAuthProvider(),
                                );
                                if (userCredential.user != null && mounted) {
                                  context.goNamedAuth('HomePage', context.mounted);
                                }
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Facebook failed: $e')));
                              }
                            },
                            child: Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFFEFAFA),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Color(0xFFCCCCCC), width: 1.0),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.facebook,
                                  color: Color(0xFF1877F2),
                                  size: 25.0,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16.0),

                          // 🟤 APPLE (Driver)
                          GestureDetector(
                            onTap: () async {
                              try {
                                final userCredential = await FirebaseAuth.instance.signInWithPopup(
                                  AppleAuthProvider(),
                                );
                                if (userCredential.user != null && mounted) {
                                  context.goNamedAuth('HomePage', context.mounted);
                                }
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple failed: $e')));
                              }
                            },
                            child: Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFFEFAFA),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Color(0xFFCCCCCC), width: 1.0),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.apple,
                                  color: Colors.black,
                                  size: 25.0,
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(width: 16.0)),
                      ),
                    ].divide(SizedBox(height: 24.0)),
                  ),
                ].divide(SizedBox(height: 24.0)).addToStart(SizedBox(height: 60.0)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
