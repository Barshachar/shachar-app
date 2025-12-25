#!/usr/bin/env bash
set -euo pipefail

# Fail CI if JS/TS/Node artifacts sneak into the Flutter tree.
# Run locally: bash .ci/guard-flutter-node-artifacts.sh

violations=$(
  { rg --files -g '*.{ts,tsx,js,jsx}' apps/b2b_flutter || true; }
)

node_dirs=$(find apps/b2b_flutter -type d -name node_modules 2>/dev/null || true)

if [[ -n "$violations" ]] || [[ -n "$node_dirs" ]]; then
  echo "ERROR: Node/JS/TS artifacts found under apps/b2b_flutter (remove web/Next files from Flutter tree):"
  [[ -n "$violations" ]] && echo "$violations"
  [[ -n "$node_dirs" ]] && echo "$node_dirs"
  exit 1
fi

echo "OK: no JS/TS artifacts detected in apps/b2b_flutter."
