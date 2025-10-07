#!/usr/bin/env bash
set -euo pipefail
REPO="/Users/shachar/new codex 20.9.25"
MASTER="$REPO/.codex_tasks/MASTER_OVERNIGHT.txt"
LOG="$REPO/logs/overnight_master.log"
BR="codex/overnight-$(date +%Y%m%d-%H%M)"
mkdir -p "$REPO/logs"
git -C "$REPO" checkout -b "$BR" >/dev/null 2>&1 || git -C "$REPO" checkout "$BR"
echo "=== START $(date) model=gpt-5 approval=full-auto branch=$BR ===" | tee -a "$LOG"
codex --model gpt-5 --approval full-auto exec --cwd "$REPO" -- "$(cat "$MASTER")" | tee -a "$LOG"
echo "=== END $(date) ===" | tee -a "$LOG"
