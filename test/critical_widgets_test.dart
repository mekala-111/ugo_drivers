import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ugo_driver/app_state.dart';
import 'package:ugo_driver/home/widgets/online_toggle.dart';
import 'package:ugo_driver/providers/ride_provider.dart';
import 'package:ugo_driver/widgets/error_boundary.dart';

/// 3 CRITICAL widget tests for Play Store production readiness.
/// Covers: ErrorBoundary resilience, core driver UI, app shell.
void main() {
  group('UGO Driver - Critical Widget Tests', () {
    // ── 1. ErrorBoundary: Renders child normally ─────────────────────────────
    testWidgets('ErrorBoundary renders child when no error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Scaffold(
              body: Center(child: Text('Hello')),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    // ── 2. ErrorBoundary: Shows fallback when child throws ───────────────────
    testWidgets('ErrorBoundary shows fallback UI when child throws',
        (tester) async {
      FlutterError.onError = (_) {}; // Suppress log so test doesn't fail
      addTearDown(() {
        FlutterError.onError = FlutterError.presentError;
      });
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Builder(
              builder: (_) => throw Exception('Simulated build error'),
            ),
          ),
        ),
      );
      await tester.pump(); // Allow error handling to complete
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    // ── 3. App shell + ErrorBoundary + OnlineToggle (core driver UI) ─────────
    testWidgets('App providers with ErrorBoundary and OnlineToggle build',
        (tester) async {
      var toggleCalled = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: FFAppState()),
            ChangeNotifierProvider(create: (_) => RideState()),
          ],
          child: MaterialApp(
            home: ErrorBoundary(
              child: Scaffold(
                body: Center(
                  child: OnlineToggle(
                    switchValue: false,
                    isDataLoaded: true,
                    onToggle: () => toggleCalled = true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('OFF'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(toggleCalled, isTrue);
    });
  });
}
