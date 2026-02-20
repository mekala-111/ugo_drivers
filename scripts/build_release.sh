#!/bin/bash
# Build release APK/Bundle with obfuscation (Play Store deployable)
# Run: ./scripts/build_release.sh [apk|bundle]
set -e
OUTPUT="${1:-apk}"
SYMBOLS_DIR="build/app/outputs/symbols"

echo "Building release with obfuscation..."

if [ "$OUTPUT" = "bundle" ]; then
  flutter build appbundle --release --obfuscate --split-debug-info="$SYMBOLS_DIR"
  echo "✅ App bundle: build/app/outputs/bundle/release/app-release.aab"
  echo "   Debug symbols: $SYMBOLS_DIR (upload to Play Console if needed)"
else
  flutter build apk --release --obfuscate --split-debug-info="$SYMBOLS_DIR"
  echo "✅ APK: build/app/outputs/flutter-apk/app-release.apk"
  echo "   Debug symbols: $SYMBOLS_DIR"
fi
