# Ugo Drivers – Production Audit Report

**Date:** 2026-02-23  
**Scope:** Flutter `lib/`, `pubspec.yaml`, `android/`, `ios/` (as needed)  
**Focus:** Bugs, ride lifecycle, performance, UX, security, fix order  

---

## A) Repo & lib/ Map

### Main Modules & Screens

| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry, Crashlytics, Wakelock, MultiProvider (FFAppState, RideState) |
| `lib/flutter_flow/nav/nav.dart` | GoRouter, 50+ routes, auth redirect |
| `lib/home/home_widget.dart` | **Home** – map, online toggle, ride overlay, incentive/earnings panels |
| `lib/home/ride_request_overlay.dart` | **Ride flow** – new request card, pickup/arrived/onTrip/complete UI |
| `lib/home/ride_request_model.dart` | `RideRequest` model, `fromJson` |
| `lib/home/home_model.dart` | HomeModel (GoogleMap controller, API responses) |
| `lib/controllers/home_controller.dart` | **Core logic** – socket, location, online/offline, incentives, earnings |
| `lib/providers/ride_provider.dart` | `RideState` – central ride state (ChangeNotifier) |
| `lib/models/ride_status.dart` | `RideStatus` enum + `RideStatusX.fromString` |
| `lib/backend/api_requests/api_manager.dart` | HTTP client, auth, 401 → logout |
| `lib/backend/api_requests/api_calls.dart` | Ride/Driver/Wallet/Bank/Incentive API calls |
| `lib/repositories/driver_repository.dart` | Driver profile, online status, incentives, earnings |
| `lib/services/ride_notification_service.dart` | FCM + local notifications for ride requests |
| `lib/services/route_polyline_service.dart` | Google Directions polyline fetch + cache |
| `lib/services/floating_bubble_service.dart` | Android overlay for ride requests in background |
| `lib/custom_code/services/socket_services.dart` | **Unused** – legacy Socket.IO (hardcoded ugotaxi.com) |
| `lib/auth/` | Firebase + JWT auth |
| `lib/login/`, `lib/otpverification/` | Auth flow |
| `lib/wallet/`, `lib/Payments/` | Wallet, bank, withdraw |
| `lib/history/history_widget.dart` | Ride history |
| `lib/ride_overview/` | Ride detail/report |
| `lib/account_support/`, `lib/account_management/` | Profile, documents, cities |
| `lib/driving_dl/`, `lib/adhar_upload/`, `lib/panupload_screen/` | KYC flows |
| `lib/on_boarding/`, `lib/choose_vehicle/` | Registration |

### State Management
- **Provider**: `FFAppState` (global), `RideState` (ride state)
- **ChangeNotifier**: `HomeController` (listened via `ListenableBuilder`)

### Navigation
- **GoRouter** – imperative APIs, auth refresh, deep links

### Networking
- **Dio** – ride accept/status/verify-otp/complete/cancel (ride_request_overlay)
- **ApiManager (http)** – driver profile, wallet, incentives, bank, etc.
- **Config.baseUrl** – `https://ugo-api.icacorp.org` (default)

### Realtime
- **Socket.IO** – in `HomeController` only (`Config.baseUrl`), events: `driver_rides`, `ride_updated`, `ride_taken`, `ride_assigned`
- **SocketService** (custom_code) – **not used**; HomeController creates its own socket

---

## B) Ride Lifecycle Correctness

### Derived State Machine

| State | Enum | Backend String | Transitions |
|-------|------|----------------|-------------|
| Searching | `searching` | SEARCHING | → accepted, cancelled, rejected |
| Accepted | `accepted` | ACCEPTED | → arrived |
| Arrived | `arrived` | ARRIVED | → started (via OTP) |
| Started | `started` | STARTED | → onTrip (often merged) |
| OnTrip | `onTrip` | ONTRIP | → completed |
| Completed | `completed` | COMPLETED | terminal |
| Cancelled | `cancelled` | CANCELLED | terminal |
| Rejected | `rejected` | REJECTED | terminal |
| Unknown | `unknown` | UNKNOWN | fallback |

### Issues

