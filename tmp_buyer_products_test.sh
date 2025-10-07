#!/usr/bin/env bash
set -euo pipefail

SUPABASE_URL="http://127.0.0.1:54321"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
EMAIL="buyer1@demo.local"
PASSWORD="Demo123!"

response=$(curl -sS -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
  -H "apikey: $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

token=$(printf '%s' "$response" | jq -r '.access_token')
if [[ -z "$token" || "$token" == "null" ]]; then
  printf 'Failed to obtain access token. Response:\n%s\n' "$response" >&2
  exit 1
fi

curl -sS -w '\nHTTP_STATUS:%{http_code}\n' \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $token" \
  "$SUPABASE_URL/rest/v1/products?select=id,sku,name&limit=3"
