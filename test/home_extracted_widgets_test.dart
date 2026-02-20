import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ugo_driver/flutter_flow/flutter_flow_util.dart';
import 'package:ugo_driver/flutter_flow/internationalization.dart';
import 'package:ugo_driver/home/ride_request_overlay.dart';
import 'package:ugo_driver/home/widgets/app_header.dart';
import 'package:ugo_driver/home/widgets/bottom_ride_panel.dart';
import 'package:ugo_driver/home/widgets/earnings_summary.dart';

/// 3 critical tests for newly extracted Home widgets.
void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await FFLocalizations.initialize();
  });

  group('Home - Extracted widgets (5-widget refactor)', () {
    // ── 1. EarningsSummary ───────────────────────────────────────────────────
    testWidgets('EarningsSummary shows todayTotal, teamEarnings, ridesToday',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales:
              FFLocalizations.languages().map((l) => Locale(l)).toList(),
          localizationsDelegates: const [
            FFLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: EarningsSummary(
              todayTotal: 450.0,
              teamEarnings: 320.0,
              ridesToday: 8,
              isLoading: false,
              isSmallScreen: false,
            ),
          ),
        ),
      );
      expect(find.text('450'), findsOneWidget);
      expect(find.text('320'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
    });

    // ── 2. AppHeader ─────────────────────────────────────────────────────────
    testWidgets('AppHeader renders with balance and online toggle',
        (tester) async {
      final scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              scaffoldKey: scaffoldKey,
              switchValue: false,
              isDataLoaded: true,
              onToggleOnline: () {},
              screenWidth: 400,
              isSmallScreen: false,
              balance: 1200.0,
              profileImageUrl: null,
              notificationCount: 0,
            ),
          ),
        ),
      );
      expect(find.text('₹1200'), findsOneWidget);
      expect(find.text('OFF'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    // ── 3. BottomRidePanel (RideRequestOverlay integration) ───────────────────
    testWidgets('BottomRidePanel builds without crashing', (tester) async {
      final overlayKey = GlobalKey<RideRequestOverlayState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BottomRidePanel(
              overlayKey: overlayKey,
              onRideComplete: () {},
              driverLocation: null,
            ),
          ),
        ),
      );
      expect(find.byType(BottomRidePanel), findsOneWidget);
    });
  });
}
