#!/usr/bin/env bash
set -euo pipefail
violations=$(rg -n "import .+apps/b2b_flutter" packages/dart/offline_toolkit || true)
if [[ -n "$violations" ]]; then
  echo "Forbidden imports in offline_toolkit:"
  echo "$violations"
  exit 1
fi
echo "OK: no app imports inside offline_toolkit."
