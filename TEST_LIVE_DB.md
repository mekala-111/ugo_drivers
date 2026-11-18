# Test / Live database switch

The app selects an API URL at build time; the backend then selects its database. Do not put MySQL credentials in the app.

- Live (default): `https://ugo-api.icacorp.org` → Live DB.
- Test: `https://ugo-api.icacorp.org/test-api` → `ugo_taxi_test`.

From this project directory:

```sh
flutter build apk --dart-define=APP_ENV=test
flutter build appbundle --dart-define=APP_ENV=live
```

`API_BASE_URL` can override either URL for a custom build. Existing Play Store installs keep their compiled Live URL. The central setting is `lib/config.dart`; the Test socket path is selected there too.
