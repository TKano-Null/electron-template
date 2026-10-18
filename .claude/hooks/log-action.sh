#!/bin/bash
# PostToolUse / PostToolUseFailure フック: ツール操作を history/<step>/actions.md に1行で追記する
set -euo pipefail
source "$(dirname "$0")/lib.sh"

file="$(step_dir)/actions.md"
ensure_actions_file "$file"

jq -r --arg root "$CLAUDE_PROJECT_DIR/" --arg time "$(date '+%Y-%m-%d %H:%M:%S')" '
  (.tool_input // {}) as $in
  | (if .tool_name == "Bash" then ($in.command // "")
     elif ($in | type) == "object" and $in.file_path != null then ($in.file_path | ltrimstr($root))
     else ($in | tojson) end) as $target
  # 表が崩れないよう 200 文字で切り、改行・バッククォート・パイプを置き換える
  | ($target | .[0:200] | gsub("[\r\n]+"; " ") | gsub("`"; "'"'"'") | gsub("\\|"; "\\|")) as $t
  | (if .hook_event_name == "PostToolUseFailure" then "失敗" else "成功" end) as $result
  | "| \($time) | \(.tool_name) | `\($t)` | \($result) |"
' >> "$file"
