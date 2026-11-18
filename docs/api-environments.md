# Flutter API environments

All API calls use `Config.baseUrl`; endpoint code is shared.
The test API is available at `https://ugo-api.icacorp.org/test-api` and
forwards to the separate Test backend process and `ugo_taxi_test` database.

Test build:

```bash
flutter build apk --dart-define=APP_ENV=test
```

Live build (the default):

```bash
flutter build appbundle --dart-define=APP_ENV=live
```

For a temporary custom endpoint, `API_BASE_URL` takes precedence:

```bash
flutter build apk --dart-define=API_BASE_URL=https://example.test
```
