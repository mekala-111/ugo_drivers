import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ugo_driver/app_state.dart';
import 'package:ugo_driver/providers/ride_provider.dart';
import 'package:ugo_driver/constants/app_colors.dart';

void main() {
  group('UGO Driver App - Critical Widget Tests', () {
    testWidgets('App providers build without crashing', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: FFAppState()),
            ChangeNotifierProvider(create: (_) => RideState()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Center(child: Text('UGO Driver', style: TextStyle(color: AppColors.primary))),
            ),
          ),
        ),
      );
      expect(find.text('UGO Driver'), findsOneWidget);
    });

    test('AppColors constants are defined', () {
      expect(AppColors.primary, isNotNull);
      expect(AppColors.primary.value, 0xFFFF7B10);
      expect(AppColors.success, isNotNull);
      expect(AppColors.error, isNotNull);
    });

    test('RideState initial state', () {
      final state = RideState();
      expect(state.currentRide, isNull);
      expect(state.hasActiveRide, isFalse);
    });
  });
}
