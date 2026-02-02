
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ugo_driver/flutter_flow/flutter_flow_theme.dart';
import 'package:haptic_feedback/haptic_feedback.dart'; // Import haptic feedback

class OtpVerificationWidget extends StatefulWidget {
  const OtpVerificationWidget({Key? key}) : super(key: key);

  @override
  State<OtpVerificationWidget> createState() => _OtpVerificationWidgetState();
}

class _OtpVerificationWidgetState extends State<OtpVerificationWidget> {
  final TextEditingController _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? currentText;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      // Trigger haptic feedback on successful OTP entry
      HapticFeedback.lightImpact();

      // Placeholder for backend OTP verification
      // In a real app, you would send _otpController.text to your backend
      // and await the response.
      print('Verifying OTP: \${_otpController.text}');

      // Simulate a successful verification
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to the next screen (Go to Pickup Zone Screen)
      // You'll need to define this route in your main.dart or routing setup.
      // For now, let's just pop to simulate going back or push a placeholder.
      if (mounted) {
        Navigator.pop(context, true); // Pop with a result indicating success
      }
    } else {
      HapticFeedback.heavyImpact(); // Haptic feedback for invalid input
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        automaticallyImplyLeading: false,
        title: Text(
          'Enter the OTP to continue.',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: FlutterFlowTheme.of(context).primaryText,
                fontSize: 22.0,
              ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Form(
                key: _formKey,
                child: PinCodeTextField(
                  appContext: context,
                  length: 4,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8.0),
                    fieldHeight: 60.0,
                    fieldWidth: 60.0,
                    activeFillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    inactiveFillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    selectedFillColor: FlutterFlowTheme.of(context).secondaryBackground,
                    activeColor: FlutterFlowTheme.of(context).primary,
                    inactiveColor: FlutterFlowTheme.of(context).alternate,
                    selectedColor: FlutterFlowTheme.of(context).primary,
                  ),
                  cursorColor: FlutterFlowTheme.of(context).primary,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  boxShadows: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onChanged: (value) {
                    setState(() {
                      currentText = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 4) {
                      return "Please enter a valid OTP";
                    }
                    return null;
                  },
                  onCompleted: (v) {
                    _verifyOtp();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: ElevatedButton(
                  onPressed: currentText != null && currentText!.length == 4
                      ? _verifyOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FlutterFlowTheme.of(context).primary,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Verify OTP',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
