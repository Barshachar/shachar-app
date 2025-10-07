#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$REPO_ROOT"
if [[ ! -f "${APP_DIR}/pubspec.yaml" && -f "${REPO_ROOT}/app/pubspec.yaml" ]]; then
  APP_DIR="${REPO_ROOT}/app"
fi

ARTIFACT_DIR="${REPO_ROOT}/.artifacts"
mkdir -p "${ARTIFACT_DIR}"

ts="$(date +%F_%H%M%S)"
out="${ARTIFACT_DIR}/codex_inventory_${ts}.md"

have_git=false
if [[ -d "${REPO_ROOT}/.git" ]]; then
  have_git=true
fi

{
  echo "# Codex Inventory (${ts})"
  echo
  echo "## Repo"
  if ${have_git}; then
    echo "- branch: $(cd "${REPO_ROOT}" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
    echo "- commit: $(cd "${REPO_ROOT}" && git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
  else
    echo "- branch: unknown (no git metadata)"
    echo "- commit: unknown (no git metadata)"
  fi
  echo
  echo "## Diff vs origin/main (name-status)"
  if ${have_git}; then
    (cd "${REPO_ROOT}" && git fetch --quiet) || true
    (cd "${REPO_ROOT}" && git diff --name-status origin/main...HEAD) || true
  else
    echo "(skipped: git metadata unavailable)"
  fi
  echo
  echo "## Last 20 commits (compact)"
  if ${have_git}; then
    (cd "${REPO_ROOT}" && git log --oneline -n 20) || true
  else
    echo "(skipped: git metadata unavailable)"
  fi
  echo
  echo "## flutter analyze"
  (cd "${APP_DIR}" && flutter analyze) 2>&1 || true
  echo
  echo "## Tests (expanded: Saved Lists / Reorder)"
  (cd "${APP_DIR}" && flutter test -r expanded test/lists/saved_lists_states_test.dart) 2>&1 || true
  (cd "${APP_DIR}" && flutter test -r expanded test/orders/reorder_states_test.dart) 2>&1 || true
  echo
  echo "## Tests (selectors smoke)"
  (cd "${APP_DIR}" && flutter test test/qa/selector_keys_smoke_test.dart) 2>&1 || true
  echo
  echo "## Tests (compact)"
  (cd "${APP_DIR}" && flutter test -r compact) 2>&1 || true
} > "${out}"

lib_dir="${APP_DIR}/lib"
test_dir="${APP_DIR}/test"

# --- Keys inventory (lib) ---
keys_defined="${ARTIFACT_DIR}/codex_keys_defined.txt"
if [[ -d "${lib_dir}" ]]; then
  grep -RIn --include='*.dart' -E "Key\(['\"][a-zA-Z0-9_{}\.-]+" "${lib_dir}" \
    | sed -E "s/.*Key\(['\"]([^'\"\)]+).*/\1/" \
    | sort -u > "${keys_defined}" || true
  grep -RIn --include='*.dart' -E "ValueKey\(['\"][a-zA-Z0-9_{}\.-]+" "${lib_dir}" \
    | sed -E "s/.*ValueKey\(['\"]([^'\"\)]+).*/\1/" \
    | sort -u >> "${keys_defined}" || true
else
  : > "${keys_defined}"
fi
sort -u "${keys_defined}" -o "${keys_defined}"

# --- Keys referenced in tests ---
keys_in_tests="${ARTIFACT_DIR}/codex_keys_in_tests.txt"
if [[ -d "${test_dir}" ]]; then
  grep -RIn --include='*.dart' -E "['\"][a-zA-Z0-9_{}]+['\"]" "${test_dir}" \
    | sed -E "s/.*['\"]([a-zA-Z0-9_{}]+)['\"].*/\1/" \
    | grep -E "saved_list_|reorder_|promotions_|open_debts_|invoice|rfq_|contract_|warehouse_|shipping_|asn_|pod_|rma_|dispute_|chat_|notif_|admin_" \
    | sort -u > "${keys_in_tests}" || true
else
  : > "${keys_in_tests}"
fi

keys_defined_not_tested="${ARTIFACT_DIR}/codex_keys_defined_not_tested.txt"
keys_tested_not_defined="${ARTIFACT_DIR}/codex_keys_tested_not_defined.txt"

comm -23 "${keys_defined}" "${keys_in_tests}" > "${keys_defined_not_tested}" || true
comm -13 "${keys_defined}" "${keys_in_tests}" > "${keys_tested_not_defined}" || true

# --- l10n parity (he/en) ---
en_arb="${APP_DIR}/assets/translations/en.arb"
he_arb="${APP_DIR}/assets/translations/he.arb"
en_keys="${ARTIFACT_DIR}/codex_en_keys.txt"
he_keys="${ARTIFACT_DIR}/codex_he_keys.txt"
if command -v jq >/dev/null 2>&1 && [[ -f "${en_arb}" && -f "${he_arb}" ]]; then
  jq -r 'keys[]' "${en_arb}" | sort -u > "${en_keys}" || true
  jq -r 'keys[]' "${he_arb}" | sort -u > "${he_keys}" || true
else
  if [[ -f "${en_arb}" ]]; then
    sed -nE 's/^[[:space:]]*"([^"]+)":.*/\1/p' "${en_arb}" | sort -u > "${en_keys}" || true
  else
    : > "${en_keys}"
  fi
  if [[ -f "${he_arb}" ]]; then
    sed -nE 's/^[[:space:]]*"([^"]+)":.*/\1/p' "${he_arb}" | sort -u > "${he_keys}" || true
  else
    : > "${he_keys}"
  fi
fi

l10n_en_only="${ARTIFACT_DIR}/codex_l10n_en_only.txt"
l10n_he_only="${ARTIFACT_DIR}/codex_l10n_he_only.txt"

comm -23 "${en_keys}" "${he_keys}" > "${l10n_en_only}" || true
comm -13 "${en_keys}" "${he_keys}" > "${l10n_he_only}" || true

# --- Summaries appended to report ---
{
  echo
  echo "## Keys summary"
  echo "- defined (lib): $(wc -l < "${keys_defined}" 2>/dev/null || echo 0)"
  echo "- in tests:       $(wc -l < "${keys_in_tests}" 2>/dev/null || echo 0)"
  echo "- defined !tested: $(wc -l < "${keys_defined_not_tested}" 2>/dev/null || echo 0)"
  echo "- tested !defined: $(wc -l < "${keys_tested_not_defined}" 2>/dev/null || echo 0)"
  echo
  echo "## l10n parity"
  echo "- en only keys: $(wc -l < "${l10n_en_only}" 2>/dev/null || echo 0)"
  echo "- he only keys: $(wc -l < "${l10n_he_only}" 2>/dev/null || echo 0)"
} >> "${out}"

echo "Inventory written to: ${out}"
echo "Artifacts:"
ls -1 "${ARTIFACT_DIR}" | sed 's/^/- /'
