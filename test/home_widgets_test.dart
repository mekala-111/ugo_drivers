import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ugo_driver/flutter_flow/internationalization.dart';
import 'package:ugo_driver/home/widgets/earnings_panel.dart';
import 'package:ugo_driver/home/widgets/incentive_panel.dart';
import 'package:ugo_driver/home/widgets/online_toggle.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await FFLocalizations.initialize();
  });

  group('Home extracted widgets', () {
    testWidgets('OnlineToggle renders ON when switchValue is true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnlineToggle(
              switchValue: true,
              isDataLoaded: true,
              onToggle: () {},
            ),
          ),
        ),
      );
      expect(find.text('ON'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('OnlineToggle renders OFF when switchValue is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnlineToggle(
              switchValue: false,
              isDataLoaded: true,
              onToggle: () {},
            ),
          ),
        ),
      );
      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('OnlineToggle switch is disabled when isDataLoaded is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OnlineToggle(
              switchValue: false,
              isDataLoaded: false,
              onToggle: () {},
            ),
          ),
        ),
      );
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('EarningsPanel shows today total', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: FFLocalizations.languages()
              .map((l) => Locale(l))
              .toList(),
          localizationsDelegates: const [
            FFLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: EarningsPanel(
                isExpanded: false,
                isLoadingEarnings: false,
                todayTotal: 450.0,
                todayRideCount: 8,
                todayWallet: 320.0,
                lastRideAmount: 55.0,
                onTap: () {},
                screenWidth: 400,
                isSmallScreen: false,
              ),
            ),
          ),
        ),
      );
      expect(find.text('450'), findsOneWidget);
    });

    testWidgets('IncentivePanel builds when collapsed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: FFLocalizations.languages()
              .map((l) => Locale(l))
              .toList(),
          localizationsDelegates: const [
            FFLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Scaffold(
            body: IncentivePanel(
              isExpanded: false,
              isLoadingIncentives: false,
              incentiveTiers: const [],
              currentRides: 0,
              totalIncentiveEarned: 0.0,
              onTap: () {},
              screenWidth: 400,
              isSmallScreen: false,
            ),
          ),
        ),
      );
      expect(find.byType(IncentivePanel), findsOneWidget);
    });
  });
}
