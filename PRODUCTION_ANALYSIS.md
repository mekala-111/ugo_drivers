# UGO Driver App – Production Analysis Report

**Senior Flutter Engineer & Mobile Performance Specialist**  
**Date:** February 2025

---

## A) Repo & lib/ Map

### Main modules and screens

| Path | Purpose |
|------|---------|
| **`lib/main.dart`** | App entry, `MultiProvider` (FFAppState, RideState), go_router, FCM init, Crashlytics |
| **`lib/home/`** | Main driver home: map, ride overlay, online toggle, earnings |
| **`lib/home/ride_request_overlay.dart`** | Core ride flow: new request, accept, arrived, OTP, complete, cancel |
| **`lib/home/ride_request_model.dart`** | `RideRequest` model with JSON parsing |
| **`lib/controllers/home_controller.dart`** | Socket.IO, location tracking, online/offline, earnings, incentives |
| **`lib/providers/ride_provider.dart`** | `RideState` ChangeNotifier for current ride |
| **`lib/app_state.dart`** | Global `FFAppState`: auth, profile, documents, active ride, persisted |
| **`lib/auth/`** | Firebase Auth, phone/social login |
| **`lib/backend/api_requests/`** | REST API via `http`, typed calls (Login, UpdateDriver, CancelRide, CompleteRide, etc.) |
| **`lib/services/ride_notification_service.dart`** | FCM + local notifications for ride requests |
| **`lib/services/route_polyline_service.dart`** | Google Directions API polyline, caching |
| **`lib/services/floating_bubble_service.dart`** | Overlay bubble when app is backgrounded |
| **`lib/flutter_flow/`** | Nav, map, theme, util, place picker |
| **`lib/components/`** | NewRequestCard, ActiveRideCard, StartRideCard, CompleteRideOverlay, OTP, Review, Cancel sheet |
| **`lib/login/`**, **`lib/otpverification/`** | Login and OTP verification |
| **`lib/on_boarding/`** | KYC completion (license, Aadhaar, PAN, RC, etc.) |
| **`lib/wallet/`**, **`lib/withdraw/`** | Wallet and withdrawal |
| **`lib/history/`** | Ride history |

### State management

- **FFAppState** (ChangeNotifier): auth, profile, active ride ID, persisted via SharedPreferences
- **RideState** (Provider): `currentRide`, `status`, `hasActiveRide`
- **HomeController** (ChangeNotifier): socket, location, online status, earnings, incentives
- **Page models** (`*_model.dart`): per-screen local state via `FlutterFlowModel`

### Navigation

- **go_router** 12.1.3, named routes
- `context.goNamed()`, `context.pushNamed()`, `context.pushNamedAuth()`
- Splash → Login/Home/Onboarding based on auth and registration step

### Networking

- **HTTP**: `package:http` via `ApiManager`, `Config.baseUrl`
- **Dio**: used for ride APIs in `ride_request_overlay.dart` (accept, verify-otp, complete)
- **Auth**: JWT in `FFAppState().accessToken`, passed in `Authorization: Bearer` headers

### Realtime

- **Socket.IO** (`socket_io_client`): in `HomeController`, connects to `Config.baseUrl`
- Events: `driver_rides`, `ride_updated`, `ride_taken`, `ride_assigned`
- **Firebase Messaging**: ride request push when app in background
- **Flutter Local Notifications**: ride request notification UI

---

## B) Ride lifecycle correctness

### State machine (from code)

```
SEARCHING (rider searching) 
    → ACCEPTED (driver accepted, drive to pickup)
    → ARRIVED (driver at pickup, OTP shown)
    → STARTED / ONTRIP (ride in progress)
    → COMPLETED | CANCELLED | REJECTED
```

### Files

- `lib/models/ride_status.dart` – enum and `fromString`
- `lib/home/ride_request_overlay.dart` – flow and UI mapping
- `lib/providers/ride_provider.dart` – central ride state

### Ambiguities

1. **`started` vs `onTrip`**  
   Both map to `RideCompleteOverlay`. Backend may use either; `RideStatusX.fromString` supports `ontrip` and `on_trip`. No functional bug, but naming is unclear.

2. **`searching` in RideStatus enum**  
   Driver sees `searching` as “new request”; it’s rider-side. Semantics are correct.

3. **RideState vs FFAppState**  
   `RideState` and `FFAppState().activeRideId` are updated in parallel. `_passDataToOverlay` updates both. Risk of drift if updates are out of order. Recommend using a single source of truth (e.g. always derive from overlay/ride provider).

