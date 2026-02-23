# Google Play Console Submission Guide

This guide helps you publish the UGO Driver app to Google Play, following practices similar to Uber Partner and other ride-sharing driver apps.

---

## Prerequisites

### 1. Google Play Developer Account
- Enroll at [Google Play Console](https://play.google.com/console) ($25 one-time fee)
- Complete identity verification (individual or organization)
- For driver/transport apps, some regions may require additional verification

### 2. App Signing Key (Upload Key)

**Create a keystore** (do this once, store safely):
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Create `android/key.properties`** (add to .gitignore - already configured):
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

> ⚠️ **Critical**: Back up your keystore and passwords. Loss means you cannot update your app on Play Store.

### 3. Google Maps API Key (Required for Android)

Add your Maps API key to `android/local.properties` (this file is gitignored):
```properties
MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
```

Get a key from [Google Cloud Console](https://console.cloud.google.com/apis/credentials). Restrict it to your app's package name and API (Maps SDK for Android) for security.

---

## Build the App Bundle (AAB)

Play Store requires **Android App Bundle (AAB)**, not APK:

```bash
flutter clean
flutter pub get
flutter build appbundle
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Play Console Setup Checklist

### App Dashboard
- [ ] Create new app in Play Console
- [ ] Set up **Play App Signing** (mandatory – Google will re-sign your app)
- [ ] Upload your **upload key** when prompted (or let Google generate one)

### Store Listing
- [ ] **App name**: UGO Driver (or your production name)
- [ ] **Short description** (80 chars max)
- [ ] **Full description** (4000 chars max)
- [ ] **App icon**: 512×512 PNG
- [ ] **Feature graphic**: 1024×500 PNG
- [ ] **Screenshots**: At least 2 phone screenshots

### Content Rating
- [ ] Complete questionnaire (likely PEGI 3 / Everyone for driver app)
- [ ] Submit for rating

### Target Audience
- [ ] Select age groups
- [ ] Declare if app targets children (No for driver app)

### Privacy & Security
- [ ] **Privacy Policy URL** (required – host a valid URL)
- [ ] **Data Safety form** – Declare:
  - Location (precise, approximate) – for ride pickup/delivery
  - Personal info (name, phone, email) – for driver account
  - App activity (ride history, earnings) – if applicable
- [ ] **Permissions declaration** – Explain:
  - `ACCESS_FINE_LOCATION` / `ACCESS_BACKGROUND_LOCATION` – Driver tracking, ride navigation
  - `CAMERA` – Document/ID capture
  - `POST_NOTIFICATIONS` – Ride requests, alerts
  - `SYSTEM_ALERT_WINDOW` – Floating ride request bubble
  - `USE_FULL_SCREEN_INTENT` – Full-screen ride request notification

### App Access
- [ ] Provide **demo account** credentials for reviewers (email + password)
- [ ] Add instructions if login flow is complex

### Ads (if applicable)
- [ ] Declare if app contains ads (likely No for driver app)

---

## Uber Partner-Style Permissions Justification

| Permission | Use Case |
|------------|----------|
| `ACCESS_FINE_LOCATION` | Show driver location to passengers, navigate to pickup/drop |
| `ACCESS_BACKGROUND_LOCATION` | Continue tracking when app is in background during active ride |
| `CAMERA` | Scan documents, capture ID/vehicle photos |
| `POST_NOTIFICATIONS` | New ride requests, earnings updates |
| `USE_FULL_SCREEN_INTENT` | Full-screen ride request alert when screen is off |
| `SYSTEM_ALERT_WINDOW` | Floating bubble for ride requests while using other apps |
| `FOREGROUND_SERVICE` | Keep ride request listener active |
| `FOREGROUND_SERVICE_DATA_SYNC` | Sync ride data in foreground service |
| `FOREGROUND_SERVICE_LOCATION` | Continuous location during active ride |

---

## Version Management

Update in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # 1.0.0 = versionName, 1 = versionCode
```

- **versionName**: User-visible (e.g., 1.0.0)
- **versionCode**: Must increase with each Play Store upload (e.g., 1, 2, 3…)

---

## Testing Before Submission

1. **Internal testing**: Add testers in Play Console
2. **Internal app sharing**: Quick test without full review
3. **Release to production**: Full review (can take 1–3 days)

---

## Common Rejection Reasons & Fixes

| Issue | Fix |
|-------|-----|
| **Declared permissions not used** | Remove unused permissions from AndroidManifest |
| **Missing privacy policy** | Add valid URL in Store listing |
| **Crash on launch** | Test release build: `flutter build appbundle` then install via `bundletool` |
| **Data Safety incomplete** | Accurately declare all data collection |
| **Foreground service policy** | Ensure service types match usage (dataSync for ride sync, location for tracking) |
| **Demo account doesn't work** | Ensure test account is active and credentials are correct |

---

## Build for Production

```bash
# Ensure key.properties exists and is correct
flutter build appbundle --release
```

Upload `build/app/outputs/bundle/release/app-release.aab` in Play Console → Production → Create new release.

---

## Security Notes

- **Do not** commit `key.properties` or `.jks` files
- Consider moving **Google Maps API key** to build config or backend for production
- Use **Play App Signing** – Google manages the app signing key for you
- Rotate API keys if ever exposed
