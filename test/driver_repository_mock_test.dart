import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:ugo_driver/repositories/driver_repository.dart';

@GenerateMocks([DriverRepositoryInterface])
import 'driver_repository_mock_test.mocks.dart';

void main() {
  late MockDriverRepositoryInterface mockRepo;

  setUp(() {
    mockRepo = MockDriverRepositoryInterface();
  });

  group('DriverRepository with mockito', () {
    test('fetchDriverProfile can be stubbed and verified', () async {
      when(mockRepo.fetchDriverProfile(
        token: anyNamed('token'),
        driverId: anyNamed('driverId'),
      )).thenAnswer((_) async => throw UnimplementedError('mocked'));

      expect(
        () => mockRepo.fetchDriverProfile(token: 't', driverId: 1),
        throwsA(isA<UnimplementedError>()),
      );

      verify(mockRepo.fetchDriverProfile(
        token: 't',
        driverId: 1,
      )).called(1);
    });

    test('getTodayEarnings can be stubbed', () async {
      when(mockRepo.getTodayEarnings(
        token: anyNamed('token'),
        driverId: anyNamed('driverId'),
      )).thenAnswer((_) async => throw Exception('API error'));

      expect(
        () => mockRepo.getTodayEarnings(token: 't', driverId: 1),
        throwsException,
      );
    });
  });
}
