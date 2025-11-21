#!/usr/bin/env bash
set -euo pipefail

EXPECTED_DB_URL="postgres://postgres:postgres@127.0.0.1:54322/postgres"

if [ -z "${DATABASE_URL:-}" ]; then
  echo "::warning::DATABASE_URL not set; defaulting to safe dev instance at $EXPECTED_DB_URL"
  export DATABASE_URL="$EXPECTED_DB_URL"
fi

if [ "$DATABASE_URL" != "$EXPECTED_DB_URL" ]; then
  echo "::warning::DATABASE_URL is '$DATABASE_URL' (expected $EXPECTED_DB_URL for local QA)."
fi

if ! command -v node >/dev/null 2>&1; then
  echo "::error::Node is not installed. Please install Node >= 20."
  exit 2
fi

NODE_MAJOR="$(node -v | sed -E 's/^v([0-9]+).*/\1/')"
if [ -n "$NODE_MAJOR" ] && [ "$NODE_MAJOR" -lt 20 ]; then
  echo "::error::Node $NODE_MAJOR detected. Please use Node >= 20 (e.g. 'nvm use 20')."
  exit 2
fi

PNPM_CMD=()
if [ -n "${PNPM_EXEC:-}" ]; then
  # shellcheck disable=SC2206
  PNPM_CMD=(${PNPM_EXEC})
else
  PNPM_CMD=(pnpm)
fi

if ! command -v "${PNPM_CMD[0]}" >/dev/null 2>&1; then
  echo "::error::pnpm executable '${PNPM_CMD[*]}' not found. Set PNPM_EXEC to a valid pnpm binary."
  exit 2
fi

TMP_OUT="$(mktemp)"
echo "Generating TS types from DB..."
"${PNPM_CMD[@]}" dlx supabase@latest gen types typescript --db-url "$DATABASE_URL" --schema public > "$TMP_OUT"

echo "Diff against committed file..."
diff -u "$TMP_OUT" apps/web_pwa/lib/generated/supabase.types.ts || {
  echo "::error::Supabase TS types drifted. Run the same generation locally and commit the updated file."
  exit 1
}

echo "OK: TS types are in sync."