1. **`searching` vs “Requested”** – Enum has `searching`; typical rider flow is Requested → Searching. For the driver app this is acceptable (driver sees “searching” when request is broadcast).
2. **`started` vs `onTrip`** – Both used; backend may send either. UI treats them identically (line 511–528 in ride_request_overlay). No inconsistency.
3. **`DECLINED` not in enum** – `home_widget.dart` line 273 checks `DECLINED` but `RideStatusX.fromString` has no `declined`. Add to parser:

```dart
// lib/models/ride_status.dart - add to fromString
case 'declined':
  return RideStatus.rejected;
```

4. **`RideState` not cleared on `removeRideById`** – When ride is cancelled/rejected/taken-by-other, `_passDataToOverlay` clears map and calls `removeRideById`, but `Provider.of<RideState>(context).clearRide()` is only called from `_cancelRide` and `onDone` (completion). For CANCELLED/REJECTED from socket, `RideState` should be cleared.

**Fix (home_widget.dart `_passDataToOverlay`):**

```dart
if (status == 'CANCELLED' || status == 'REJECTED' || status == 'DECLINED') {
  _controller.setRideStatus('IDLE');
  Provider.of<RideState>(context, listen: false).clearRide();  // ADD
  // ... rest
}
```

5. **`Provider.of<RideState>` without `listen: false` in build** – Line 284: `Provider.of<RideState>(context, listen: false)` is correct in callback. No change.

6. **`FETCHING`** – Used in `shouldShowPanels` and `_fetchInitialRideStatus` but not in `RideStatus` enum. This is controller-only state; OK.

---

## C) Bug List (Prioritized)

### BLOCKER

#### B1. Accept Ride API URL Typo
**File:** `lib/home/ride_request_overlay.dart`  
**Symbol:** `_acceptRide`  
**Why:** URL `api/rides/rides/$rideId/accept` has redundant `rides`. Backend may expect `api/rides/$rideId/accept`.  
**Reproduce:** Accept a ride; if 404, URL is wrong.  
**Fix:** Align with backend. If backend uses `/api/rides/$rideId/accept`:
```dart
'${Config.baseUrl}/api/rides/$rideId/accept',
```
**Verify:** Accept ride → 200, ride status ACCEPTED.

---

### CRITICAL

#### C1. setState After Dispose in RideRequestOverlay
**File:** `lib/home/ride_request_overlay.dart`  
**Symbol:** `_updateLocalRideStatus`, `_startTickTimer`  
**Why:** `_updateLocalRideStatus` calls `setState` without `mounted` check. Timer and async callbacks can fire after dispose.  
**Reproduce:** Accept ride, quickly navigate away; or receive socket update after overlay disposed.  
**Fix:**
```dart
void _updateLocalRideStatus(int rideId, RideStatus status, {...}) {
  if (!mounted) return;
  setState(() { ... });
}
```
And in `_startTickTimer`:
```dart
_tickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  if (!mounted) return;
  setState(() { ... });
});
```
**Verify:** No “setState() called after dispose” in logs.

#### C2. RideState Not Cleared on Socket CANCELLED/REJECTED
**File:** `lib/home/home_widget.dart`  
**Symbol:** `_passDataToOverlay`  
**Why:** When ride is cancelled/rejected via socket, `RideState` keeps stale ride.  
**Reproduce:** Ride cancelled by rider → driver still sees old ride state.  
**Fix:** See B.4 above – add `Provider.of<RideState>(context, listen: false).clearRide()`.

#### C3. ApiManager Logs Full Response Body (PII Leak)
**File:** `lib/backend/api_requests/api_manager.dart` line 573  
**Why:** `print(... body: ${result.bodyText} ...)` logs full response; may include tokens, PII.  
**Reproduce:** Any API call in debug.  
**Fix:**
```dart
// Remove or wrap in kDebugMode and truncate:
if (kDebugMode) {
  debugPrint('API [$callName] → ${result.statusCode}');
}
```
**Verify:** No full body in release logs.

---

### MAJOR

#### M1. UpdateDriverCall Logs Token
**File:** `lib/backend/api_requests/api_calls.dart` lines 636–639  
**Why:** `print('Token: ${token?.substring(0, 20)}...')` logs token prefix.  
**Fix:** Remove or use `debugPrint` + `kDebugMode` only.

