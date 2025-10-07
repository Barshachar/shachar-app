#!/usr/bin/env bash
set -euo pipefail

if ! command -v supabase >/dev/null 2>&1; then
  echo "Supabase CLI is required. Install from https://supabase.com/docs/guides/cli" >&2
  exit 1
fi

supabase start
