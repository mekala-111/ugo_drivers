import 'dart:convert';

import '/app_state.dart';
import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_manager.dart';
import '/config.dart';

class AuthSessionManager {
  AuthSessionManager._();
  static final AuthSessionManager instance = AuthSessionManager._();

  Future<bool> login({
    required int mobile,
    required String fcmToken,
  }) async {
    final res = await LoginCall.call(
      mobile: mobile,
      fcmToken: fcmToken,
    );
    if (!res.succeeded) return false;
    final access = LoginCall.accessToken(res.jsonBody) ?? '';
    final refresh = LoginCall.refreshToken(res.jsonBody) ?? '';
    if (access.isEmpty || refresh.isEmpty) return false;
    await storeTokensSecurely(
      accessToken: access,
      refreshToken: refresh,
    );
    return true;
  }

  Future<void> logout() async {
    final token = FFAppState().accessToken;
    if (token.isNotEmpty) {
      await DriverLogoutCall.call(token: token);
    }
    await FFAppState().clearAppState();
  }

  Future<bool> refreshToken() async {
    final appState = FFAppState();
    if (appState.refreshToken.isEmpty) return false;
    final res = await ApiManager.instance.makeApiCall(
      callName: 'authRefresh',
      apiUrl: '${Config.baseUrl}/api/auth/refresh',
      callType: ApiCallType.POST,
      headers: {
        'Content-Type': 'application/json',
      },
      params: {},
      body: jsonEncode({
        'refreshToken': appState.refreshToken,
      }),
      bodyType: BodyType.JSON,
      returnBody: true,
      cache: false,
      alwaysAllowBody: true,
    );
    if (!res.succeeded) return false;
    final access = LoginCall.accessToken(res.jsonBody) ??
        (res.jsonBody is Map ? res.jsonBody['accessToken']?.toString() : null) ??
        '';
    final refresh = LoginCall.refreshToken(res.jsonBody) ??
        (res.jsonBody is Map ? res.jsonBody['refreshToken']?.toString() : null) ??
        '';
    if (access.isEmpty) return false;
    appState.accessToken = access;
    if (refresh.isNotEmpty) appState.refreshToken = refresh;
    return true;
  }

  Future<bool> restoreSession() async {
    final appState = FFAppState();
    if (appState.accessToken.isNotEmpty && appState.driverid > 0) return true;
    if (appState.refreshToken.isEmpty) return false;
    return refreshToken();
  }

  Future<ApiCallResponse> handle401AndRetry(
    Future<ApiCallResponse> Function() request,
  ) async {
    final first = await request();
    if (first.statusCode != 401) return first;
    final refreshed = await refreshToken();
    if (!refreshed) return first;
    return request();
  }

  Future<void> handleForcedLogout() async {
    await FFAppState().clearAppState();
  }

  Future<void> storeTokensSecurely({
    required String accessToken,
    required String refreshToken,
  }) async {
    final appState = FFAppState();
    appState.accessToken = accessToken;
    appState.refreshToken = refreshToken;
  }
}
