#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
APP="${APP:-$REPO_ROOT/apps/b2b_flutter}"
DEFAULT_UDID="$(
  python3 - <<'PY' 2>/dev/null || true
import json, subprocess, re

data = subprocess.check_output(["xcrun", "simctl", "list", "devices", "--json"])
j = json.loads(data)

runtime_ids = [rid for rid in j.get("devices", {}).keys() if rid.startswith("com.apple.CoreSimulator.SimRuntime.iOS-")]
def parse_version(runtime_id: str):
    m = re.search(r"iOS-(\\d+)(?:-(\\d+))?$", runtime_id)
    if not m:
        return (0, 0)
    return (int(m.group(1)), int(m.group(2) or 0))

runtime_ids.sort(key=parse_version, reverse=True)
for rid in runtime_ids:
    devices = [d for d in j["devices"].get(rid, []) if d.get("isAvailable") and "iPhone" in d.get("name", "")]
    if not devices:
        continue
    preferred = [d for d in devices if d.get("name") == "iPhone 17 Pro"]
    pick = (preferred[0] if preferred else devices[0])
    print(pick.get("udid", ""))
    raise SystemExit(0)
PY
)"
UDID="${UDID:-${DEFAULT_UDID:-DB61D22F-A3BC-4034-B2FE-1ECD781480E4}}"
BUNDLE_ID="com.shachar.ashachar.dev"
SIM_RESULT_FILE="${SIM_RESULT_FILE:-/tmp/sim-run.status}"

cd "$APP"
: > "$SIM_RESULT_FILE"

build_status="built"

echo "=== SIM • Boot ==="
open -a Simulator || true
xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b

echo "=== SIM • Build (ios simulator, ENV=dev) ==="
rm -rf "build/ios/iphonesimulator/Runner.app"
build_rc=0
flutter build ios --simulator --debug \
  --dart-define=ENV=dev \
  --dart-define=INITIAL_ROUTE=/home || build_rc=$?
if [[ "$build_rc" -ne 0 ]]; then
  build_status="failed"
  echo "=== SIM • Build failed (exit $build_rc). Not installing stale Runner.app ===" >&2
  printf 'build_status=%s\n' "$build_status" > "$SIM_RESULT_FILE"
  exit "$build_rc"
fi

echo "=== SIM • Boot & Launch ==="
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
