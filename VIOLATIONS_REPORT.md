# Code Violations Report & Fixes

This document lists violations found in the codebase and their resolution status.

---

## ✅ FIXED

### 1. Hardcoded Google Maps API Key (Security)
**Location:** `android/app/src/main/AndroidManifest.xml`  
**Issue:** API key was hardcoded and committed to version control.  
**Fix:** Moved to `local.properties` (gitignored). Add `MAPS_API_KEY=your_key` to `android/local.properties`.  
**Remaining:** `web/index.html` still has the key for web builds. For production web deployment, use build-time environment variables or a secrets manager.

### 2. Package/Path Mismatch (Code Hygiene)
**Location:** `MainActivity.kt`, `FloatingBubbleService.java`  
**Issue:** Files were in wrong directories (`com/example/my_project/`, `com/ugocabs/drivers/`) but declared package `com.ugotaxi_rajkumar.driver`.  
**Fix:** Moved to correct paths: `com/ugotaxi_rajkumar/driver/`.

### 3. Missing iOS Background Location Description
**Location:** `ios/Runner/Info.plist`  
**Issue:** App uses `ACCESS_BACKGROUND_LOCATION` but iOS had no `NSLocationAlwaysAndWhenInUseUsageDescription`.  
**Fix:** Added usage descriptions for background location (driver tracking during active rides).

### 4. Debug Logging in Release
**Location:** `FloatingBubbleService.java`  
**Issue:** `Log.d()` calls could leak info in production.  
**Fix:** Wrapped debug logs in `BuildConfig.DEBUG`; added ProGuard rules to strip `Log.v`/`Log.d`/`Log.i` in release.

---

## ⚠️ ACTION REQUIRED (Play Console)

### 5. USE_FULL_SCREEN_INTENT Declaration
**Status:** Permission declared in manifest; app uses `fullScreenIntent: false` in notifications.  
**Action:** Either:
- **Option A:** Remove `USE_FULL_SCREEN_INTENT` from manifest if you don't plan to use full-screen ride alerts when the screen is off.
- **Option B:** Enable full-screen intent for ride requests and complete the [Play Console declaration](https://support.google.com/googleplay/android-developer/answer/13392821) (App content → Full-screen intent). Driver apps with ride requests qualify but require explicit declaration.

### 6. Foreground Service Declaration
**Status:** Using `dataSync` and `location` foreground service types.  
**Action:** In Play Console → App content → Foreground service types, declare:
- **dataSync:** “Sync ride request data when driver is online; floating bubble shows incoming rides.”
- **location:** “Continuous driver location during active ride for passenger tracking.”

### 7. Permissions Declaration
**Action:** In Data safety and Play policies, justify:
- `ACCESS_BACKGROUND_LOCATION` – Driver tracking during active ride
- `SYSTEM_ALERT_WINDOW` – Floating ride request bubble
- `USE_FULL_SCREEN_INTENT` – (If kept) Full-screen ride alert when screen off

---

## 📋 REMAINING / NOTES

### 8. requestLegacyExternalStorage (Deprecated)
**Location:** `AndroidManifest.xml`  
**Status:** Deprecated on Android 11+. Kept for compatibility with `minSdk 26`. Can be removed when dropping support for older devices.

### 9. Debug print() in Dart
**Location:** Various `lib/` files  
**Status:** Several `print()` calls remain. Consider using `debugPrint()` or a logging package with release-level filtering.

### 10. Web API Key
**Location:** `web/index.html`  
**Status:** Maps key is hardcoded. For production, use build-time replacement (e.g., `--dart-define`) or inject via CI.

---

## Setup After Fixes

1. **Android Maps:** Add to `android/local.properties`:
   ```
   MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
   ```

2. **Build:** Run `flutter build appbundle` (ensure `key.properties` exists for release signing).

3. **Play Console:** Complete foreground service and full-screen intent declarations before submission.
