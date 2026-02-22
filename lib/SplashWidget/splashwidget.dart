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
          // ⚠️ Logged In BUT Not Registered -> Resume from where user stopped
          final registrationStep = FFAppState().registrationStep;
          
          // Route based on current registration step
          if (registrationStep >= 4) {
            // Step 4+: OnBoarding (final registration page)
            context.goNamed(OnBoardingWidget.routeName);
          } else if (registrationStep >= 3) {
            // Step 3: ChooseVehicle
            context.goNamed(ChooseVehicleWidget.routeName);
          } else if (registrationStep >= 2) {
            // Step 2: AddressDetails
            context.goNamed(
              AddressDetailsWidget.routeName,
              queryParameters: {
                'mobile': serializeParam(
                  FFAppState().mobileNo,
                  ParamType.int,
                ),
              }.withoutNulls,
            );
          } else {
            // Step 0, 1, or unset: Start from FirstDetails
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
        }
      } else {
        // ❌ Not Logged In -> Go to Language Select if needed
        final storedLocale = FFLocalizations.getStoredLocale();
        if (storedLocale == null) {
          context.goNamed(LanguageSelectWidget.routeName);
        } else {
          context.goNamed(LoginWidget.routeName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:
          Colors.white, // Ensure background isn't black during load
      body: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary, // Match your brand color
        ),
      ),
    );
  }
}
