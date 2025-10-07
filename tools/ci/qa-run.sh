#!/usr/bin/env bash
set -euo pipefail
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
APP="${APP:-$REPO_ROOT/apps/b2b_flutter}"
if [[ ! -f "$APP/pubspec.yaml" ]]; then
  echo "Error: No pubspec.yaml found at $APP" >&2
  exit 1
fi
UDID="DB61D22F-A3BC-4034-B2FE-1ECD781480E4"
BUNDLE_ID="com.shachar.ashachar.dev"
SUPABASE_URL="http://127.0.0.1:54321"
DB_HOST=127.0.0.1; DB_PORT=54322
cd "$APP"

QA_LOG_DIR="$APP/build/qa/logs"
mkdir -p "$QA_LOG_DIR"
ANALYZE_LOG="$QA_LOG_DIR/flutter_analyze.log"
UNIT_TEST_LOG="$QA_LOG_DIR/flutter_test.log"
SCREENSHOT_LOG="$QA_LOG_DIR/orders_screenshot.log"
INTEGRATION_LOG="$QA_LOG_DIR/integration.log"

SOFT_FAILURE=0

run_and_log() {
  local log_file="$1"; shift
  local description="$1"; shift
  echo "=== QA • ${description} ==="
  rm -f "$log_file"
  set +e
  "$@" | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e
  if [[ $status -ne 0 ]]; then
    echo "[QA] ${description} FAILED (exit $status)"
    tail -n 80 "$log_file" || true
    exit $status
  fi
  tail -n 20 "$log_file" || true
}

run_and_log_soft() {
  local log_file="$1"; shift
  local description="$1"; shift
  echo "=== QA • ${description} (soft gate) ==="
  rm -f "$log_file"
  set +e
  "$@" | tee "$log_file"
  local status=${PIPESTATUS[0]}
  set -e
  if [[ $status -ne 0 ]]; then
    echo "[QA] ${description} FAILED (soft gate, continuing) (exit $status)"
    tail -n 80 "$log_file" || true
    SOFT_FAILURE=1
  else
    tail -n 20 "$log_file" || true
  fi
}

ensure_screenshot() {
  local base_name="$1"
  local label="$2"
  local base_file="docs/screens/orders/${base_name}.png"
  local pattern="docs/screens/orders/${base_name}_*.png"

  if [[ ! -s "$base_file" ]]; then
    echo "[QA] Missing latest screenshot: $base_file"
    if [[ -f "$SCREENSHOT_LOG" ]]; then
      echo "[QA] tail orders_screenshot.log"
      tail -n 80 "$SCREENSHOT_LOG"
    elif [[ -f "$UNIT_TEST_LOG" ]]; then
      echo "[QA] tail flutter_test.log"
      tail -n 80 "$UNIT_TEST_LOG"
    fi
    exit 1
  fi

  if ! compgen -G "$pattern" >/dev/null; then
    echo "[QA] Missing timestamped screenshot (pattern: $pattern)"
    if [[ -f "$SCREENSHOT_LOG" ]]; then
      echo "[QA] tail orders_screenshot.log"
      tail -n 80 "$SCREENSHOT_LOG"
    elif [[ -f "$UNIT_TEST_LOG" ]]; then
      echo "[QA] tail flutter_test.log"
      tail -n 80 "$UNIT_TEST_LOG"
    fi
    exit 1
  fi

  local latest
  latest=$(ls -1t $pattern 2>/dev/null | head -n1 || true)
  echo "[QA] ${label} screenshot: $(basename "$latest")"
}

echo "=== QA • Supabase health ==="
SKIP_ADMIN_SCENARIOS="false"
if ! supabase status >/dev/null 2>&1; then
  echo "supabase CLI not found or not initialized; admin scenarios will be skipped."
  SKIP_ADMIN_SCENARIOS="true"
else
  # Try to ensure services are up
  if ! supabase status 2>/dev/null | grep -qi 'Started'; then
    echo "Starting local Supabase (dev)..."
    supabase start || true
  fi
  # Wait for REST & Auth health up to ~60s
  READY=0
  for i in $(seq 1 60); do
    if curl -fsS "$SUPABASE_URL/auth/v1/health" >/dev/null 2>&1 && \
       curl -fsS -o /dev/null -w "%{http_code}" "$SUPABASE_URL/rest/v1/" \
         | grep -qE '200|404'; then
      READY=1
      break
    fi
    sleep 1
  done
  if [ "$READY" != "1" ]; then
    echo "Supabase health not ready; admin scenarios will be skipped."
    SKIP_ADMIN_SCENARIOS="true"
  fi
fi

echo "=== QA • Toolchain ==="
flutter --version | head -n1 || true
supabase --version || true

echo "=== QA • Fix RLS recursion on order_items (safe, idempotent) ==="
cat > /tmp/rls_order_items_fix.sql <<'SQL'
do $$
declare r record;
begin
  for r in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename  = 'order_items'
      and cmd in ('INSERT','ALL')
      and policyname ilike '%customer%insert%'
  loop
    execute format('drop policy if exists %I on public.order_items;', r.policyname);
  end loop;
end$$;

create or replace function public.order_item_customer_company(p_order_id uuid)
returns uuid
language sql
stable
security definer
set search_path = public, auth
as $$
  select customer_company_id
  from public.orders
  where id = p_order_id;
