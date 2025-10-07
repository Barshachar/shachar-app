#!/usr/bin/env bash
set -euo pipefail

ts="$(date +%F_%H%M%S)"
root="$(pwd)"
art_dir=".artifacts"
art_path="${root}/${art_dir}"
mkdir -p "$art_path"
report_path="$art_path/codex_inventory_${ts}.md"

echo "# Codex Inventory (multi-app) ${ts}" > "$report_path"

# --- discover Flutter packages (monorepo-friendly) ---
PKGS=()
while IFS= read -r pkg; do
  if [ -n "$pkg" ]; then
    PKGS+=("$pkg")
  fi
done < <(
  find "$root" -type f -name pubspec.yaml -not -path "*/build/*" \
    -exec awk 'f||/name:/{print FILENAME; f=1; exit}' {} \; \
    | xargs -I{} sh -c "grep -q 'sdk:[[:space:]]*flutter' '{}' && dirname '{}' || true"
)

if [ ${#PKGS[@]} -eq 0 ]; then
  {
    echo "No Flutter packages found under: $root"
    echo "Tip: cd to the actual Flutter workspace root (directory containing pubspec.yaml)"
  } | tee -a "$report_path"
  exit 0
fi

# --- top-level git info (if repo) ---
{
  echo "## Repo"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "- branch: $(git rev-parse --abbrev-ref HEAD)"
    echo "- commit: $(git rev-parse --short HEAD)"
  else
    echo "- branch: unknown (no .git here)"
    echo "- commit: unknown"
  fi
  echo
} >> "$report_path"

# iterate packages
for pkg in "${PKGS[@]}"; do
  appname="$(basename "$pkg")"
  pfx="$art_path/${appname}"
  mkdir -p "$pfx"

  {
    echo "### App: ${appname}  (path: ${pkg})"
    echo "- flutter sdk: $(command -v flutter || echo 'not found')"
  } >> "$report_path"

  pushd "$pkg" >/dev/null

  # flutter pub get (best effort)
  echo "## ${appname} :: flutter pub get" | tee "$pfx/pub_get.log"
  (flutter pub get || true) 2>&1 | tee -a "$pfx/pub_get.log"

  # analyze
  echo "## ${appname} :: flutter analyze" | tee "$pfx/analyze.log"
  (flutter analyze || true) 2>&1 | tee -a "$pfx/analyze.log"

  # tests (expanded + compact) if test/ exists
  if [ -d "test" ]; then
    echo "## ${appname} :: flutter test (expanded)" | tee "$pfx/test_expanded.log"
    (flutter test -r expanded || true) 2>&1 | tee -a "$pfx/test_expanded.log"

    echo "## ${appname} :: flutter test (compact)" | tee "$pfx/test_compact.log"
    (flutter test -r compact || true) 2>&1 | tee -a "$pfx/test_compact.log"
  else
    echo "## ${appname} :: no test/ directory" | tee "$pfx/test_expanded.log"
  fi

  # keys defined in lib/
  : > "$pfx/keys_defined.txt"
  if [ -d "lib" ]; then
    grep -RIn --include='*.dart' -E "Key\(['\"][a-zA-Z0-9_{}\.-]+" lib \
      | sed -E "s/.*Key\(['\"]([^'\"\)]+).*/\1/" \
      | sort -u >> "$pfx/keys_defined.txt" || true
    grep -RIn --include='*.dart' -E "ValueKey\(['\"][a-zA-Z0-9_{}\.-]+" lib \
      | sed -E "s/.*ValueKey\(['\"]([^'\"\)]+).*/\1/" \
      | sort -u >> "$pfx/keys_defined.txt" || true
    sort -u "$pfx/keys_defined.txt" -o "$pfx/keys_defined.txt"
  fi

  # keys referenced in tests/
  : > "$pfx/keys_in_tests.txt"
  if [ -d "test" ]; then
    grep -RIn --include='*.dart' -E "['\"][a-zA-Z0-9_{}]+['\"]" test \
      | sed -E "s/.*['\"]([a-zA-Z0-9_{}]+)['\"].*/\1/" \
      | grep -E "saved_list_|reorder_|promotions_|open_debts_|invoice|rfq_|contract_|warehouse_|shipping_|asn_|pod_|rma_|dispute_|chat_|notif_|admin_" \
      | sort -u > "$pfx/keys_in_tests.txt" || true
  fi

  comm -23 "$pfx/keys_defined.txt" "$pfx/keys_in_tests.txt" > "$pfx/keys_defined_not_tested.txt" || true
  comm -13 "$pfx/keys_defined.txt" "$pfx/keys_in_tests.txt" > "$pfx/keys_tested_not_defined.txt" || true

  # l10n parity (he/en)
  : > "$pfx/l10n_en_only.txt"; : > "$pfx/l10n_he_only.txt"
  if [ -f "assets/translations/en.arb" ] && [ -f "assets/translations/he.arb" ]; then
    if command -v jq >/dev/null 2>&1; then
      jq -r 'keys[]' assets/translations/en.arb | sort -u > "$pfx/en_keys.txt"
      jq -r 'keys[]' assets/translations/he.arb | sort -u > "$pfx/he_keys.txt"
    else
      sed -nE 's/^[[:space:]]*"([^"]+)":.*/\1/p' assets/translations/en.arb | sort -u > "$pfx/en_keys.txt" || true
      sed -nE 's/^[[:space:]]*"([^"]+)":.*/\1/p' assets/translations/he.arb | sort -u > "$pfx/he_keys.txt" || true
    fi
    comm -23 "$pfx/en_keys.txt" "$pfx/he_keys.txt" > "$pfx/l10n_en_only.txt" || true
    comm -13 "$pfx/en_keys.txt" "$pfx/he_keys.txt" > "$pfx/l10n_he_only.txt" || true
  fi

  # append summary to main report
  {
    echo
    echo "### ${appname} — Summary"
    echo "- keys defined: $(wc -l < "$pfx/keys_defined.txt" 2>/dev/null || echo 0)"
    echo "- keys in tests: $(wc -l < "$pfx/keys_in_tests.txt" 2>/dev/null || echo 0)"
    echo "- keys defined !tested: $(wc -l < "$pfx/keys_defined_not_tested.txt" 2>/dev/null || echo 0)"
    echo "- keys tested !defined: $(wc -l < "$pfx/keys_tested_not_defined.txt" 2>/dev/null || echo 0)"
    if [ -f "$pfx/en_keys.txt" ] && [ -f "$pfx/he_keys.txt" ]; then
      echo "- l10n en-only: $(wc -l < "$pfx/l10n_en_only.txt" 2>/dev/null || echo 0)"
      echo "- l10n he-only: $(wc -l < "$pfx/l10n_he_only.txt" 2>/dev/null || echo 0)"
    else
      echo "- l10n: translations not found"
    fi
  } >> "$report_path"

  popd >/dev/null
done

echo
echo "Inventory complete. See: $report_path"
ls -1 "$art_path" | sed 's/^/- /'
