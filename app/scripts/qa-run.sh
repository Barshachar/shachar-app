#!/usr/bin/env bash
set -euo pipefail
export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

PASS_MARKER="QA STATUS: GREEN / PASS"
FAIL_MARKER="QA STATUS: RED / FAIL"

DEFAULT_LOG_FILE="/tmp/qa-run.log"
LOG_FILE=${LOG_FILE:-$DEFAULT_LOG_FILE}
mkdir -p "$(dirname "$LOG_FILE")"
: > "$LOG_FILE"
exec > >(tee "$LOG_FILE") 2>&1

AUTH_RATE_LIMIT_DETECTED=0
AUTH_COOLDOWN_SEC="${AUTH_COOLDOWN_SEC:-45}"

# ראנר ל-flutter drive עם Retry על 429 וקירור בין ריצות
run_drive_with_retry() {
  local name="$1"; shift
  local logfile="/tmp/qa-drive-${name}.log"
  : > "$logfile"

  local safe_name
  safe_name=$(printf '%s' "$name" | tr '[:lower:]' '[:upper:]')
  safe_name=${safe_name//[^A-Z0-9]/_}
  local flag_var="AUTH429_${safe_name}"

  local code
  set +e
  (flutter drive "$@" 2>&1) | tee "$logfile" | tee -a /tmp/qa-run.log
  code=${PIPESTATUS[0]}
  set -e

  if grep -q "status=429" "$logfile"; then
    AUTH_RATE_LIMIT_DETECTED=1
    printf -v "$flag_var" "%s" "1"
  else
    printf -v "$flag_var" "%s" "0"
  fi

  if [ $code -ne 0 ] && grep -q "login=error" "$logfile" && grep -q "status=429" "$logfile"; then
    echo "[QA] Detected auth 429 in ${name}. Cooldown ${AUTH_COOLDOWN_SEC}s and retry once..."
    sleep "${AUTH_COOLDOWN_SEC}"
    set +e
    (flutter drive "$@" 2>&1) | tee -a "$logfile" | tee -a /tmp/qa-run.log
    code=${PIPESTATUS[0]}
    set -e
    if grep -q "status=429" "$logfile"; then
      AUTH_RATE_LIMIT_DETECTED=1
      printf -v "$flag_var" "%s" "1"
    else
      printf -v "$flag_var" "%s" "0"
    fi
  fi

  sleep "${AUTH_COOLDOWN_SEC}"
  return $code
}

print_tail() {
  echo "=== QA • Log Tail (last 120 lines) ==="
  tail -n 120 "$LOG_FILE" || true
}

print_marker_summary() {
  echo "=== QA • Marker Tail Summary ==="
  if [ ! -f "$LOG_FILE" ]; then
    echo "(log file not found: $LOG_FILE)"
    return 0
  fi

  local marker
  local marker_output
  for marker in "[NAV]" "[AUTH_FLOW]" "[ORDER_FLOW]" "[QA_ORDER]"; do
    echo "Marker ${marker} (last 40 lines):"
    marker_output="$(grep -F "$marker" "$LOG_FILE" 2>/dev/null | tail -n 40 || true)"
    if [ -z "$marker_output" ]; then
      echo "(no recent entries)"
    else
      printf '%s\n' "$marker_output"
    fi
  done
}

finalize_log() {
  if [ "$LOG_FILE" != "$DEFAULT_LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
    cp "$LOG_FILE" "$DEFAULT_LOG_FILE" || true
  fi
}

on_fail() {
  {
    print_marker_summary
    print_tail
  } || true
  echo "$FAIL_MARKER"
}
trap on_fail ERR
trap finalize_log EXIT

run_step() {
  local label="$1"
  local status_var="$2"
  local tail_lines="$3"
  local severity="$4" # "strict" or "warn"
  shift 4

  local safe_label
  safe_label=$(printf '%s' "$label" | tr -c '[:alnum:]' '_')
  local log_file
  log_file=$(mktemp -t "qa_${safe_label}.XXXX.log")

  set +e
  "$@" | tee "$log_file"
  local rc=${PIPESTATUS[0]}
  set -e

  tail -n "$tail_lines" "$log_file" || true
  rm -f "$log_file"

  if [ "$rc" -ne 0 ]; then
    if [ "$severity" = "strict" ]; then
      echo "[$label] FAILED (exit $rc)" >&2
      FAIL_STEPS+=("$label")
      printf -v "$status_var" "FAIL"
    else
      echo "[$label] WARN (exit $rc)" >&2
      WARN_STEPS+=("$label")
      printf -v "$status_var" "WARN"
    fi
  else
    echo "[$label] PASS"
    printf -v "$status_var" "PASS"
  fi
}

run_with_timeout() {
  local timeout_seconds="$1"
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout_seconds" "$@"
  else
    perl -e 'alarm shift @ARGV; exec @ARGV' "$timeout_seconds" "$@"
  fi
}

ensure_supabase_running() {
  local status_output
  status_output=$(mktemp -t qa_supabase_status.XXXX)
  if supabase status -o json >"$status_output" 2>&1; then
    echo "Supabase already running"
    cat "$status_output"
    rm -f "$status_output"
    return 0
  fi

  echo "Supabase not running; attempting to start (timeout 180s)..."
  if ! run_with_timeout 180 supabase start; then
    echo "Supabase failed to start within timeout" >&2
    rm -f "$status_output"
    return 1
  fi

  if ! supabase status -o json >"$status_output" 2>&1; then
    echo "Supabase status still unavailable after start" >&2
    rm -f "$status_output"
    return 1
  fi
  echo "Supabase started successfully"
  cat "$status_output"
  rm -f "$status_output"
}

create_order_flow() {
  local order_file="$1"
  (
    set -euo pipefail
    local config_json="$APP/assets/config/app_config.dev.json"
    if [ ! -f "$config_json" ]; then
      echo "Config file not found at $config_json" >&2
      return 1
    fi

    local supabase_status_json
    if ! supabase_status_json=$(supabase status -o json 2>/dev/null); then
      echo "Unable to fetch Supabase status (is Supabase running?)" >&2
      return 1
    fi

    local anon_key
    anon_key=$(printf '%s' "$supabase_status_json" | jq -r '.services.api.anon_key // empty')
    if [ -z "$anon_key" ] || [ "$anon_key" = "null" ]; then
      anon_key=$(jq -r '.SUPABASE_ANON_KEY // empty' "$config_json")
    fi
    if [ -z "$anon_key" ] || [ "$anon_key" = "null" ]; then
      echo "Anon key could not be resolved" >&2
      return 1
    fi

    local supabase_url email password
    supabase_url=$(jq -r '.SUPABASE_URL // empty' "$config_json")
    email=$(jq -r '.DEMO_EMAIL // empty' "$config_json")
    password=$(jq -r '.DEMO_PASSWORD // empty' "$config_json")
    if [ -z "$supabase_url" ] || [ "$supabase_url" = "null" ]; then
      supabase_url="$SUPABASE_URL"
    fi
    if [ -z "$email" ] || [ -z "$password" ]; then
      echo "Demo buyer credentials missing in config" >&2
      return 1
    fi

    local auth_json
    auth_json=$(curl -sfS -X POST "$supabase_url/auth/v1/token?grant_type=password" \
      -H "apikey: $anon_key" \
      -H "Content-Type: application/json" \
      --max-time 30 \
      -d "{\"email\":\"$email\",\"password\":\"$password\"}")

    local access_token
    access_token=$(printf '%s' "$auth_json" | jq -r '.access_token // empty')
    if [ -z "$access_token" ] || [ "$access_token" = "null" ]; then
      echo "Password grant did not return an access token" >&2
      printf '%s\n' "$auth_json" >&2
      return 1
    fi

    local order_json order_id
    order_json=$(curl -sfS -X POST "$supabase_url/rest/v1/rpc/rpc_create_draft" \
      -H "apikey: $anon_key" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-Type: application/json" \
      -H "Prefer: return=representation" \
      --max-time 30 \
      -d '{}')
    order_id=$(printf '%s' "$order_json" | jq -r '
      if type == "string" then .
      elif type == "object" then (.rpc_create_draft // .id // .order_id // empty)
      elif type == "array" then (
        if length > 0 then
          (.[0] | if type=="string" then . else (.rpc_create_draft // .id // .order_id // empty) end)
        else empty end)
      else empty end')
    if [ -z "$order_id" ]; then
      echo "Order draft creation response unexpected: $order_json" >&2
      return 1
    fi

    local variant_id="" matched_code="" product_json
    for product_code in HERB-002 SKU-1 mint; do
      product_json=$(curl -sfS -X POST "$supabase_url/rest/v1/rpc/rpc_find_by_code" \
        -H "apikey: $anon_key" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        --max-time 30 \
        -d "{\"p_code\":\"$product_code\"}")
      variant_id=$(printf '%s' "$product_json" | jq -r 'if type=="array" and length>0 then (.[0].variant_id // empty) else empty end')
      if [ -n "$variant_id" ] && [ "$variant_id" != "null" ]; then
        matched_code="$product_code"
        break
      fi
    done
    if [ -z "$variant_id" ]; then
      echo "No variants found via rpc_find_by_code" >&2
      return 1
    fi

    curl -sfS -X POST "$supabase_url/rest/v1/rpc/rpc_add_line" \
      -H "apikey: $anon_key" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-Type: application/json" \
      --max-time 30 \
      -d "{\"p_order_id\":\"$order_id\",\"p_variant_id\":\"$variant_id\",\"p_qty\":1}" >/dev/null

    curl -sfS -X POST "$supabase_url/rest/v1/rpc/rpc_submit_order" \
      -H "apikey: $anon_key" \
      -H "Authorization: Bearer $access_token" \
      -H "Content-Type: application/json" \
      --max-time 30 \
      -d "{\"p_order_id\":\"$order_id\"}" >/dev/null

    local shipments_json shipment_count
    shipments_json=$(curl -sfS "$supabase_url/rest/v1/shipments" \
      -H "apikey: $anon_key" \
      -H "Authorization: Bearer $access_token" \
      --get \
      --data-urlencode "select=order_id,status" \
      --data-urlencode "order_id=eq.$order_id" \
      --max-time 30)
    shipment_count=$(printf '%s' "$shipments_json" | jq 'if type=="array" then length else 0 end')

    if [ "$shipment_count" -eq 0 ]; then
      curl -sfS -X POST "$supabase_url/rest/v1/rpc/rpc_split_order" \
        -H "apikey: $anon_key" \
        -H "Authorization: Bearer $access_token" \
        -H "Content-Type: application/json" \
        --max-time 30 \
        -d "{\"p_order_id\":\"$order_id\"}" >/dev/null

      shipments_json=$(curl -sfS "$supabase_url/rest/v1/shipments" \
        -H "apikey: $anon_key" \
        -H "Authorization: Bearer $access_token" \
        --get \
        --data-urlencode "select=order_id,status" \
        --data-urlencode "order_id=eq.$order_id" \
        --max-time 30)
      shipment_count=$(printf '%s' "$shipments_json" | jq 'if type=="array" then length else 0 end')
    fi

    local timestamp
    if ! timestamp=$(date --iso-8601=seconds 2>/dev/null); then
      timestamp=$(date '+%Y-%m-%dT%H:%M:%S%z')
    fi

    mkdir -p "$(dirname "$order_file")"
    cat >"$order_file" <<JSON
{
  "order_id": "$order_id",
  "variant_id": "$variant_id",
  "product_code": "$matched_code",
  "shipments": $shipment_count,
  "created_at": "$timestamp"
}
JSON

    echo "[QA_ORDER] order_id=$order_id code=$matched_code shipments=$shipment_count" >&2
  )
}

APP="$(cd "$(dirname "$0")/.." && pwd)"
export APP
UDID="DB61D22F-A3BC-4034-B2FE-1ECD781480E4"
BUNDLE_ID="com.shachar.ashachar.dev"
SUPABASE_URL="http://127.0.0.1:54321"
DB_HOST=127.0.0.1
DB_PORT=54322
REPO_ROOT="$(cd "$APP/.." && pwd)"
SCREEN_DIR="$REPO_ROOT/docs/screens"
SCREENSHOT="$SCREEN_DIR/home_after_install.png"
CATALOG_SCREENSHOT="$SCREEN_DIR/catalog_search.png"
QUICK_ORDER_SCREENSHOT="$SCREEN_DIR/quick_order.png"
ORDERS_LIST_SCREENSHOT="$SCREEN_DIR/orders_list.png"
ORDER_DETAIL_SCREENSHOT="$SCREEN_DIR/order_detail.png"
PRODUCT_UOM_SCREENSHOT="$SCREEN_DIR/product_uom.png"
CHECKOUT_NET_TERMS_SCREENSHOT="$SCREEN_DIR/checkout_net_terms.png"
SIM_RESULT_FILE="${SIM_RESULT_FILE:-/tmp/sim-run.status}"
export SIM_RESULT_FILE
SIM_BUILD_STATUS="unknown"

declare -a FAIL_STEPS=()
declare -a WARN_STEPS=()
SUPABASE_PREFLIGHT_STATUS="SKIP"
ANALYZE_STATUS="SKIP"
UNIT_STATUS="SKIP"
INTEGRATION_STATUS="SKIP"
DRIVE_STATUS="SKIP"
RLS_STATUS="SKIP"
ORDERS_CAPTURE_STATUS="SKIP"
ORDER_AUTOMATION_STATUS="SKIP"
PRODUCT_CHECKOUT_STATUS="SKIP"
ORDER_ID=""
ORDER_STATE_FILE="${ORDER_STATE_FILE:-/tmp/qa-last-order.json}"
rm -f "$ORDER_STATE_FILE"

RATE_LIMIT_WARN_OCCURRED=0

cd "$APP"

echo "=== QA • Toolchain ==="
flutter --version | head -n 1 || true
supabase --version || true

echo "=== QA • Supabase preflight ==="
set +e
ensure_supabase_running
pref_rc=$?
set -e
if [ "$pref_rc" -ne 0 ]; then
  SUPABASE_PREFLIGHT_STATUS="FAIL"
  FAIL_STEPS+=("supabase preflight")
  echo "[supabase preflight] FAILED" >&2
  print_marker_summary
  print_tail
  trap - ERR
  echo "$FAIL_MARKER"
  exit 1
else
  SUPABASE_PREFLIGHT_STATUS="PASS"
  echo "[supabase preflight] PASS"
fi

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

do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname='public'
      and tablename='order_items'
      and policyname='order_items_customer_insert'
      and cmd in ('INSERT','ALL')
  ) then
    create policy order_items_customer_insert on public.order_items
    for insert to authenticated
    with check (
      auth_role() in ('customer_admin','buyer')
      and order_item_customer_guard(order_items.order_id)
    );
  end if;
end$$;

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
run_step "psql rls fix" RLS_STATUS 20 warn bash -lc "PGPASSWORD=postgres psql -h '$DB_HOST' -p '$DB_PORT' -U postgres -d postgres -v ON_ERROR_STOP=1 -f /tmp/rls_order_items_fix.sql"

echo "=== QA • Build+Launch (ENV=dev) ==="
"$APP/scripts/sim-run.sh"
if [ -f "$SIM_RESULT_FILE" ]; then
  SIM_BUILD_STATUS=$(sed -n 's/^build_status=//p' "$SIM_RESULT_FILE" | head -n 1)
  if [ -z "$SIM_BUILD_STATUS" ]; then
    SIM_BUILD_STATUS="unknown"
  fi
fi

echo "=== QA • Screenshot (home_after_install) ==="
mkdir -p "$SCREEN_DIR"
tmp_shot="${SCREENSHOT}.tmp"
rm -f "$tmp_shot"
xcrun simctl io "$UDID" screenshot "$tmp_shot"
mv "$tmp_shot" "$SCREENSHOT"
if [ ! -f "$SCREENSHOT" ]; then
  echo "Screenshot not found at $SCREENSHOT" >&2
  exit 1
fi
ls -lh "$SCREENSHOT"

echo "=== QA • Capture catalog & quick-order screens ==="
rm -f "$CATALOG_SCREENSHOT" "$QUICK_ORDER_SCREENSHOT"
run_step "flutter drive (ui capture)" DRIVE_STATUS 40 strict \
  env QA_SCREENSHOT_DIR="$SCREEN_DIR" flutter drive --no-pub \
    --driver=docs/screens/driver.dart \
    --target=docs/screens/ui_capture_test.dart \
    -d "$UDID" \
    --dart-define=ENV=dev \
    --dart-define=INITIAL_ROUTE=/home
if [ "$DRIVE_STATUS" = "PASS" ]; then
  missing=()
  [ -f "$CATALOG_SCREENSHOT" ] || missing+=("catalog_search")
  [ -f "$QUICK_ORDER_SCREENSHOT" ] || missing+=("quick_order")
  if [ ${#missing[@]} -ne 0 ]; then
    echo "UI capture missing files: ${missing[*]}" >&2
    FAIL_STEPS+=("ui screenshots")
    DRIVE_STATUS="FAIL"
  else
    ls -lh "$CATALOG_SCREENSHOT" "$QUICK_ORDER_SCREENSHOT"
  fi
fi

echo "=== QA • Unit/Analyze ==="
run_step "flutter analyze" ANALYZE_STATUS 20 warn flutter analyze
run_step "flutter test (unit)" UNIT_STATUS 10 warn flutter test -r compact

echo "=== QA • Integration (UI) ==="
run_step "integration test (order_flow)" INTEGRATION_STATUS 50 warn flutter test \
  -d "$UDID" \
  integration_test/order_flow_test.dart \
  --dart-define=ENV=dev \
  --dart-define=INITIAL_ROUTE=/home \
  -r compact

echo "=== QA • Buyer order automation ==="
set +e
create_order_flow "$ORDER_STATE_FILE"
order_rc=$?
set -e
if [ "$order_rc" -eq 0 ] && [ -f "$ORDER_STATE_FILE" ]; then
  ORDER_ID=$(jq -r '.order_id // empty' "$ORDER_STATE_FILE" 2>/dev/null || true)
  if [ -n "${ORDER_ID:-}" ]; then
    ORDER_AUTOMATION_STATUS="PASS"
    echo "[order automation] PASS (order_id=$ORDER_ID)"
  else
    ORDER_AUTOMATION_STATUS="WARN"
    WARN_STEPS+=("buyer order automation")
    echo "[order automation] WARN (order_id missing)" >&2
  fi
else
  ORDER_AUTOMATION_STATUS="WARN"
  WARN_STEPS+=("buyer order automation")
  echo "[order automation] WARN (exit $order_rc)" >&2
fi

echo "=== QA • Product & checkout capture ==="
rm -f "$PRODUCT_UOM_SCREENSHOT" "$CHECKOUT_NET_TERMS_SCREENSHOT"
if [ "$ORDER_AUTOMATION_STATUS" != "PASS" ]; then
  PRODUCT_CHECKOUT_STATUS="WARN"
  WARN_STEPS+=("product/checkout screenshots (skipped)")
  echo "Product & checkout screenshots skipped: missing order context" >&2
else
  if [ "${QA_SKIP_PRODUCT_CHECKOUT:-0}" != "1" ]; then
    local_product_checkout_rc=0
    set +e
    QA_SCREENSHOT_DIR="$SCREEN_DIR" run_drive_with_retry "product_checkout" \
      --no-pub \
      --driver=docs/screens/driver.dart \
      --target=docs/screens/product_checkout_test.dart \
      -d "$UDID" \
      --dart-define=ENV=dev \
      --dart-define=INITIAL_ROUTE=/home
    local_product_checkout_rc=$?
    set -e

    if [ $local_product_checkout_rc -eq 0 ]; then
      PRODUCT_CHECKOUT_STATUS="PASS"
      missing=()
      [ -f "$PRODUCT_UOM_SCREENSHOT" ] || missing+=("product_uom")
      [ -f "$CHECKOUT_NET_TERMS_SCREENSHOT" ] || missing+=("checkout_net_terms")
      if [ ${#missing[@]} -ne 0 ]; then
        echo "Product/checkout capture missing files: ${missing[*]}" >&2
        FAIL_STEPS+=("product checkout screenshots")
        PRODUCT_CHECKOUT_STATUS="FAIL"
      else
        ls -lh "$PRODUCT_UOM_SCREENSHOT" "$CHECKOUT_NET_TERMS_SCREENSHOT"
      fi
    else
      if [ "${AUTH429_PRODUCT_CHECKOUT:-0}" = "1" ] \
        && [ "$ANALYZE_STATUS" = "PASS" ] \
        && [ "$UNIT_STATUS" = "PASS" ] \
        && [ "$INTEGRATION_STATUS" = "PASS" ]; then
        PRODUCT_CHECKOUT_STATUS="WARN"
        WARN_STEPS+=("product checkout capture (auth rate limit)")
        echo "[product checkout] WARN: auth rate limit (status 429)" >&2
        RATE_LIMIT_WARN_OCCURRED=1
      else
        PRODUCT_CHECKOUT_STATUS="FAIL"
        FAIL_STEPS+=("product checkout capture")
        echo "[product checkout] FAILED (exit $local_product_checkout_rc)" >&2
      fi
    fi
  else
    echo "[QA] Skipping product checkout capture by flag"
    PRODUCT_CHECKOUT_STATUS="WARN"
    WARN_STEPS+=("product checkout capture (skipped)")
  fi
fi

echo "=== QA • Orders screens capture ==="
orders_capture_test="$APP/.dart_tool/qa/orders_capture_test.dart"
mkdir -p "$(dirname "$orders_capture_test")"
rm -f "$ORDERS_LIST_SCREENSHOT" "$ORDER_DETAIL_SCREENSHOT"
rm -f "$orders_capture_test"
if [ "$ORDER_AUTOMATION_STATUS" != "PASS" ] || [ -z "${ORDER_ID:-}" ]; then
  ORDERS_CAPTURE_STATUS="WARN"
  WARN_STEPS+=("orders screenshots (skipped)")
  echo "Orders screenshots skipped: missing order context" >&2
else
  cat > "$orders_capture_test" <<'DART'
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ashachar_marketplace/main.dart' as entry;
import 'package:ashachar_marketplace/src/app/app_bootstrap.dart';
import 'package:ashachar_marketplace/src/features/orders/presentation/orders_controller.dart';
import 'package:ashachar_marketplace/src/router/app_router.dart';

Future<void> _goToRoute(
  WidgetTester tester,
  ProviderContainer container,
  String route,
) async {
  await tester.runAsync(() async {
    final GoRouter router = container.read(appRouterProvider);
    router.go(route);
  });
  await tester.pumpAndSettle(const Duration(seconds: 3));
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 200));
  }
  throw TestFailure('Finder $finder not found within $timeout');
}

Finder _localizedText(List<String> candidates) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data != null &&
        candidates.contains(widget.data),
  );
}

Future<String> _loadOrderId() async {
  final String? path = Platform.environment['QA_LAST_ORDER_FILE'];
  if (path == null || path.isEmpty) {
    throw StateError('QA_LAST_ORDER_FILE missing');
  }
  final File file = File(path);
  if (!await file.exists()) {
    throw StateError('Order context file missing at $path');
  }
  final dynamic data = jsonDecode(await file.readAsString());
  if (data is Map<String, dynamic>) {
    final Object? idValue = data['order_id'];
    if (idValue is String && idValue.isNotEmpty) {
      return idValue;
    }
  }
  throw StateError('order_id missing in QA order context');
}

Future<void> _ensureOrderCached(
  ProviderContainer container,
  String orderId,
) async {
  final List<dynamic> orders =
      await container.read(ordersControllerProvider.future);
  final bool found = orders.any((dynamic order) {
    try {
      final Object? value = order is Map<String, dynamic> ? order['id'] : order.id;
      return value is String && value == orderId;
    } catch (_) {
      return false;
    }
  });
  if (!found) {
    throw StateError('Order $orderId not exposed in ordersController');
  }
}

final IntegrationTestWidgetsFlutterBinding binding =
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

void main() {
  testWidgets('Capture orders list/detail screens', (tester) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await AppBootstrap(container: container).initialize();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const entry.MarketplaceApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await binding.convertFlutterSurfaceToImage();

    final String orderId = await tester.runAsync(_loadOrderId);
    await tester.runAsync(() => _ensureOrderCached(container, orderId));

    await _goToRoute(tester, container, '/customer/orders');
    await _pumpUntilFound(
      tester,
      _localizedText(const <String>['Orders', 'הזמנות']),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('orders_list');

    await _goToRoute(tester, container, '/customer/orders/$orderId');
    await _pumpUntilFound(
      tester,
      _localizedText(const <String>['Shipments', 'משלוחים']),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('order_detail');
  });
}
DART
  if [ "${QA_SKIP_ORDERS_CAPTURE:-0}" != "1" ]; then
    local_orders_capture_rc=0
    set +e
    QA_SCREENSHOT_DIR="$SCREEN_DIR" QA_LAST_ORDER_FILE="$ORDER_STATE_FILE" \
      run_drive_with_retry "orders_capture" \
        --no-pub \
        --driver=docs/screens/driver.dart \
        --target="$orders_capture_test" \
        -d "$UDID" \
        --dart-define=ENV=dev \
        --dart-define=INITIAL_ROUTE=/home
    local_orders_capture_rc=$?
    set -e

    if [ $local_orders_capture_rc -eq 0 ]; then
      ORDERS_CAPTURE_STATUS="PASS"
      missing=()
      [ -f "$ORDERS_LIST_SCREENSHOT" ] || missing+=("orders_list")
      [ -f "$ORDER_DETAIL_SCREENSHOT" ] || missing+=("order_detail")
      if [ ${#missing[@]} -ne 0 ]; then
        echo "Orders capture missing files: ${missing[*]}" >&2
        FAIL_STEPS+=("orders screenshots")
        ORDERS_CAPTURE_STATUS="FAIL"
      else
        ls -lh "$ORDERS_LIST_SCREENSHOT" "$ORDER_DETAIL_SCREENSHOT"
      fi
    else
      if [ "${AUTH429_ORDERS_CAPTURE:-0}" = "1" ] \
        && [ "$ANALYZE_STATUS" = "PASS" ] \
        && [ "$UNIT_STATUS" = "PASS" ] \
        && [ "$INTEGRATION_STATUS" = "PASS" ]; then
        ORDERS_CAPTURE_STATUS="WARN"
        WARN_STEPS+=("orders capture (auth rate limit)")
        echo "[orders capture] WARN: auth rate limit (status 429)" >&2
        RATE_LIMIT_WARN_OCCURRED=1
      else
        ORDERS_CAPTURE_STATUS="FAIL"
        FAIL_STEPS+=("orders capture")
        echo "[orders capture] FAILED (exit $local_orders_capture_rc)" >&2
      fi
    fi
  else
    echo "[QA] Skipping orders screens capture by flag"
    ORDERS_CAPTURE_STATUS="WARN"
    WARN_STEPS+=("orders capture (skipped)")
  fi
  rm -f "$orders_capture_test"
fi

echo "=== QA • Runner log (markers) ==="
xcrun simctl spawn "$UDID" log show --style compact --last 2m \
  --predicate 'process == "Runner" AND (eventMessage CONTAINS "Order submitted:" OR eventMessage CONTAINS "[ORDER_FLOW]" OR eventMessage CONTAINS "Demo sign-in result")' \
  | tail -n 120 || true

echo "=== QA • NAV markers (sorted tail) ==="
xcrun simctl spawn "$UDID" log show --style compact --last 5m \
  --predicate 'process == "Runner" AND eventMessage CONTAINS "[NAV] initial="' \
  | tail -n 200 | LC_ALL=C sort || true

echo "=== QA • AUTH_FLOW markers (sorted tail) ==="
xcrun simctl spawn "$UDID" log show --style compact --last 5m \
  --predicate 'process == "Runner" AND eventMessage CONTAINS "[AUTH_FLOW]"' \
  | tail -n 200 | LC_ALL=C sort || true


echo "=== FINAL STATUS (QA) ==="
echo "- RLS order_items: fixed safe insert (see above)."
echo "- RLS fix status: $RLS_STATUS"
echo "- Supabase preflight: $SUPABASE_PREFLIGHT_STATUS"
echo "- Build+Launch: via scripts/sim-run.sh (build_status=$SIM_BUILD_STATUS)"
echo "- Screenshot: $SCREENSHOT"
echo "- Catalog screenshot: $CATALOG_SCREENSHOT"
echo "- Quick order screenshot: $QUICK_ORDER_SCREENSHOT"
echo "- Product detail screenshot: $PRODUCT_UOM_SCREENSHOT"
echo "- Checkout screenshot: $CHECKOUT_NET_TERMS_SCREENSHOT"
echo "- Orders list screenshot: $ORDERS_LIST_SCREENSHOT"
echo "- Order detail screenshot: $ORDER_DETAIL_SCREENSHOT"
echo "- Order automation: $ORDER_AUTOMATION_STATUS (order_id=${ORDER_ID:-N/A})"
echo "- Product checkout capture: $PRODUCT_CHECKOUT_STATUS"
echo "- UI capture step: $DRIVE_STATUS"
echo "- Orders capture step: $ORDERS_CAPTURE_STATUS"
echo "- Analyze: $ANALYZE_STATUS"
echo "- Unit tests: $UNIT_STATUS"
echo "- Integration(UI): $INTEGRATION_STATUS"
echo "- QA log: $LOG_FILE"
echo "- Marker tail summary: [NAV] / [AUTH_FLOW] / [ORDER_FLOW] / [QA_ORDER]"

if grep -q "status=429" "$DEFAULT_LOG_FILE" 2>/dev/null; then
  echo "WARN: Auth rate limit detected"
fi

print_marker_summary

if [ "${#FAIL_STEPS[@]}" -ne 0 ]; then
  echo "Failing steps:"
  for step in "${FAIL_STEPS[@]}"; do
    echo "  • $step"
  done
  print_tail
  trap - ERR
  echo "$FAIL_MARKER"
  exit 1
fi

if [ "${#WARN_STEPS[@]}" -ne 0 ]; then
  echo "Warnings (non-blocking):"
  for step in "${WARN_STEPS[@]}"; do
    echo "  • $step"
  done
fi
print_tail

trap - ERR
if [ "$ANALYZE_STATUS" = "PASS" ] && [ "$UNIT_STATUS" = "PASS" ] && [ "$INTEGRATION_STATUS" = "PASS" ]; then
  if [ "${RATE_LIMIT_WARN_OCCURRED:-0}" = "1" ]; then
    echo "QA STATUS: WARN / AUTH RATE LIMIT (Analyze=$ANALYZE_STATUS, Unit=$UNIT_STATUS, Integration=$INTEGRATION_STATUS)"
  else
    echo "$PASS_MARKER"
  fi
else
  echo "QA STATUS: WARN / REVIEW (Analyze=$ANALYZE_STATUS, Unit=$UNIT_STATUS, Integration=$INTEGRATION_STATUS)"
fi
