#!/usr/bin/env bash
set -euo pipefail

# Regenerate Dart supabase types from the canonical TS snapshot.
# Usage:
#   DATABASE_URL=postgres://... bash tools/ci/gen-dart-types.sh
#   USE_EXISTING_TS=1 bash tools/ci/gen-dart-types.sh  # reuse current TS snapshot

OUT_FILE="packages/dart/contracts/lib/generated/supabase.types.dart"
TMP_TS="$(mktemp)"
DEFAULT_DB_URL="postgres://postgres:postgres@127.0.0.1:54322/postgres"

if [ -z "${DATABASE_URL:-}" ]; then
  echo "::warning::DATABASE_URL not set; defaulting to $DEFAULT_DB_URL"
  export DATABASE_URL="$DEFAULT_DB_URL"
fi

if [ "${USE_EXISTING_TS:-}" = "1" ]; then
  cp packages/contracts/src/generated/supabase.types.ts "$TMP_TS"
else
  supabase gen types typescript --db-url "$DATABASE_URL" --schema public >"$TMP_TS"
fi

HASH="$(sha256sum "$TMP_TS" | awk '{print $1}')"

python3 - <<'PY' "$TMP_TS" "$OUT_FILE" "$HASH"
import pathlib
import sys

ts_path = pathlib.Path(sys.argv[1])
out_path = pathlib.Path(sys.argv[2])
schema_hash = sys.argv[3]

ts_content = ts_path.read_text()

out_path.parent.mkdir(parents=True, exist_ok=True)
out_path.write_text(
    f"""// GENERATED CODE - DO NOT EDIT.
// Source: supabase gen types typescript --schema public
// Schema hash: {schema_hash}

typedef Json = Object?;
typedef Database = Map<String, dynamic>;

/// Raw Supabase TypeScript definitions embedded for reference and drift detection.
const String supabaseTypesTypescript = r'''{ts_content}''';
"""
)
PY

echo "Wrote Dart supabase types to $OUT_FILE (hash $HASH)"