4. **RideRequest.otp**  
   `copyWith` accepts `otp` but `RideRequest` has no `otp` field. Backend sends OTP; UI uses `_otpControllers` in overlay. Dead parameter in `copyWith`.

### Missing / weak handling

- **Backend status mismatch**  
   If backend sends a status like `PICKUP_REACHED`, it will become `unknown`. Add mapping or log for unknown statuses.
- **`activeRideId` persistence**  
   Restored from SharedPreferences on startup. If ride was completed on another device, stale ID may remain until cleared by API/404.

### Suggested fixes

**1. Add `unknown` handling in overlay**

```dart
// lib/home/ride_request_overlay.dart - in handleNewRide
if (status == RideStatus.unknown) {
  if (kDebugMode) debugPrint('Unknown ride status from backend: ${rawData['ride_status']}');
  return;  // Don't add/update; avoid corrupting state
}
```

**2. Remove dead `otp` from `copyWith`**

```dart
// lib/home/ride_request_model.dart - remove otp from copyWith signature
RideRequest copyWith({
  // ... other params
  // String? otp,  // REMOVE - not stored in model
  String? vehicleType,
  int? vehicleTypeId,
}) {
```

**3. Clear active ride on 404**

```dart
// lib/home/ride_request_overlay.dart - _fetchRideFromBackend
} catch (e) {
  if (e is DioException && e.response?.statusCode == 404) {
    FFAppState().activeRideId = 0;
    Provider.of<RideState>(context, listen: false).clearRide();  // Add
  }
}
```

---

## C) Bug list (prioritized)

### 1. **removeRideById can call setState after dispose**

**Severity:** Major  
**File:** `lib/home/ride_request_overlay.dart`  
**Symbol:** `removeRideById`  

**Why:** `removeRideById` calls `setState` without checking `mounted`. It is used from `handleNewRide` (async) and `_ignoreRideRequest`. If the overlay is disposed while parsing or handling, setState will run on a disposed widget.

**Reproduce:** Accept ride, quickly navigate away (or dispose overlay), then receive socket event that triggers `removeRideById`.

**Fix:**

```dart
void removeRideById(int id) {
  if (!mounted) return;
  setState(() {
    _activeRequests.removeWhere((r) => r.id == id);
    _timers.remove(id);
    _waitTimers.remove(id);
    _showOtpOverlay.remove(id);
    if (_otpControllers.containsKey(id)) {
      for (var c in _otpControllers[id]!) {
        c.dispose();
      }
      _otpControllers.remove(id);
    }
  });
  // ...
}
```

**Test:** Unit test or widget test that disposes overlay before async completion and verifies no exception.

---

### 2. **Access token stored in SharedPreferences**

**Severity:** Major (security)  
**File:** `lib/app_state.dart`  

**Why:** JWT is written to SharedPreferences, which is not encrypted on Android. Rooted devices or backup extraction can expose it.

**Fix:** Store JWT in `SecureStorageService` (or `flutter_secure_storage`) instead of SharedPreferences. Keep SharedPreferences only for non-sensitive flags.

---

### 3. **Socket token may be stale after login refresh**

**Severity:** Major  
**File:** `lib/controllers/home_controller.dart`  

**Why:** `_initSocket` runs once with the token from `FFAppState().accessToken` at init. If the token is refreshed (e.g. after re-login), the socket still uses the old token.

**Fix:** Reconnect socket when token changes, or pass token dynamically if the socket client supports it. Alternatively, disconnect on logout and reconnect on login with the new token.

---

### 4. **RideState and overlay can drift**

**Severity:** Major  
**File:** `lib/home/home_widget.dart` – `_passDataToOverlay`  

**Why:** Flow is: `Provider.of<RideState>.updateRide()` → `_overlayKey.currentState!.handleNewRide()`. Overlay maintains `_activeRequests` separately. If `handleNewRide` fails or behaves differently, RideState and overlay can diverge.

**Fix:** Prefer one source of truth. Either: (a) Have overlay own ride data and RideState subscribe to it, or (b) Have RideState (or a shared ride repository) own ride data and overlay only render it.

---

### 5. **Polyline fetch uses jsonDecode on main thread**

**Severity:** Minor (performance)  
**File:** `lib/services/route_polyline_service.dart:52`  

**Why:** `jsonDecode(res.body)` runs on the calling isolate. Large Directions responses can cause frame drops.