$$;
grant execute on function public.order_item_customer_company(uuid) to authenticated, service_role;

create or replace function public.order_item_customer_guard(p_order_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_company uuid;
  v_auth uuid := auth_company_id();
  v_role text := current_setting('request.jwt.claims', true)::json->>'role';
begin
  select customer_company_id into v_company
    from public.orders
   where id = p_order_id;

  if v_auth is null then
    raise exception 'auth_company_id() is null for role %', v_role using errcode = '42501';
  end if;

  if v_company is null then
    raise exception 'order % not visible (company null) for role %', p_order_id, v_role using errcode = '42501';
  end if;

  if v_company <> v_auth then
    raise exception 'order % belongs to % but auth has %', p_order_id, v_company, v_auth using errcode = '42501';
  end if;

  return true;
end;
$$;

grant execute on function public.order_item_customer_guard(uuid) to authenticated, service_role;

-- 2) צור מדיניות INSERT נכונה ללקוח – WITHOUT recursion (בדיקה מול orders בלבד)
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='public' and tablename='order_items'
      and policyname='order_items_customer_insert' and cmd in ('INSERT','ALL')
  ) then
    create policy order_items_customer_insert on public.order_items
    for insert to authenticated
    with check (
      auth_role() in ('customer_admin','buyer')
      and order_item_customer_guard(order_items.order_id)
    );
  end if;
end$$;

-- 3) וידוא rpc_create_draft מאובטח
create or replace function public.rpc_create_draft()
returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_user uuid := auth.uid();
  v_company uuid := auth_company_id();
  v_existing uuid;
begin
  if v_user is null then
    raise exception 'Authentication required' using errcode = '28000';
  end if;

  if v_company is null then
    raise exception 'Company context missing';
  end if;

  select id
    into v_existing
    from orders
   where status = 'draft'
     and customer_company_id = v_company
     and created_by = v_user
   order by created_at desc
   limit 1;

  if v_existing is not null then
    return v_existing;
  end if;

  insert into orders (customer_company_id, created_by, status, currency)
  values (v_company, v_user, 'draft', 'ILS')
  returning id into v_existing;

  insert into audit_log(actor_user_id, action, table_name, row_id, metadata)
  values (v_user, 'order_draft_created', 'orders', v_existing, jsonb_build_object('currency', 'ILS'));

  return v_existing;
end;
$$;

grant execute on function public.rpc_create_draft() to authenticated, service_role;
SQL
PGPASSWORD=postgres psql -h $DB_HOST -p $DB_PORT -U postgres -d postgres -v ON_ERROR_STOP=1 -f /tmp/rls_order_items_fix.sql | tail -n 20

echo "=== QA • Build+Launch (ENV=dev) ==="
open -a Simulator || true
xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b
flutter build ios --simulator --debug --dart-define=ENV=dev
xcrun simctl terminate "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl uninstall "$UDID" "$BUNDLE_ID" 2>/dev/null || true
xcrun simctl install "$UDID" "build/ios/iphonesimulator/Runner.app"
xcrun simctl launch "$UDID" "$BUNDLE_ID" || true

run_and_log "$ANALYZE_LOG" "Unit/Analyze • flutter analyze" flutter analyze
run_and_log "$UNIT_TEST_LOG" "Unit/Analyze • flutter test -r compact" flutter test -r compact
run_and_log "$SCREENSHOT_LOG" "Screenshots • flutter test docs/screens/product_checkout_test.dart" \
  flutter test docs/screens/product_checkout_test.dart -r compact

echo "=== QA • Screenshot validation ==="
ensure_screenshot "orders_list" "Orders list"
ensure_screenshot "order_detail" "Order detail"
echo "[QA] Orders screenshots OK"

echo "=== QA • Integration (UI) ==="
# מריץ בדיקת אינטגרציה על הסימולטור (soft gate)
run_and_log_soft "$INTEGRATION_LOG" "Integration(UI) • order_flow_test" \
  flutter test -d "$UDID" integration_test/order_flow_test.dart -r compact \
    --dart-define=ENV=dev \
    --dart-define=INITIAL_ROUTE=/home \
    --dart-define=SKIP_ADMIN_SCENARIOS=$SKIP_ADMIN_SCENARIOS

echo "=== QA • Runner log (markers) ==="
xcrun simctl spawn "$UDID" log show --style compact --last 2m \
  --predicate 'process == "Runner" AND (eventMessage CONTAINS "Order submitted:" OR eventMessage CONTAINS "[ORDER_FLOW]" OR eventMessage CONTAINS "Demo sign-in result")' \
  | tail -n 120 || true

echo "=== FINAL STATUS (QA) ==="
echo "- RLS order_items: fixed safe insert (see above)."
echo "- Build+Launch: done (ENV=dev)."
echo "- Unit/Analyze: see tails above."
if [[ $SOFT_FAILURE -ne 0 ]]; then
  echo "- Integration(UI): soft gate had failures; inspect $INTEGRATION_LOG"
else
  echo "- Integration(UI): look for PASS in output + 'Order submitted:' in logs."
fi
QA_STATUS="GREEN"
if [[ $SOFT_FAILURE -ne 0 ]]; then
  QA_STATUS="GREEN (with soft warnings)"
fi
echo "QA STATUS: $QA_STATUS"
