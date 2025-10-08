#!/usr/bin/env bash
set -euo pipefail
LOG="logs/overnight_batch.log"
echo "=== START $(date) model=gpt-5 approval=full-auto branch=$(git branch --show-current) ===" | tee -a "$LOG"
i=0
while IFS= read -r STEP || [ -n "$STEP" ]; do
i=$((i+1)); [ -z "$STEP" ] && continue
tag=$(printf "%02d" "$i")
echo ">>> STEP $tag: $STEP" | tee -a "$LOG"
yes y | codex exec --approval-mode full-auto --model gpt-5 -- "$STEP" | tee -a "$LOG"
git add -A >/dev/null 2>&1 || true
git commit -m "codex: step $tag" >/dev/null 2>&1 || true
done < .codex_tasks/steps.list
echo "=== END $(date) ===" | tee -a "$LOG"