#### M2. _searchingPollTimer Uses Wrong Variable
**File:** `lib/home/ride_request_overlay.dart`  
**Symbol:** `_startSearchingPoll`  
**Why:** Uses `_searchingPollTimer` but declares `_searchingPollTimer` (typo in one place – verify). Actually both are `_searchingPollTimer`. No bug; ignore.

#### M3. FlutterFlowGoogleMap setState Without mounted Check
**File:** `lib/flutter_flow/flutter_flow_google_map.dart`  
**Symbol:** `updateMarkers`, `updateCircles`, `updatePolylines`  
**Why:** These call `setState`; if map is disposed during async polyline fetch, crash.  
**Fix:** In state class, guard: `if (!mounted) return;` before `setState`.

#### M4. RideRequestOverlay handleNewRide setState in Async
**File:** `lib/home/ride_request_overlay.dart`  
**Symbol:** `handleNewRide`  
**Why:** After `await` or in callbacks, `setState` without `mounted`.  
**Fix:** Add `if (!mounted) return;` before each `setState` in async paths.

---

### MINOR

#### N1. DECLINED Not Parsed in RideStatus
**File:** `lib/models/ride_status.dart`  
**Fix:** Add `case 'declined': return RideStatus.rejected;`

#### N2. SocketService Dead Code with Hardcoded URL
**File:** `lib/custom_code/services/socket_services.dart`  
**Why:** Hardcoded `https://ugotaxi.com`, never used.  
**Fix:** Delete or refactor to use Config.baseUrl if ever reused.

---

## D) Performance & Smoothness Audit

### Top 10 Improvements

| # | Issue | Impact | Effort | Fix |
|---|-------|--------|--------|-----|
| 1 | **Polyline fetch on main thread** | High | Low | `RoutePolylineService.getRoutePoints` is async; decoding is in isolate. Already OK. But `jsonDecode` in route_polyline_service is synchronous – consider `compute()` for large responses. |
| 2 | **Location stream 10m distanceFilter** | Medium | Low | `Geolocator.getPositionStream(distanceFilter: 10)` – reasonable. Could increase to 20–30m when not on ride to save battery. |
| 3 | **HomeController notifyListeners on every location update** | High | Medium | `_handleLocationUpdate` calls `_notify()` on every 50m update. Throttle to e.g. 2s or 100m when no active ride. |
| 4 | **Map marker/polyline updates** | Medium | Low | `updateMarkers`/`updatePolylines` rebuild map. Batch updates; avoid calling on every tiny state change. |
| 5 | **Missing const** | Low | Low | Add `const` to widgets in ride cards, panels where possible. |
| 6 | **ListenableBuilder on entire Home build** | Medium | Low | Home uses `ListenableBuilder(listenable: _controller)`. Consider `Selector` or `Consumer` to limit rebuilds. |
| 7 | **IncentivePanel / EarningsSummary rebuild** | Low | Low | Extract to separate widgets with `const` where possible. |
| 8 | **Socket event handlers not debounced** | Medium | Low | Rapid `driver_rides` events could cause many rebuilds. Debounce 100–200ms. |
| 9 | **RoutePolylineService cache unbounded** | Low | Low | `_cache` grows indefinitely. Add max size or TTL eviction. |
| 10 | **Heavy JSON parsing in DriverRepository** | Medium | Medium | `getJsonField` on large responses. Consider parsing in isolate for history/earnings. |

### Map-Specific
- **Marker updates:** Done via `_mapKey.currentState?.updateMarkers`. Single batch per ride event – OK.
- **Polyline:** Fetched async, applied when ready. Good.
- **Location throttling:** 50m threshold + 10m stream – reasonable.
- **Background:** Wakelock enabled; location continues. Ensure Android battery optimization handled.

### Realtime
- **Socket:** One instance in HomeController; `_socket.off` before `on` prevents duplicate listeners for `driver_rides`, `ride_updated`, `ride_taken`, `ride_assigned`.
- **Stream cancellation:** `_locationSub?.cancel()` in `_stopLocationTracking` on dispose – OK.
- **Reconnection:** `setReconnectionAttempts(5)`, `onReconnect` re-emits `watch_entity` – OK.

---

## E) UX Improvements

