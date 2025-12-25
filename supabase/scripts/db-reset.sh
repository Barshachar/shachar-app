#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PG_URI=${PG_URI:-postgres://postgres:postgres@127.0.0.1:54322/postgres}

supabase db reset --no-seed --yes

psql "$PG_URI" -f "$ROOT_DIR/sql/schema_applied.sql"
psql "$PG_URI" -f "$ROOT_DIR/sql/patches/023_admin_user_management.sql"
psql "$PG_URI" -f "$ROOT_DIR/sql/patches/025_returns_lifecycle.sql"
psql "$PG_URI" -f "$ROOT_DIR/sql/patches/026_order_cancellation.sql"
psql "$PG_URI" -f "$ROOT_DIR/sql/patches/027_approvals_inbox.sql"
psql "$PG_URI" -f "$ROOT_DIR/sql/policies_apply.sql"
psql "$PG_URI" -f "$ROOT_DIR/seed.sql"