**Fix:** Move decode to a compute isolate:

```dart
final data = await compute(_parseDirectionsJson, res.body);
```

---

### 6. **HomeController.goOffline does not check _disposed before _notify**

**Severity:** Minor  
**File:** `lib/controllers/home_controller.dart`  

**Why:** `goOffline` calls `_notify()` at the end. If the controller was disposed during the async calls, `notifyListeners` could run on a disposed ChangeNotifier. Most paths check `_disposed`, but `goOffline`’s success branch does not.

**Fix:** Add `if (_disposed) return;` before the final `_notify()` in `goOffline`.

---

### 7. **Duplicate socket implementation (dead code)**

**Severity:** Minor  
**File:** `lib/custom_code/services/socket_services.dart`  

**Why:** `SocketService` uses a hardcoded `ugotaxi.com` URL and is not used. `HomeController` uses `Config.baseUrl`. Dead code and wrong URL risk if ever used.

**Fix:** Delete `SocketService` or align it with `Config.baseUrl` and integrate if needed.

---

### 8. **_hideFloatingBubble is async but dispose does not await**

**Severity:** Minor  
**File:** `lib/home/home_widget.dart:443`  

**Why:** `_hideFloatingBubble()` is async; `dispose` does not await it. The bubble may still be stopping when the widget is gone. Usually safe but can cause platform-channel calls after disposal.

**Fix:** Make `dispose` synchronous and have `_hideFloatingBubble` schedule work without blocking, or use a flag to avoid platform calls after dispose.

---

## D) Performance & smoothness audit

### Top causes of jank

1. **Route polyline JSON decoding on main thread**  
   `route_polyline_service.dart` – move `jsonDecode` to `compute()`.  
   Impact: High | Effort: Low

2. **Map marker/polyline updates**  
   `updateMarkers`, `updatePolylines`, `updateCircles` replace full sets. No diffing; every update rebuilds markers. Consider diffing or batching.  
   Impact: Medium | Effort: Medium

3. **Location stream**  
   `distanceFilter: 10` is reasonable. `_handleLocationUpdate` has extra logic; consider debouncing `_notify()` when not on an active ride.  
   Impact: Low | Effort: Low

4. **ListenableBuilder on entire HomeController**  
   `HomeWidget` rebuilds on any controller change. Consider splitting listeners (e.g. earnings vs map vs ride).  
   Impact: Medium | Effort: Medium

5. **Heavy widgets in ride overlay**  
   `NewRequestCard`, `ActiveRideCard`, etc. Use `const` where possible and avoid unnecessary rebuilds.  
   Impact: Low | Effort: Low

6. **Polyline cache unbounded**  
   `_cache` in `RoutePolylineService` grows indefinitely. Add max size or TTL-based eviction.  
   Impact: Low | Effort: Low

7. **No image caching config**  
   `CachedNetworkImage` used without explicit cache config. Defaults are usually fine, but worth validating.  
   Impact: Low | Effort: Low

8. **Socket events trigger full overlay rebuild**  
   Each `driver_rides` / `ride_updated` causes `handleNewRide` and overlay rebuild. Consider batching or throttling.  
   Impact: Medium | Effort: Medium

9. **Ride polling every 2s**  
   `_pollSearchingRides` runs every 2s for all SEARCHING rides. Add exponential backoff or stop when none left.  
   Impact: Low | Effort: Low

10. **Map style and marker bitmap init**  
    `initializeMarkerBitmap` uses `ResizeImage` and async resolution. Ensure it does not block the first frame.  
    Impact: Low | Effort: Low

### Map-specific

- **Marker updates:** Full set replacement; no clustering.
- **Polyline:** Fetched per route; 30min cache; no incremental updates.
- **Camera:** No automatic camera animation to driver/ride; user-controlled.
- **Location:** 50m server threshold, 100m/2s UI notify; reasonable for driver tracking.

### Realtime

- **Socket:** `_socket.off()` before `_socket.on()` avoids duplicate listeners per init.
- **Reconnect:** Re-emits `watch_entity` on reconnect; no dedup of events.
- **Dispose:** `HomeController.dispose` disconnects socket and cancels location stream.

---

## E) UX improvements (rider + driver)

### Onboarding

**Path:** `lib/on_boarding/on_boarding_widget.dart`  
- Add step indicator (e.g. 1/5, 2/5).  
- Show “Why we need this” for document uploads.  
- Add skip/back where safe.

### Permissions

