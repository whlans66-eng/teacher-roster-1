#!/usr/bin/env sh
# 為這個專案開一個 herdr 工作區，一次把三個 pane 擺好：
#
#   ┌───────────────┬───────────────┐
#   │               │  預覽伺服器   │
#   │  Claude Code  ├───────────────┤
#   │               │     shell     │
#   └───────────────┴───────────────┘
#
# 用法：先執行 `herdr` 進到 herdr 裡，再跑這個腳本（herdr server 要在跑才行）
#   sh herdr-setup/dev-layout.sh [工作區名稱]
#
# 環境變數：PORT 可改預覽埠號（預設 8000）

set -eu

PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
LABEL=${1:-teacher-roster}
PORT=${PORT:-8000}

if ! command -v herdr >/dev/null 2>&1; then
  echo "找不到 herdr 指令，請先確認安裝完成並在 PATH 裡（herdr --version）" >&2
  exit 1
fi

# 從 herdr 的 JSON 回應裡取出巢狀欄位，優先用 jq，沒有就退回 python3
json_get() {
  _json=$1
  shift
  if command -v jq >/dev/null 2>&1; then
    _filter=".result"
    for _key in "$@"; do
      _filter="${_filter}.${_key}"
    done
    printf '%s\n' "$_json" | jq -r "$_filter"
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s\n' "$_json" | PATH_KEYS="$*" python3 -c '
import json, os, sys
node = json.load(sys.stdin)["result"]
for key in os.environ["PATH_KEYS"].split():
    node = node[key]
print(node)
'
  else
    echo "需要 jq 或 python3 來解析 herdr 的 JSON 回應" >&2
    exit 1
  fi
}

# 1. 建立工作區（同時會產生第一個 tab 和 root pane）
created=$(herdr workspace create --cwd "$PROJECT_DIR" --label "$LABEL" --focus)
root_pane=$(json_get "$created" root_pane pane_id)

# 2. 右邊切一個 pane 跑本機預覽伺服器
split=$(herdr pane split "$root_pane" --direction right --ratio 0.4 --cwd "$PROJECT_DIR" --no-focus)
server_pane=$(json_get "$split" pane pane_id)
herdr pane rename "$server_pane" 預覽
herdr pane run "$server_pane" "python3 -m http.server $PORT"

# 3. 預覽 pane 下方再切一個一般 shell（跑 git、curl 之類的雜事）
split_shell=$(herdr pane split "$server_pane" --direction down --ratio 0.5 --cwd "$PROJECT_DIR" --no-focus)
shell_pane=$(json_get "$split_shell" pane pane_id)
herdr pane rename "$shell_pane" shell

# 4. 左邊主 pane 跑 Claude Code
#    agent start 會等 herdr 真的認出 agent，並把它命名成 claude，
#    之後可以直接 `herdr agent prompt claude "..."`。失敗就退回單純執行指令。
herdr pane rename "$root_pane" claude
if ! herdr agent start claude --kind claude --pane "$root_pane" >/dev/null 2>&1; then
  echo "agent start 沒成功（可能沒裝 claude 或啟動較慢），改用一般方式啟動" >&2
  herdr pane run "$root_pane" "claude"
fi

echo
echo "工作區 \"$LABEL\" 已就緒"
echo "  預覽：http://localhost:$PORT/index.html"
echo "  切換 pane：ctrl+b h/j/k/l（或 ctrl+alt+h/j/k/l）"
echo "  離開但不中斷工作：ctrl+b q，之後再執行 herdr 接回來"
