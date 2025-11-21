#!/usr/bin/env bash
set -euo pipefail

disallowed=$(rg -n "createServiceRoleClient\\(" apps/web_pwa | rg -v "app/api/admin/" || true)
if [[ -n "$disallowed" ]]; then
  echo "ERROR: service-role usage found outside admin APIs:"
  echo "$disallowed"
  exit 1
fi
echo "OK: no service-role usage in buyer flows."
