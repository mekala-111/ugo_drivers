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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Not logged in → Login
      if (!FFAppState().isLoggedIn) {
        context.goNamed(LoginWidget.routeName);
        return;
      }

      // Logged in but NOT registered → Login
      if (FFAppState().isLoggedIn && !FFAppState().isRegistered) {
        context.goNamed(LoginWidget.routeName);
        return;
      }

      // Logged in AND registered → Home
      context.goNamed(HomeWidget.routeName);
    });
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


