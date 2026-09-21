# herdr 設定說明

[herdr](https://github.com/herdrdev/herdr) 是用 Rust 寫的終端機多工器（可以想成「為 AI coding agent 設計的 tmux」）。
它把終端機放在背景 server 裡，所以關掉視窗、闔上筆電、SSH 斷線，裡面的 agent 都還在跑；
側邊欄會標出每個 pane 是 working / blocked / idle，卡住等你回答的那個一眼就看得到。

這個資料夾放的是可以直接套用的設定：

| 檔案 | 用途 |
|---|---|
| `config.toml` | herdr 主設定檔，已針對中文輸入法和 Claude Code 調過 |
| `dev-layout.sh` | 一鍵為本專案開好工作區（Claude Code + 預覽伺服器 + shell） |

---

## 1. 先確認裝好了

```bash
herdr --version
```

印不出版本就是 PATH 還沒吃到，重開一個終端機再試。

> 注意：herdr 的設定**只有一份，屬於使用者層級**，沒有「每個專案一份」的設定檔。
> 所以下面是把 `config.toml` 放到你的家目錄，不是留在這個 repo 裡讀取。

## 2. 套用設定檔

先看 herdr 在你這台機器實際用哪個路徑（`herdr --help` 的輸出裡有一行 `Config:`）：

```bash
herdr --help
```

預設位置：

| 系統 | 路徑 |
|---|---|
| macOS / Linux | `~/.config/herdr/config.toml` |
| Windows | `%APPDATA%\herdr\config.toml` |

複製過去（macOS / Linux）：

```bash
mkdir -p ~/.config/herdr
cp herdr-setup/config.toml ~/.config/herdr/config.toml
```

Windows（PowerShell）：

```powershell
New-Item -ItemType Directory -Force "$env:APPDATA\herdr" | Out-Null
Copy-Item herdr-setup\config.toml "$env:APPDATA\herdr\config.toml"
```

已經有自己的設定、不想被蓋掉的話，就打開 `config.toml` 挑需要的段落貼進去。
想看所有可用選項和預設值：

```bash
herdr --default-config
```

## 3. 檢查並套用

```bash
herdr config check          # 驗證語法，印出診斷
herdr server reload-config  # 讓正在跑的 server 重新讀設定
```

在 herdr 畫面裡也可以按 `ctrl+b shift+r` 重新載入。

## 4. 啟動

```bash
herdr
```

之後在裡面直接跑 `claude`、`codex` 等等，herdr 會自動認出是哪個 agent。
`ctrl+b q` 離開（agent 繼續跑），再執行 `herdr` 就接回來。

> 不要在 herdr 的 pane 裡再執行 `herdr`，預設不允許巢狀啟動。

---

## 這份設定改了什麼

### 中文輸入法的兩個坑（重點）

1. **`ctrl+b` 被輸入法吃掉。** 設定裡每個常用動作都多綁了一組不需要前綴的
   `ctrl+alt` 快捷鍵當備援，例如切換 pane 除了 `ctrl+b h/j/k/l`，也可以直接按
   `ctrl+alt+h/j/k/l`。另外開了 `switch_ascii_input_source_in_prefix`，前綴模式啟動時
   會自動切到 ASCII 輸入法，結束再切回來 —— **這個選項在 macOS 有效，
   Windows 目前只支援韓文 IME（中文 IME 無效），Linux 無作用。**

2. **候選字視窗位置跑掉。** Claude Code 這類自己繪製游標的 TUI 會讓輸入法找不到錨點。
   設定裡開了 `reveal_hidden_cursor_for_cjk_ime`，並用 `cjk_ime_agents` 限定只對
   claude / codex 生效。
   如果你用 Windows 或 WSL 而候選字視窗還是歪掉，把 `config.toml` 裡
   `host_cursor = "native"` 那行的註解拿掉。

### 其他

- 主題 `catppuccin`，跟著終端機淺色/深色自動切換
- 側邊欄狀態改用符號（`status_indicators = "symbols"`），比彩色圓點好認
- agent 面板改成 blocked 優先排序（`agent_panel_sort = "priority"`）
- 背景 agent 換狀態時發系統通知 + 提示音（走開也知道誰在等你）
- `ctrl+b t` 開浮動臨時終端；有裝 lazygit 可把 `prefix+alt+g` 那段註解拿掉
- server 重啟後自動把 agent pane 接回原本的對話（`resume_agents_on_restore`）

---

## 常用按鍵

前綴鍵是 `ctrl+b`。按 `ctrl+b ?` 會列出目前實際生效的所有按鍵（可用 `/` 過濾）。

| 動作 | 按鍵 |
|---|---|
| 說明 / 所有按鍵 | `ctrl+b ?` |
| 新 tab | `ctrl+b c` |
| 往右切一個 pane | `ctrl+b v` |
| 往下切一個 pane | `ctrl+b -` |
| 在 pane 之間移動 | `ctrl+b h/j/k/l`（或 `ctrl+alt+h/j/k/l`） |
| 放大 / 還原當前 pane | `ctrl+b z` |
| 關閉 pane | `ctrl+b x` |
| 上一個 / 下一個 tab | `ctrl+b p` / `ctrl+b n` |
| 跳到第 1–9 個 tab | `ctrl+b 1`…`9` |
| 工作區選擇器 | `ctrl+b w` |
| 新工作區 | `ctrl+b shift+n` |
| 跳轉選單 | `ctrl+b g` |
| 開關側邊欄 | `ctrl+b b` |
| 複製模式 | `ctrl+b [` |
| 調整大小模式 | `ctrl+b r` |
| 離開（agent 繼續跑） | `ctrl+b q` |
| 重新載入設定 | `ctrl+b shift+r` |

---

## 搭配 Claude Code

### 安裝官方整合

讓 herdr 更準確地判斷 Claude Code 的狀態，並在 server 重啟後接回原本的對話：

```bash
herdr integration install claude
herdr integration status
```

同樣的做法也支援 `codex`、`copilot`、`cursor`、`opencode`、`grok`、`droid`、`devin`、
`kimi`、`qwen` 等；完整清單執行 `herdr integration` 就會列出來。

### 讓 Claude Code 自己操作 herdr

herdr 內建一份 agent skill，裝了之後 Claude Code 就能自己開 pane、啟動另一個 agent、
讀它的輸出、等它卡住：

```bash
mkdir -p ~/.claude/skills/herdr
herdr --skill > ~/.claude/skills/herdr/SKILL.md
```

這個 skill 只在 Claude Code 本身跑在 herdr 的 pane 裡（`HERDR_ENV=1`）才會動作。

---

## 本專案的一鍵佈局

先執行 `herdr` 進到裡面，再跑：

```bash
sh herdr-setup/dev-layout.sh
```

會開一個工作區，擺好三個 pane：

```
┌───────────────┬───────────────┐
│               │  預覽伺服器   │
│  Claude Code  ├───────────────┤
│               │     shell     │
└───────────────┴───────────────┘
```

預覽網址 <http://localhost:8000/index.html>。換埠號用 `PORT=8080 sh herdr-setup/dev-layout.sh`。

> 瀏覽器把 `http://localhost` 當成安全來源，所以在本機開 `asset-management.html`
> 相機掃碼是可以用的。但用手機連你電腦的區網 IP 就不算安全來源了，
> 那種情況還是要走 GitHub Pages 的 HTTPS（見 `GITHUB_PAGES_SETUP.md`）。

---

## 遠端 / 多台機器

```bash
herdr --remote <ssh-host>              # 本機介面，pane 跑在遠端
herdr machine add <ssh-host> --label "工作機"   # 存起來，之後 Local 和遠端同一個視窗
```

手機沒有官方 App，做法是用任何 SSH client 連上去再跑 `herdr`，介面會自動縮成單欄。

## 出問題時

```bash
herdr status          # server / client 狀態
herdr config check    # 設定檔診斷
herdr --help          # 印出設定檔與 log 的實際路徑
```

log 在設定檔同一個資料夾（`herdr.log`、`herdr-client.log`、`herdr-server.log`）。
想看詳細一點：`HERDR_LOG=herdr=debug herdr`。

按鍵被自己改壞了的話，`herdr config reset-keys` 會先備份設定再還原成預設按鍵。

官方文件：<https://herdr.dev/docs/>
