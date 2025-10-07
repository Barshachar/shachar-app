#!/usr/bin/env bash
set -euo pipefail

cd "$(cd "$(dirname "$0")/../.." && pwd)/apps/b2b_flutter" || exit 1
mkdir -p /tmp/agent-logs

echo "== analyze ==" | tee /tmp/agent-logs/analyze.log
flutter analyze 2>&1 | tee -a /tmp/agent-logs/analyze.log

# טסטים כלליים (יחידה+ווידג'טים)
echo "== unit+widget tests ==" | tee /tmp/agent-logs/unit.log
flutter test -r compact 2>&1 | tee -a /tmp/agent-logs/unit.log || true

# פילוחים לפי תחום (כדי שכל סוכן יקבל לוג ממוקד)
echo "== AUTH scope tests ==" | tee /tmp/agent-logs/auth.log
flutter test -r compact test/auth 2>&1 | tee -a /tmp/agent-logs/auth.log || true

echo "== CATALOG scope tests ==" | tee /tmp/agent-logs/catalog.log
flutter test -r compact test/catalog 2>&1 | tee -a /tmp/agent-logs/catalog.log || true

echo "== ORDERS scope tests ==" | tee /tmp/agent-logs/orders.log
flutter test -r compact test/orders 2>&1 | tee -a /tmp/agent-logs/orders.log || true

echo "== VENDOR scope tests (integration selector) ==" | tee /tmp/agent-logs/vendor.log
flutter test integration_test/order_flow_test.dart --plain-name 'Vendor:' -r expanded 2>&1 | tee -a /tmp/agent-logs/vendor.log || true

echo "== ADMIN scope tests (integration selector) ==" | tee /tmp/agent-logs/admin.log
flutter test integration_test/order_flow_test.dart --plain-name 'Admin:' -r expanded 2>&1 | tee -a /tmp/agent-logs/admin.log || true

echo
echo "לוגים לפי תחום נמצאים תחת:"
ls -1 /tmp/agent-logs
