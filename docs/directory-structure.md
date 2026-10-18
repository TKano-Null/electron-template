# ディレクトリ構成

```
<project>/
  CLAUDE.md
  package.json
  electron.vite.config.ts
  tsconfig.json          # 共通設定・参照のみ
  tsconfig.node.json     # main / preload / shared 用
  tsconfig.web.json      # renderer / shared 用
  docs/                  # 設計ドキュメント
  src/
    main/                # メインプロセス。データの唯一の所有者
      index.ts           # アプリ起動・BrowserWindow 生成・セキュリティ設定
      ipc.ts             # ipcMain.handle の登録
      validation.ts      # IPC 引数の検証
      <name>Repository.ts # 永続化
    preload/
      index.ts           # contextBridge で window.api を公開
      index.d.ts         # window.api の型宣言（renderer から参照）
    renderer/            # React UI（Node API へのアクセス不可）
      index.html         # CSP の meta タグを含む
      src/
        main.tsx
        App.tsx
        components/
        hooks/           # window.api を呼び、状態を保持する hook
    shared/              # main / preload / renderer で共有
      types.ts           # ドメイン型・入力型
      ipcChannels.ts     # IPC チャネル名の定数
  tests/
    main/                # Repository・validation のユニットテスト
```

## 各層の責務

| 層 | 責務 | 触ってよいもの |
|---|---|---|
| main | データの読み書き、入力検証、ウィンドウ管理 | Node API、Electron main API |
| preload | IPC 呼び出しを型付きの関数として公開 | `contextBridge`、`ipcRenderer`（外には出さない） |
| renderer | 表示と操作 | `window.api` のみ |
| shared | 型と定数 | 実行時の依存を持たない（型・定数のみ） |
