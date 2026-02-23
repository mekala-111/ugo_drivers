# ugo_driver

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

### Maps API Key

Add `MAPS_API_KEY=your_key` to `android/local.properties` (this file is gitignored).

**Run with Maps key passed to Dart (for polyline/directions):**
```bash
./scripts/flutter_run.sh
# or with device: ./scripts/flutter_run.sh -d V2151
```

Or manually: `flutter run --dart-define=GOOGLE_MAPS_API_KEY=$(grep '^MAPS_API_KEY=' android/local.properties | cut -d'=' -f2)`
