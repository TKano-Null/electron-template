#!/bin/bash
# UserPromptSubmit フック: プロンプト原文を history/prompt-history.md に追記し、
# 同じ連番の区切り行を history/<step>/actions.md にも追記する
set -euo pipefail
source "$(dirname "$0")/lib.sh"

file="$history_root/prompt-history.md"
# IDE が自動で付ける <ide_opened_file> 行は除外する
prompt=$(jq -r '.prompt' | sed '/^<ide_opened_file>.*<\/ide_opened_file>$/d')

# 既存エントリ数 + 1 を連番にする
n=$(( $(grep -c '^## #' "$file" || true) + 1 ))

printf '\n---\n\n## #%d（%s）\n\n### プロンプト\n\n~~~~\n%s\n~~~~\n' \
  "$n" "$(date '+%Y-%m-%d %H:%M')" "$prompt" >> "$file"

actions="$(step_dir)/actions.md"
ensure_actions_file "$actions"
printf '| %s | — | **プロンプト #%d** | — |\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$n" >> "$actions"
