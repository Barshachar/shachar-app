#!/usr/bin/env bash
set -euo pipefail

APP="${APP:-$(cd "$(dirname "$0")/.." && pwd)}"
UDID="DB61D22F-A3BC-4034-B2FE-1ECD781480E4"
BUNDLE_ID="com.shachar.ashachar.dev"
SIM_RESULT_FILE="${SIM_RESULT_FILE:-/tmp/sim-run.status}"

cd "$APP"
: > "$SIM_RESULT_FILE"

build_status="built"

echo "=== SIM • Build (ios simulator, ENV=dev) ==="
rm -rf "build/ios/iphonesimulator/Runner.app"
if ! flutter build ios --simulator --debug \
  --dart-define=ENV=dev \
  --dart-define=INITIAL_ROUTE=/home
then
  build_rc=$?
  build_status="failed"
  echo "=== SIM • Build failed (exit $build_rc). Not installing stale Runner.app ===" >&2
  exit "$build_rc"
fi

echo "=== SIM • Boot & Launch ==="
open -a Simulator || true
xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b

xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$UDID" "build/ios/iphonesimulator/Runner.app"
xcrun simctl launch "$UDID" "$BUNDLE_ID" || true

echo "=== SIM • Runner logs (last 2m) ==="
xcrun simctl spawn "$UDID" log show \
  --style compact \
  --last 2m \
  --predicate 'process == "Runner"' | tail -n 120

printf 'build_status=%s
' "$build_status" > "$SIM_RESULT_FILE"
