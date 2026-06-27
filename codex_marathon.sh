#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/shachar/new codex 20.9.25"
WEB="$ROOT/apps/web_pwa"
LOGDIR="$ROOT/codex"
BR="codex/full-build-$(date +%Y%m%d-%H%M)"
CYCLES="${CYCLES:-20}"                  # כמה סבבים להריץ (אפשר לשנות)
LEGAL_PAGES_E2E="${LEGAL_PAGES_E2E:-0}" # 0=דלג legal-pages; 1=הרץ

mkdir -p "$LOGDIR"

run_eslint_tsc() {
  ( cd "$WEB";
    npx eslint . --ext .ts,.tsx --fix || true
    node -e "try{require.resolve('typescript');process.exit(0)}catch{process.exit(2)}" \
      && npx tsc -p tsconfig.json --noEmit || true
  )
}

run_vitest_and_summary() {
  ( cd "$WEB";
    LEGAL_PAGES_E2E="$LEGAL_PAGES_E2E" npx vitest run | tee "$LOGDIR/vitest_full_test.log" || true
  )
  local DATE; DATE=$(date -u +"%Y-%m-%d %H:%M UTC")
  local PASS_LINE; PASS_LINE=$(tail -n 5 "$LOGDIR/vitest_full_test.log" | sed -n "s/^ Test Files  \(.*\)$/\1/p")
  printf "# Test Summary — %s\n\n## Web PWA (Vitest)\n- %s\n" \
         "$DATE" "${PASS_LINE:-See codex/vitest_full_test.log for details}" \
         > "$LOGDIR/TEST_SUMMARY.md"
}

run_build() {
  ( cd "$WEB"; npm ci || npm install; npm run build || true )
}

git_maybe_commit_push() {
  git add -A || true
  git commit -m "$1" || true
  git checkout -b "$BR" 2>/dev/null || git checkout "$BR" || true
  git push -u origin "$BR" || true
}

codex_apply_once() {
  codex exec --skip-git-repo-check --model gpt-5-codex <<'END'
Act as a Principal Engineer for apps/web_pwa (TypeScript/Next.js). Local-only, no internet/CI.
Every change MUST include Vitest tests.
Priorities:
1) Make /api/quote PDF fully RTL: table columns (index,name,sku,qty,unit,total). Numerics right-aligned. Subtotal/VAT/Total block using integer cents with formatILS. Keep font fallback/pagination.
2) Add a pure helper computeTotals(items, vatRate) with tests (edge cases, rounding).
3) Keep existing tests green; skip legal-pages via LEGAL_PAGES_E2E=0. Do small, safe refactors.
Do the edits now and write/update tests. No questions.
END
}

echo "==> Codex marathon on branch: $BR ; cycles: $CYCLES"
git checkout -b "$BR" 2>/dev/null || git checkout "$BR" || true

i=1
while [ "$i" -le "$CYCLES" ]; do
  echo "---- Iteration $i/$CYCLES: Codex apply ----"
  codex_apply_once

  echo "---- Iteration $i/$CYCLES: Lint/Typecheck ----"
  run_eslint_tsc
  git_maybe_commit_push "chore(web): lint/ts (iter $i)"

  echo "---- Iteration $i/$CYCLES: Vitest + summary ----"
  run_vitest_and_summary
  git_maybe_commit_push "docs: refresh TEST_SUMMARY (iter $i)"

  echo "---- Iteration $i/$CYCLES: Build ----"
  run_build
  git_maybe_commit_push "build(web): ensure next build (iter $i)"

  i=$(( i + 1 ))
done

echo
echo "==> Finished on branch: $BR"
echo "Open PR: https://github.com/Barshachar/shachar-app/compare/main...$BR?expand=1"
echo "Artifacts:"
echo "- $LOGDIR/vitest_full_test.log"
echo "- $LOGDIR/TEST_SUMMARY.md"
