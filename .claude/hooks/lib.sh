# フック共通: 現在の実装ステップと記録先フォルダを決める（source して使う）
history_root="$CLAUDE_PROJECT_DIR/history"

# history/.current-step のステップ名（英数字・-・_ のみ）。無ければ general
current_step() {
  local s=""
  [ -f "$history_root/.current-step" ] && s=$(tr -cd 'A-Za-z0-9_-' < "$history_root/.current-step")
  echo "${s:-general}"
}

# history/<step>/ を作って返す
step_dir() {
  local d="$history_root/$(current_step)"
  mkdir -p "$d"
  echo "$d"
}

# actions.md が無ければ見出しと表のヘッダーを書く
ensure_actions_file() {
  [ -f "$1" ] || printf '# 動作履歴: %s\n\n| 時刻 | ツール | 対象 | 結果 |\n|---|---|---|---|\n' "$(current_step)" > "$1"
}
