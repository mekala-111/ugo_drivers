#!/bin/bash
# Build release APK/Bundle with obfuscation (Play Store deployable)
# Run: ./scripts/build_release.sh [apk|bundle]
# Uses MAPS_API_KEY from android/local.properties for Directions/polyline API.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT="${1:-apk}"
SYMBOLS_DIR="build/app/outputs/symbols"

MAPS_KEY=""
if [ -f "$PROJECT_ROOT/android/local.properties" ]; then
  MAPS_KEY=$(grep '^MAPS_API_KEY=' "$PROJECT_ROOT/android/local.properties" 2>/dev/null | cut -d'=' -f2- | tr -d '\r')
fi

DART_DEFINES=()
[ -n "$MAPS_KEY" ] && DART_DEFINES+=(--dart-define=GOOGLE_MAPS_API_KEY="$MAPS_KEY")

echo "Building release with obfuscation..."

if [ "$OUTPUT" = "bundle" ]; then
  flutter build appbundle --release --obfuscate --split-debug-info="$SYMBOLS_DIR" "${DART_DEFINES[@]}"
  echo "✅ App bundle: build/app/outputs/bundle/release/app-release.aab"
  echo "   Debug symbols: $SYMBOLS_DIR (upload to Play Console if needed)"
else
  flutter build apk --release --obfuscate --split-debug-info="$SYMBOLS_DIR" "${DART_DEFINES[@]}"
  echo "✅ APK: build/app/outputs/flutter-apk/app-release.apk"
  echo "   Debug symbols: $SYMBOLS_DIR"
fi
