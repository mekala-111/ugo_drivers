# Google Play Developer Program Policy – Ugo Taxi Driver Compliance Report

Based on the [Developer Program Policies](https://play.google.com/about/developer-content-policy/) and a review of the codebase.

---

## Executive summary

| Status | Count |
|--------|-------|
| Compliant | 12 |
| Needs action | 4 |
| Play Console setup required | 5 |

---

## Compliant policies

### 1. **Functionality and User Experience**
- App provides full ride-hailing driver functionality: login, map, ride requests, accept/complete, earnings, wallet, history.
- No crashes or broken flows identified in core logic (hotfixes applied for `removeRideById`, `goOffline`, 404 handling, unknown status).
- Not a limited-functionality or placeholder app.

### 2. **Target API level**
- `targetSdkVersion 36` in `android/app/build.gradle`.
- Meets “within one year of latest major Android release” requirement.

### 3. **Impersonation**
- No impersonation of Uber, Rapido, or other brands.
- App is branded as “Ugo Taxi Driver” / “UGO-DRIVER”.

### 4. **Financial services**
- App is a ride-hailing driver app, not a personal loan or lending app.
- Wallet/withdrawal is driver earnings payout, not consumer lending.
- No binary options, high-APR loans, or prohibited financial products.

### 5. **Account deletion**
- In-app: Account → “Delete Account” with confirmation dialog.
- Web: `https://ugotaxi.com/driver-delete-account.html`.
- Privacy policy refers to account deletion and data retention.
- Implemented in `lib/account_support/account_support_widget.dart`.

### 6. **Privacy policy**
- In-app privacy policy: `lib/privacy_policy_page/`, `lib/privacypolicy/`.
- Covers data retention, account deletion, and secure handling.
- **Action:** Ensure the same policy is hosted at a public URL and linked in Play Console.

### 7. **Permissions usage**
- Location: driver tracking and ride navigation (core use case).
- Camera: document capture for KYC.
- Notifications: ride requests.
- Foreground service: ride data sync when online.
- Permissions appear justified for ride-hailing use cases.

### 8. **Deceptive behavior**
- No misleading claims, hidden features, or unexpected behavior found.
- Store listing should reflect actual app behavior.

### 9. **Malware**
- No malicious or unwanted code identified.

### 10. **Spam**
- App is not spam; it has a clear, single purpose.

### 11. **Floating bubble**
- Bubble is disabled; `FloatingBubbleService` is `android:enabled="false"`.
- No `SYSTEM_ALERT_WINDOW` permission, reducing policy risk.

### 12. **Content rating**
- App is for drivers (typically 18+); not targeted at children.
- Category: Transportation, appropriate for general audience.

---

## Needs action (code or config)

### 1. **Hardcoded Google Maps API key** (critical)

**Policy:** Avoid exposing secrets and keys in source or binaries.

**Location:** `android/app/src/main/AndroidManifest.xml` line 81

**Issue:**
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="AIzaSyDO0iVw0vItsg45hIDHV3oAu8RB-zcra2Y"/>
```
API key is hardcoded and can be extracted from the APK.

**Fix:** Use `local.properties` (or a secure build config) and a manifest placeholder:

In `AndroidManifest.xml`:
```xml
<meta-data android:name="com.google.android.geo.API_KEY" android:value="${MAPS_API_KEY}"/>
```

In `build.gradle`, ensure:
```groovy
manifestPlaceholders += [MAPS_API_KEY: mapsApiKey ?: ""]
```

Add `MAPS_API_KEY=your_key` to `android/local.properties` (already gitignored).

Then remove the hardcoded key from the manifest.

---

### 2. **Prominent disclosure for location (User Data policy)**

**Policy:** In-app disclosure before collecting location (and before runtime permission), describing what data is collected and why.

**Current flow:**  
User taps “Go Online” → `Geolocator.requestPermission()` → system permission dialog.  
There is a dialog when permission is denied, but no explicit disclosure before the first permission request.

**Recommendation:**  
Show a short in-app disclosure immediately before requesting location, e.g.:

> “Ugo Taxi Driver collects your location to show you on the map, match you with nearby rides, and navigate to pickup and drop-off. Location is shared with the platform during active rides.”

Then trigger the system location permission request.  
Implement this in `goOnline()` in `home_controller.dart` (or equivalent) before calling `Geolocator.requestPermission()`.

---

### 3. **Access token in SharedPreferences**

**Policy:** Sensitive data should be handled securely.

**Location:** `lib/app_state.dart` – JWT stored in SharedPreferences.

**Risk:** On some devices, SharedPreferences may be less secure than encrypted storage.

**Recommendation:**  
Store JWT in `flutter_secure_storage` (or equivalent) instead of SharedPreferences.  
This is a hardening step; not always a direct policy violation, but reduces risk.

---

### 4. **USE_FULL_SCREEN_INTENT declaration**

**Location:** `AndroidManifest.xml` line 13

**Status:** Permission declared, but `fullScreenIntent: false` in notifications (`ride_notification_service.dart`).

**Recommendation:**  
- If full-screen intents are not used: remove `USE_FULL_SCREEN_INTENT` from the manifest.  
- If you intend to use them: keep the permission and complete the Full-screen intent declaration in Play Console (App content → Full-screen intent).

---

## Play Console setup required

These cannot be verified from code; they must be completed in Play Console.

| Item | Action |
|------|--------|
| **Data safety form** | Declare: location (precise, background), personal info (name, phone, email), financial/earnings data, app activity (ride history). |
| **Privacy policy URL** | Add a public URL to your privacy policy in the store listing. |
| **Account deletion URL** | Add `https://ugotaxi.com/driver-delete-account.html` (or your actual URL) in the designated account deletion field. |
| **Foreground service types** | Declare usage of `dataSync` (ride sync when online). |
| **Permissions justification** | In App content, justify each sensitive permission (e.g. location, camera, notifications). |
| **Demo account** | Provide working test credentials for app review. |

---

## Policy checklist summary

| Policy area | Status |
|-------------|--------|
| User Data (privacy, disclosure) | Needs location disclosure; otherwise generally compliant |
| Permissions | Compliant (used for stated purpose) |
| Target API level | Compliant |
| Functionality & UX | Compliant |
| Financial services | Compliant (not a loan app) |
| Account deletion | Compliant |
| Privacy policy | Compliant (link in Play Console required) |
| Impersonation | Compliant |
| Deceptive behavior | Compliant |
| Malware / Spam | Compliant |
| API keys / secrets | Needs fix (remove hardcoded Maps key) |

---

## Recommended order of actions

1. Fix hardcoded Maps API key (use manifest placeholder and `local.properties`).
2. Add prominent in-app disclosure before first location permission request.
3. Complete Data safety, privacy policy URL, account deletion URL, and foreground service declarations in Play Console.
4. (Optional) Move access token to secure storage.
5. Resolve `USE_FULL_SCREEN_INTENT` (either remove or declare in Play Console).

---

## References

- [Developer Program Policies](https://play.google.com/about/developer-content-policy/)
- [User Data Policy](https://support.google.com/googleplay/android-developer/answer/9888076)
- [Permissions Policy](https://support.google.com/googleplay/android-developer/answer/12579724)
- [Account Deletion](https://support.google.com/googleplay/android-developer/answer/13327111)
- [Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)
