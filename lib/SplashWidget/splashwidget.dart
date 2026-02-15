import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:flutter/material.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({super.key});

  static String routeName = 'Splash';
  static String routePath = '/splash';

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Check if user is Logged In (OTP Verified)
      if (FFAppState().isLoggedIn) {

        // 2. Check if Registration is Complete
        if (FFAppState().isRegistered) {
          // ✅ Logged In & Registered -> Go Home
          context.goNamed(HomeWidget.routeName);
        } else {
          // ⚠️ Logged In BUT Not Registered -> Go to First Details
          // We pass the mobile number stored in AppState so they don't lose context
          context.goNamed(
            FirstdetailsWidget.routeName,
            queryParameters: {
              'mobile': serializeParam(
                FFAppState().mobileNo,
                ParamType.int,
              ),
            }.withoutNulls,
          );
        }

      } else {
        // ❌ Not Logged In -> Go to Login
        context.goNamed(LoginWidget.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure background isn't black during load
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF7B10), // Match your brand color
        ),
      ),
    );
  }
}