#!/bin/bash
# Run Flutter with MAPS_API_KEY from android/local.properties passed as dart-define.
# Use: ./scripts/flutter_run.sh [flutter run args...]
# Example: ./scripts/flutter_run.sh -d V2151
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOCAL_PROPS="$PROJECT_ROOT/android/local.properties"

MAPS_KEY=""
if [ -f "$LOCAL_PROPS" ]; then
  MAPS_KEY=$(grep '^MAPS_API_KEY=' "$LOCAL_PROPS" 2>/dev/null | cut -d'=' -f2- | tr -d '\r')
fi

DART_DEFINES=()
if [ -n "$MAPS_KEY" ]; then
  DART_DEFINES+=(--dart-define=GOOGLE_MAPS_API_KEY="$MAPS_KEY")
fi

cd "$PROJECT_ROOT"
exec flutter run "${DART_DEFINES[@]}" "$@"
