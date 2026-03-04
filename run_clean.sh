#!/bin/bash
# Run Flutter with filtered logs (removes E/FrameEvents and other noise)
# Automatically reads MAPS_API_KEY from android/local.properties

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_PROPS="$SCRIPT_DIR/android/local.properties"

MAPS_KEY=""
if [ -f "$LOCAL_PROPS" ]; then
  MAPS_KEY=$(grep '^MAPS_API_KEY=' "$LOCAL_PROPS" 2>/dev/null | cut -d'=' -f2- | tr -d '\r')
fi

DART_DEFINES=()
if [ -n "$MAPS_KEY" ]; then
  DART_DEFINES+=(--dart-define=GOOGLE_MAPS_API_KEY="$MAPS_KEY")
  echo "✅ Using Google Maps API key from local.properties"
else
  echo "⚠️ No MAPS_API_KEY found in local.properties"
fi

flutter run "${DART_DEFINES[@]}" "$@" 2>&1 | sed -E $'s/\x1B\[[0-9;]*[[:alpha:]]//g' | grep -v -E '(^|[[:space:]])[EWI]/FrameEvents\(|W/ActivityThread|I/chatty'
