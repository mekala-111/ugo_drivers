# Android driver floating bubble & foreground service

## Architecture

| Layer | Responsibility |
|--------|----------------|
| **Flutter** | Source of truth for ONLINE/OFFLINE (`FFAppState.isonline` → `SharedPreferences` key `ff_isonline`). Calls MethodChannel when lifecycle or online state changes. |
| **CaptainBubbleService** | Foreground service + `TYPE_APPLICATION_OVERLAY` bubble + optional full-screen ride request UI. |
| **MainActivity** | MethodChannel host, overlay settings intent, `onUserLeaveHint` safety net. |
| **DriverOnlineBootReceiver** | After `BOOT_COMPLETED`, restarts the service if prefs still say ONLINE and overlay is allowed. |

## MethodChannel (`com.ugotaxi_rajkumar.driver/floating_bubble`)

| Method | Purpose |
|--------|---------|
| `startFloatingBubble` `{ overlaySuppressedInitially }` | Starts FGS. If overlay suppressed, only the notification runs (driver inside app). |
| `setBubbleOverlaySuppressed` `{ suppressed }` | Shows or hides the small bubble while keeping the FGS. |
| `stopFloatingBubble` | Stops service, clears bubble (driver OFFLINE / logout). |
| `updateBubbleBadge` `{ count }` | Optional red dot on bubble. |
| `isBubbleServiceRunning` | Returns whether the service process is up. |
| `checkOverlayPermission` / `requestOverlayPermission` | `SYSTEM_ALERT_WINDOW`. |

Dart helpers live in `lib/services/floating_bubble_service.dart`.

## Lifecycle (intended flow)

1. **Driver goes ONLINE** (API success + `FFAppState.isonline = true`) → `HomeWidget` runs `_syncFloatingBubble` → starts FGS with `overlaySuppressedInitially: true` if the app is in foreground → bubble hidden, persistent notification visible.
2. **App backgrounds** (`paused` / `inactive`) → `setBubbleOverlaySuppressed(false)` → overlay bubble appears over other apps.
3. **Task removed from Recents** → `CaptainBubbleService.onTaskRemoved` re-`startForegroundService` if `DriverOnlinePrefs.isDriverOnline` and overlay allowed. **Not guaranteed** on aggressive OEMs; entire process may still die.
4. **Reboot** → `DriverOnlineBootReceiver` tries the same (best-effort).
5. **Driver OFFLINE or logout** → `stopFloatingBubble` → notification + overlay removed.

## Rapido/Uber-style constraints (read this)

- **OEM battery / “auto start”**: MIUI, Vivo, Oppo, Realme, Samsung may kill background services or block overlay until the user allows “display over other apps” and disables battery restrictions for UGO Driver. The app already requests ignore-battery-optimizations where applicable; you may add an in-app “Help → Stay online” screen linking to vendor settings.
- **Android 12+**: Foreground services started from background are restricted. **Mitigation**: FGS is started while the activity is in foreground when the driver toggles ONLINE (and on cold start after prefs load if still online).
- **Android 14/15**: Declare correct `foregroundServiceType` (`dataSync` today). For Play policy changes, you may need `specialUse` or `location` with Play Console declarations.
- **Force-stop**: User force-stopping the app kills everything until the user opens the app again.
- **Close on bubble**: The bubble’s close control **opens the app**; it does **not** go offline (offline is only from the in-app toggle / logout).

## Files touched (reference)

- `android/.../CaptainBubbleService.kt` — FGS, overlay, `onTaskRemoved`, suppress flag.
- `android/.../MainActivity.kt` — channel + `DriverOnlinePrefs`.
- `android/.../DriverOnlinePrefs.kt` — reads Flutter online flag.
- `android/.../DriverOnlineBootReceiver.kt` — boot restart.
- `android/app/src/main/AndroidManifest.xml` — service, receiver, `RECEIVE_BOOT_COMPLETED`.
- `lib/home/home_widget.dart` — `_syncFloatingBubble`.
- `lib/main.dart` — post-prefs bubble sync; no `stopFloatingBubble` on `detached`.

## Fallback if the service dies

- Socket / push may still wake the app; on next **Home** resume, `_syncFloatingBubble(force: true)` restores FGS if ONLINE.
- Consider a periodic “still online?” ping that restarts FGS only when `isonline` and overlay granted (optional; watch battery).