| Area | Current | Suggestion | File |
|------|---------|------------|------|
| **Onboarding** | Multi-step KYC | Add progress indicator, “3 of 5 steps” | on_boarding, driving_dl, adhar, etc. |
| **Permissions** | Dialog on go-online fail | Explain before toggle: “Location needed to receive rides” | home_controller, app_header |
| **Home map** | Map + captains count | Add “Tap to center on me” | map_container, flutter_flow_google_map |
| **Ride request** | NewRequestCard, 30s timer | Add fare breakdown, distance to pickup | new_request_card |
| **Confirmation** | Accept/Decline | Haptic on tap, loading state on Accept | ride_request_overlay |
| **Searching** | Poll every 2s | Show “Searching for driver…” if applicable (rider-side). N/A for driver. |
| **Driver assigned** | RidePickupOverlay | Show “Navigate to pickup” button | RidePickupOverlay, active_ride_card |
| **Arrival** | RideBottomOverlay, OTP | Clear “I’ve arrived” CTA, OTP layout | start_ride_card, otp_screen |
| **Trip in progress** | RideCompleteOverlay | ETA to drop, trip timer | RideCompleteOverlay |
| **Completion** | CashPaymentScreen / ReviewScreen | Fare breakdown, tip prompt | cash_payment_screen, review_screen |
| **Ratings** | ReviewScreen | Star rating UI if backend supports | review_screen |
| **Support** | Multiple screens | Single “Help” entry, contextual by ride state | support, support_ride |

---

## F) Security & Reliability

### Security

| Item | Status | Action |
|------|--------|--------|
| Hardcoded keys | Config uses `String.fromEnvironment`; Maps in local.properties | Ensure CI sets env vars |
| Token storage | `SharedPreferences` for access token | Prefer `flutter_secure_storage` for tokens |
| Aadhaar/PAN | `SecureStorageService` | OK |
| Logging tokens | `api_manager.dart`, `api_calls.dart` print tokens/body | Remove or gate with kDebugMode |
| PII in logs | Many `print()` with user data | Replace with `debugPrint` + `kDebugMode` |

### Crash-Prone Patterns

1. **`result.response!.body`** – ApiManager line 573: `result.response` can be null for streamed/error responses. Use `result.response?.body`.
2. **`unwrap(data)` returning null** – home_widget `process` is invoked only when `m != null`; OK.
3. **`int.tryParse` on rideId** – Used safely with null checks.

---

## G) Fix Order Plan

### 1-Day Hotfix
1. **B1** – Fix accept ride URL (confirm with backend first).
2. **C1** – Add `mounted` checks in RideRequestOverlay.
3. **C2** – Clear RideState on socket CANCELLED/REJECTED.
4. **C3** – Remove/truncate API body logging.
5. **N1** – Add DECLINED to RideStatus parser.

### 1-Week Stabilization
1. **M1** – Remove token logging from UpdateDriverCall.
2. **M3** – Add `mounted` check in FlutterFlowGoogleMap.
3. **M4** – Add `mounted` checks in handleNewRide async paths.
4. Throttle HomeController `_notify()` on location (e.g. 2s).
5. Gate all `print()` with `kDebugMode` or replace with `debugPrint`.

### 1-Month Refactor
1. Move access token to `flutter_secure_storage`.
2. Refactor Home build with `Selector`/`Consumer` to reduce rebuilds.
3. Add `compute()` for heavy JSON parsing.
4. Route polyline cache eviction (max size / TTL).
5. Remove or refactor dead `SocketService`.

---

## Targeted Questions (If Backend Unknown)

1. Accept ride: `/api/rides/$rideId/accept` or `/api/rides/rides/$rideId/accept`?
2. Verify OTP: `/api/rides/verify-otp` – request body `{otp, ride_id}`?
3. Update ride status: `PUT /api/rides/$rideId` with `{ride_status, driver_id}`?
4. Complete ride: `POST /api/drivers/complete-ride` – exact payload?
5. Cancel ride: `PATCH /api/rides/rides/cancel` – exact payload?
6. Socket events: Does backend emit `ride_taken`/`ride_assigned` when another driver accepts?
7. Ride status strings: Uppercase (ACCEPTED) or lowercase (accepted)?
8. `DECLINED` vs `REJECTED`: Same meaning for driver declining?
9. FCM payload: `type: ride_request`, `ride_id`?
10. Preferred city: Required before go-online? (Code already enforces.)

---

*End of Report*
