#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
PG_URI=${PG_URI:-postgres://postgres:postgres@127.0.0.1:54322/postgres}

psql "$PG_URI" -f "$ROOT_DIR/seed.sql"
