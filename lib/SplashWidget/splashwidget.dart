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
      debugPrint('UGO_SPLASH: Starting navigation check...');
      // 1. Check if user is Logged In (OTP Verified)
      if (FFAppState().isLoggedIn) {
        debugPrint('UGO_SPLASH: User is Logged In. Checking registration...');
        // 2. Check if Registration is Complete
        if (FFAppState().isRegistered) {
          debugPrint('UGO_SPLASH: User is Registered. Going to Home.');
          // ✅ Logged In & Registered -> Go Home
          context.goNamed(HomeWidget.routeName);
        } else {
          // ⚠️ Logged In BUT Not Registered -> Resume from where user stopped
          final registrationStep = FFAppState().registrationStep;
          debugPrint('UGO_SPLASH: User is NOT Registered. Step: $registrationStep');

          // Route based on current registration step
          if (registrationStep >= 4) {
            debugPrint(
                'UGO_SPLASH: Going to PreferredEarningMode (final signup step).');
            context.goNamed(PreferredEarningModeWidget.routeName);
          } else if (registrationStep >= 2) {
            debugPrint('UGO_SPLASH: Going to ChooseVehicle (Step 2 or 3).');
            // Step 2: ChooseVehicle
            context.goNamed(ChooseVehicleWidget.routeName);
          } else {
            debugPrint('UGO_SPLASH: Going to FirstDetails (Step 0 or 1).');
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
