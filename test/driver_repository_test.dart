import 'package:flutter_test/flutter_test.dart';

import 'package:ugo_driver/repositories/driver_repository.dart';

void main() {
  group('DriverRepository', () {
    test('instance is singleton', () {
      final a = DriverRepository.instance;
      final b = DriverRepository.instance;
      expect(identical(a, b), isTrue);
    });

    test('fetchDriverProfile returns Future', () {
      final future = DriverRepository.instance.fetchDriverProfile(
        token: 'test-token',
        driverId: 1,
      );
      expect(future, isA<Future>());
    });

    test('getTodayEarnings returns Future', () {
      final future = DriverRepository.instance.getTodayEarnings(
        token: 'test-token',
        driverId: 1,
      );
      expect(future, isA<Future>());
    });

    test('getRideHistory returns Future', () {
      final future = DriverRepository.instance.getRideHistory(
        token: 'test-token',
        driverId: 1,
      );
      expect(future, isA<Future>());
    });
  });
}
