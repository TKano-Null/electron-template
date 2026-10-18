# 実装ステップ

各ステップは1コミット単位。完了条件を満たしてから次へ進む。

## ステップ1: 雛形とセキュリティ設定

- [ ] electron-vite（React + TypeScript テンプレート）でプロジェクトを生成
- [ ] `tsconfig` を `strict: true` にし、[directory-structure.md](directory-structure.md) の構成に合わせる（`src/shared` を追加）
- [ ] `webPreferences` に `contextIsolation: true` / `nodeIntegration: false` / `sandbox: true` を設定
- [ ] `index.html` に CSP の meta タグを追加
- [ ] `setWindowOpenHandler` で新規ウィンドウを拒否、`will-navigate` で外部遷移を拒否
- [ ] Vitest を導入
- [ ] `CLAUDE.md` に dev / build / test コマンドを追記

**完了条件**: `npm run dev` で空のウィンドウが起動し、DevTools で `require` や `process` が未定義であることを確認できる。

## ステップ2: 共有型と永続化

- [ ] `src/shared/types.ts` にドメイン型を定義
- [ ] `src/main/` に Repository インターフェースと実装を作成
- [ ] ファイル保存ならアトミック書き込み（tmp → `rename`）、ファイルがない・壊れている場合の扱い
- [ ] ユニットテスト

**完了条件**: `npm test` が通る。

## ステップ3: IPC と preload

- [ ] `src/shared/ipcChannels.ts` にチャネル定数を定義
- [ ] `src/main/validation.ts` に入力検証を実装
- [ ] `src/main/ipc.ts` で `ipcMain.handle` を登録
- [ ] `src/preload/index.ts` で `window.api` を公開、`index.d.ts` で型宣言
- [ ] ユニットテスト: 検証ロジック（不正な型・範囲外の値・余計なキー）

**完了条件**: DevTools のコンソールから `window.api` を呼んで結果が返る。

## ステップ4〜: UI

<!-- アプリの機能ごとにステップを分けて書く -->

## ステップN: 仕上げ

- [ ] IPC エラー時のメッセージ表示
- [ ] キーボード操作とフォーカス管理
- [ ] 異常系（壊れたデータファイル、不正入力）の確認

**完了条件**: 異常系で落ちずに動作する。

## ステップN+1（任意）: E2E とパッケージ化

- [ ] Playwright（`_electron`）で主要操作の E2E テスト
- [ ] electron-builder で配布用パッケージを作成

**完了条件**: E2E テストが通り、パッケージ版のアプリが起動・保存できる。
