import 'package:dio/dio.dart';

import '/app_state.dart';
import 'api_manager.dart';

/// Shared Dio for screens that call the API directly (ride overlay, scan-to-book).
///
/// Previously each call did `Dio()` with a hand-built Bearer header: once the
/// access token expired those calls just failed with 401 (no refresh), so accept /
/// arrive / OTP / ride polling stopped working mid-shift. This instance applies the
/// same policy as ApiManager via AuthSessionGuard:
///  - always sends the CURRENT access token;
///  - 401 → one shared refresh → one retry; server-rejected session → forced logout;
///  - network errors / 5xx / permission 403 → error returned, session kept.
Dio authDio() => _instance ??= _build();
Dio? _instance;

Dio _build() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final hasAuth =
            options.headers.keys.any((k) => k.toLowerCase() == 'authorization');
        final token = FFAppState().accessToken;
        if (hasAuth && token.isNotEmpty) {
          options.headers
              .removeWhere((k, _) => k.toLowerCase() == 'authorization');
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final res = err.response;
        final status = res?.statusCode ?? 0;
        final authHeader = err.requestOptions.headers.entries
            .firstWhere((e) => e.key.toLowerCase() == 'authorization',
                orElse: () => const MapEntry('', null))
            .value
            ?.toString();
        final requestToken = (authHeader != null &&
                authHeader.toLowerCase().startsWith('bearer '))
            ? authHeader.substring(7).trim()
            : null;
        if (res == null ||
            requestToken == null ||
            requestToken.isEmpty ||
            (status != 401 && status != 403)) {
          return handler.next(err);
        }
        final alreadyRetried = err.requestOptions.extra['authRetried'] == true;
        final retryToken = await ApiManager.handleAuthFailure(
          status: status,
          body: res.data,
          requestToken: requestToken,
          alreadyRetried: alreadyRetried,
        );
        if (retryToken == null) return handler.next(err);
        try {
          final opts = err.requestOptions;
          opts.headers.removeWhere((k, _) => k.toLowerCase() == 'authorization');
          opts.headers['Authorization'] = 'Bearer $retryToken';
          opts.extra['authRetried'] = true;
          final retried = await dio.fetch(opts);
          return handler.resolve(retried);
        } on DioException catch (e) {
          return handler.next(e);
        }
      },
    ),
  );
  return dio;
}