**Path:** `lib/controllers/home_controller.dart`, `lib/home/home_widget.dart`  
- Show a “Before you go online” screen explaining location, overlay, notifications.  
- If permission denied, show in-context CTA to open settings with a short explanation.

### Home map

**Path:** `lib/home/widgets/ride_map.dart`, `lib/home/widgets/map_container.dart`  
- Add “Center on my location” FAB.  
- Show ETA to pickup/drop when on a ride.  
- Subtle pulse on driver marker when waiting for action.

### Pickup / drop

**Path:** `lib/components/active_ride_card.dart`, `lib/components/start_ride_card.dart`  
- Make “Navigate” more prominent.  
- Show distance to pickup in accepted phase.  
- Show drop distance in trip phase.

### Fare breakdown

**Path:** `lib/components/review_screen.dart`, `lib/components/cash_payment_screen.dart`  
- Explicit fare breakdown (base + distance + time + promo).  
- Match backend structure for consistency.

### Confirmation / searching

**Path:** `lib/components/new_request_card.dart`  
- Clear “Accept” / “Decline” with feedback on tap.  
- Show “Finding rider…” or similar when appropriate.

### Driver assigned / arrival

**Path:** `lib/components/active_ride_card.dart`, `lib/components/start_ride_card.dart`  
- Clear “Arrived at pickup” state and OTP entry.  
- Voice/visual cue when OTP is correct.

### Trip in progress

**Path:** `lib/components/complete_ride_overlay.dart`  
- Progress indicator (e.g. to drop).  
- Prominent “Complete ride” action.

### Completion / ratings

**Path:** `lib/components/review_screen.dart`  
- Clear success state after payment/review.  
- Optional rating before closing (if backend supports).

### Support

**Path:** `lib/support/`, `lib/account_support/`  
- List FAQs before “Contact us”.  
- Show expected response time.

---

## F) Security & reliability

### Security

1. **Access token in SharedPreferences** – Move to secure storage (see Bug #2).
2. **Config defaults** – `Config.baseUrl` and `Config.googleMapsApiKey` have defaults. Ensure production builds use dart-define.
3. **No PII logging found** – `debugPrint` used for errors; no tokens or PII logged in hot paths.
4. **Razorpay** – Keys from dart-define; no hardcoded keys in code.

### Reliability

1. **setState after dispose** – Add mounted checks (see Bug #1).
2. **Socket after dispose** – `_disposed` is checked before callbacks; acceptable.
3. **Async without context check** – Several `BuildContext` usages after `await`; `use_build_context_synchronously` is ignored in analysis_options. Prefer `if (!context.mounted) return` after awaits.
4. **Crashlytics** – Used for Flutter and platform errors.

---

## G) Fix order plan

### 1-day hotfix list

1. Add `if (!mounted) return` to `removeRideById` (`ride_request_overlay.dart`).
2. Add `if (_disposed) return` before `_notify()` in `goOffline` (`home_controller.dart`).
3. Clear RideState when ride fetch returns 404 (`ride_request_overlay.dart`).
4. Add unknown status handling in `handleNewRide` (`ride_request_overlay.dart`).

### 1-week stabilization list

1. Move access token to secure storage (`app_state.dart`).
2. Add `mounted` checks after all awaits that use `context` in ride flow.
3. Fix socket token refresh (reconnect on token change or login).
4. Move `jsonDecode` in route polyline service to `compute()`.
5. Add polyline cache size limit and eviction.
6. Remove or fix dead `SocketService` in custom_code.

### 1-month refactor list

1. Consolidate ride state: single source of truth for ride (RideState or overlay).
2. Split HomeController listeners (earnings, map, ride) to reduce rebuilds.
3. Implement marker/polyline diffing for map updates.
4. Add UX improvements: step indicator, permission education, center-on-location FAB.
5. Add integration tests for ride flow (accept → arrived → OTP → complete).

---

## Questions for backend / product

1. Backend ride status values and transitions: full list and allowed transitions?
2. OTP generation: backend-only or client involved?
3. Expected FCM payload format for ride_request (fields, structure)?
4. Token refresh strategy: refresh token, sliding expiry, or re-login?
5. Polyline: use backend route or only client Directions API?
6. Rate limits for ride accept, status updates, and polling?
7. Idempotency for accept/complete in case of retries?
8. Ride lifecycle when app is killed: how to resync on next launch?
9. Analytics events for ride state changes?
10. Error response format and error codes for ride APIs?
