# CLAUDE.md

Electron 製のデスクトップアプリ。<!-- アプリの概要を 1〜2 行で書く -->

> 現状: 設計段階（未実装）。ビルド・テストコマンドは雛形作成後にこのファイルへ追記すること。

## 設計ドキュメント

- [docs/tech-decisions.md](docs/tech-decisions.md) — 技術選定の理由
- [docs/directory-structure.md](docs/directory-structure.md) — ディレクトリ構成と各層の責務
- [docs/ipc-api.md](docs/ipc-api.md) — IPC API とバリデーション
- [docs/implementation-steps.md](docs/implementation-steps.md) — 実装ステップと完了条件
<!-- 設計ドキュメントを追加したらここに列挙する -->

## プロンプト実行履歴（必ず守る）

プロンプト原文は UserPromptSubmit フック（[.claude/hooks/log-prompt.sh](.claude/hooks/log-prompt.sh)）が送信時に [history/prompt-history.md](history/prompt-history.md) の末尾へ自動で書き込む。フックは `## #<連番>（YYYY-MM-DD HH:MM）` の見出しと `### プロンプト` を書く。

Claude はプロンプトを処理し終えるたびに、その最新エントリを次のように仕上げる。

- 見出しの連番の後ろに作業内容の要約を足す: `## #<連番> <作業内容の要約>（YYYY-MM-DD HH:MM）`
- `### プロンプト` はフックが書くので、Claude は書かない・書き換えない
- 末尾に `### 実施内容`: 行ったこと・決めたことを箇条書きで簡潔に
- `### 成果物`: 作成・更新したファイルのパス（なければ「なし」）
- 区切りの `---` はフックが書く
- フックのエントリが見当たらない場合（フック無効時など）は、見出し・プロンプトを含めてエントリ全体を Claude が書く
- 質問への回答のみで作業がない場合も記録する。途中で中断されたプロンプトは、実施した範囲と「中断」と明記して記録する
- 過去のエントリは書き換えない

## 動作履歴（実装ステップごと・必ず守る）

ツール操作はフックが実装ステップごとに自動保存する。

```
history/
  prompt-history.md      # プロンプト履歴（上記）
  .current-step          # 現在のステップ名（例: step-01）
  step-01/
    actions.md           # 操作ログ: 時刻・ツール・対象・成否（PostToolUse / PostToolUseFailure フック）
  general/               # .current-step が無いときの記録先（git 管理外）
```

- 実装ステップを始めるときは、最初に `history/.current-step` にステップ名を書く（[docs/implementation-steps.md](docs/implementation-steps.md) の番号を 2 桁で `step-01` 形式）
- ステップを終えたら `history/.current-step` を削除する
- `actions.md` はフックが書くので、Claude は編集しない

## 機能要件

<!-- 記入 -->

## 技術スタック

- 言語: TypeScript（`strict: true`）
- ビルド: electron-vite（main / preload / renderer を一括ビルド）
- レンダラー: React + Vite
- 永続化: <!-- 方式と保存先を記入（例: `app.getPath('userData')/data.json`） -->
- テスト: Vitest（main・shared のロジック）、必要に応じて Playwright（E2E）

## ディレクトリ構成

```
src/
  main/        # メインプロセス。データの唯一の所有者
    index.ts          # アプリ起動・BrowserWindow 生成
    ipc.ts            # ipcMain.handle の登録
    validation.ts     # IPC 引数の検証
  preload/
    index.ts   # contextBridge で window.api を公開
  renderer/    # React UI（Node API へのアクセス不可）
  shared/      # main / preload / renderer で共有する型・定数
    types.ts
    ipcChannels.ts
```

## セキュリティ規約（必ず守る）

- `BrowserWindow` の `webPreferences` は `contextIsolation: true` / `nodeIntegration: false` / `sandbox: true` を維持する。緩める変更はしない
- レンダラーとメインの通信は preload が公開する `window.api` のみ。`ipcRenderer` 自体や任意チャネルを送れる汎用関数を公開しない
- IPC は `ipcMain.handle` / `ipcRenderer.invoke` で行い、メイン側で引数を必ず検証する（レンダラーの入力は信用しない）
- CSP を設定する: `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'`（本番）
- 外部 CDN やリモートコンテンツを読み込まない
- `setWindowOpenHandler` で新規ウィンドウを拒否し、`will-navigate` でアプリ外への遷移を拒否する
- `shell.openExternal` や `remote` モジュールは使わない

## アーキテクチャ規約

- アプリデータの読み書きは main プロセスのみ。renderer は IPC の戻り値で状態を更新する
- IPC チャネル名と引数・戻り値の型は `src/shared` に定義し、main / preload / renderer で共有する
- 永続化は Repository インターフェース越しに行い、保存方式を差し替え可能にする
- ファイル書き込みは一時ファイル → `rename` のアトミック書き込みで行う。保存形式には `version` を持たせる
- ID は `crypto.randomUUID()`、日時は ISO 8601 文字列

## コーディング規約

- `any` を使わない。IPC 境界の型は `unknown` で受けてから検証する
- 依存追加は最小限
