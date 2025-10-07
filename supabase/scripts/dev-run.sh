#!/usr/bin/env bash
set -euo pipefail

( cd .. && supabase start ) &
SUPABASE_PID=$!
trap 'kill $SUPABASE_PID' EXIT

echo "Waiting for Supabase to start..."
sleep 10

echo "Run Flutter in web mode"
( cd ../app && flutter run -d chrome )
