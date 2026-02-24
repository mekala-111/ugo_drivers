# Play Console Open Test – Readiness Report

**Date:** Feb 24, 2025  
**App:** UGO Driver (com.ugotaxi_rajkumar.driver)

---

## Executive Summary

| Status | Count |
|--------|-------|
| ✅ **Ready** | 10 areas |
| ⚠️ **Code fixes needed** | 2 items |
| 📋 **Play Console setup required** | 6 items |

**Bottom line:** The app is **not yet ready** for open testing. Fix 2 code violations first, then complete Play Console setup.

---

## ✅ What’s Already Good

1. **Maps API key** – Uses `${MAPS_API_KEY}` placeholder; key in `local.properties` (gitignored).
2. **Access token** – Stored in `SecureStorageService` (encrypted), not SharedPreferences.
3. **Account deletion** – In-app "Delete Account" + URL `https://ugotaxi.com/driver-delete-account.html`.
4. **Privacy policy** – In-app privacy policy and account deletion info.
5. **Location disclosure** – Implemented in `_startLocationTracking()` (but see violation #1).
6. **Background location notice** – Shown when upgrading from while-in-use to background.
7. **Target SDK 36** – Compliant with latest requirements.
8. **Floating bubble** – Disabled (`android:enabled="false"`); no SYSTEM_ALERT_WINDOW.
9. **Aadhaar/PAN** – In secure storage.
10. **Foreground service** – Uses `dataSync` for FloatingBubbleService (currently disabled).

---

## ⚠️ Code Violations – Must Fix Before Submission

### Violation 1: Location disclosure shown too late (User Data policy)

**Issue:** In `goOnline()`, `Geolocator.getCurrentPosition()` is called **before** any location disclosure. That can trigger the system permission dialog on first use without an in-app explanation.

**Where:** `lib/controllers/home_controller.dart` – `goOnline()` lines 239–247.

**Fix:** Show the location disclosure **before** any `Geolocator` call in `goOnline()`.

**Impact:** User Data policy – prominent disclosure must appear before requesting location.

---

### Violation 2: USE_FULL_SCREEN_INTENT declared but not used

**Issue:** `USE_FULL_SCREEN_INTENT` is in the manifest, but notifications use `fullScreenIntent: false` in `ride_notification_service.dart`. Declaring unused sensitive permissions can cause rejection.

**Where:** `android/app/src/main/AndroidManifest.xml` line 13.

**Fix:** Remove the `USE_FULL_SCREEN_INTENT` permission from the manifest.

---

## 📋 Play Console Setup – Complete Before Open Test

| # | Item | Action |
|---|------|--------|
| 1 | **Privacy policy URL** | Add a public URL (e.g. `https://ugotaxi.com/privacy-policy`) in Store listing → Privacy policy. |
| 2 | **Data safety form** | Declare: location (precise, background), personal info (name, phone, email), financial/earnings data, ride history. |
| 3 | **Account deletion** | In App content → App access, add `https://ugotaxi.com/driver-delete-account.html`. |
| 4 | **Foreground service** | In App content → Foreground service types, declare `dataSync`: “Sync ride request data when driver is online.” |
| 5 | **Permissions justification** | Justify ACCESS_BACKGROUND_LOCATION, CAMERA, POST_NOTIFICATIONS in App content. |
| 6 | **Demo account** | Provide working test credentials for reviewers (email + password or phone + OTP instructions). |

---

## Optional Improvements (Lower Priority)

| Item | Current | Recommendation |
|------|---------|----------------|
| **FOREGROUND_SERVICE_SPECIAL_USE** | Declared in manifest | Remove if no service uses `specialUse`. FloatingBubbleService uses `dataSync` only. |
| **local.properties** | Contains MAPS_API_KEY | Ensure `MAPS_API_KEY` is set in CI/build environment for release builds. |

---

## Fix Order

1. **Code fixes**
   - Add location disclosure at the start of `goOnline()`.
   - Remove `USE_FULL_SCREEN_INTENT` from the manifest.
2. **Play Console**
   - Complete Data safety, privacy policy URL, account deletion, foreground service, and demo account setup.
3. **Build & upload**
   - Run `flutter build appbundle`.
   - Upload the AAB to an internal or open test track.

---

## References

- [User Data Policy](https://support.google.com/googleplay/android-developer/answer/9888076)
- [Data Safety](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Account Deletion](https://support.google.com/googleplay/android-developer/answer/13327111)
- [Foreground Services](https://support.google.com/googleplay/android-developer/answer/13392821)
