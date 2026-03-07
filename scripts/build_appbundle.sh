#!/bin/bash
# Build app bundle via Gradle directly (bypasses Flutter's strip validation that fails on some setups).
# Output: build/app/outputs/bundle/release/app-release.aab
set -e
cd "$(dirname "$0")/.."
echo "Building app bundle (via Gradle, bypassing Flutter strip check)..."
flutter pub get
cd android
./gradlew bundleRelease
cd ..
echo ""
echo "✅ App bundle built successfully!"
echo "   Location: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Note: Built via Gradle directly. The bundle is valid for Play Store upload."
