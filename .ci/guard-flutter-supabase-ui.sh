#!/usr/bin/env bash
set -euo pipefail

# Guard against unintended Supabase JS/web client artifacts in the Flutter tree.
# Run locally: bash .ci/guard-flutter-supabase-ui.sh

violations=$(
  {
    rg -n "@supabase/supabase-js|createClient\\(" apps/b2b_flutter || true
    rg -n "Supabase\\.instance\\.client" apps/b2b_flutter/lib/src/features --glob '!**/data/**' --glob '!**/core/**' || true
  }
)

if [[ -n "$violations" ]]; then
  echo "ERROR: Supabase web/JS client artifacts detected in Flutter app (or direct client use outside data/core):"
  echo "$violations"
  exit 1
fi

echo "OK: no web Supabase artifacts in Flutter UI layers."
