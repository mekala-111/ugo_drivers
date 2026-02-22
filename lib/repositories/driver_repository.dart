import '/backend/api_requests/api_calls.dart';

/// Abstract interface for driver API operations. Enables mockito-based tests.
abstract class DriverRepositoryInterface {
  Future<ApiCallResponse> fetchDriverProfile({
    required String token,
    required int driverId,
  });
  Future<ApiCallResponse> fetchPostQR({
    required String token,
    required int driverId,
  });
  Future<ApiCallResponse> updateDriver({
    required int id,
    required String token,
    required bool? isonline,
    double? latitude,
    double? longitude,
    String? fcmToken,
    Map<String, dynamic>? extraParams,
  });
  Future<ApiCallResponse> getActiveCities({required String token});
  Future<ApiCallResponse> setPreferredCity({
    required String token,
    required int cityId,
  });
  Future<ApiCallResponse> setOnlineStatus({
    required String token,
    required bool isOnline,
  });
  Future<ApiCallResponse> requestPreferredCityApproval({
    required String token,
    required int requestedCityId,
  });
  Future<ApiCallResponse> getVehicleTypes();
  Future<ApiCallResponse> getAllDrivers({String? token});
  Future<ApiCallResponse> getDriverIncentives({
    required String token,
    required int driverId,
  });
  Future<ApiCallResponse> getTodayEarnings({
    required String token,
    required int driverId,
    String period = 'daily',
  });
  Future<ApiCallResponse> getRideHistory({
    required String token,
    required int driverId,
  });
}

/// Repository layer for driver-related API calls.
/// Abstracts api_calls.dart for easier testing and separation of concerns.
class DriverRepository implements DriverRepositoryInterface {
  DriverRepository._();
  static final DriverRepository instance = DriverRepository._();

  @override
  Future<ApiCallResponse> fetchDriverProfile({
    required String token,
    required int driverId,
  }) =>
      DriverIdfetchCall.call(token: token, id: driverId);

  @override
  Future<ApiCallResponse> fetchPostQR({
    required String token,
    required int driverId,
  }) =>
      PostQRcodeCall.call(token: token, driverId: driverId);

  @override
  Future<ApiCallResponse> updateDriver({
    required int id,
    required String token,
    required bool? isonline,
    double? latitude,
    double? longitude,
    String? fcmToken,
    Map<String, dynamic>? extraParams,
  }) =>
      UpdateDriverCall.call(
        id: id,
        token: token,
        isonline: isonline,
        latitude: latitude,
        longitude: longitude,
        fcmToken: fcmToken,
      );

  @override
  Future<ApiCallResponse> getActiveCities({required String token}) =>
      GetCitiesCall.call(token: token, onlyActive: true);

  @override
  Future<ApiCallResponse> setPreferredCity({
    required String token,
    required int cityId,
  }) =>
      SetPreferredCityCall.call(token: token, cityId: cityId);

  @override
  Future<ApiCallResponse> setOnlineStatus({
    required String token,
    required bool isOnline,
  }) =>
      SetOnlineStatusCall.call(token: token, isOnline: isOnline);

  @override
  Future<ApiCallResponse> requestPreferredCityApproval({
    required String token,
    required int requestedCityId,
  }) =>
      RequestPreferredCityApprovalCall.call(
        token: token,
        requestedCityId: requestedCityId,
      );

  @override
  Future<ApiCallResponse> getVehicleTypes() => ChoosevehicleCall.call();

  @override
  Future<ApiCallResponse> getAllDrivers({String? token}) =>
      GetAllDriversCall.call(token: token);

  @override
  Future<ApiCallResponse> getDriverIncentives({
    required String token,
    required int driverId,
  }) =>
      GetDriverIncentivesCall.call(
        token: token,
        driverId: driverId,
      );

  @override
  Future<ApiCallResponse> getTodayEarnings({
    required String token,
    required int driverId,
    String period = 'daily',
  }) =>
      DriverEarningsCall.call(
        token: token,
        driverId: driverId,
        period: period,
      );

  @override
  Future<ApiCallResponse> getRideHistory({
    required String token,
    required int driverId,
  }) =>
      DriverRideHistoryCall.call(token: token, id: driverId);
}
