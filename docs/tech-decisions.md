# 技術選定

## レンダラーの UI フレームワーク: React + Vite（electron-vite）

| 候補 | 評価 |
|---|---|
| **React（採用）** | TypeScript の型情報が充実していて資料も多い |
| Svelte | 軽くてコードも短い。ただ Electron ではバンドルサイズの差がほぼ効かないので、利点が小さい |
| Vanilla TS | 依存はゼロ。ただ UI の状態と DOM の同期を手で書く量が増える |

electron-vite を使うと、main・preload・renderer の3つを1つの設定でビルドでき、HMR も使える。

## 永続化: <!-- 採用方式 -->

| 方式 | 長所 | 短所 |
|---|---|---|
| JSON ファイル（fs） | 依存ゼロ。中身を直接読めてデバッグが楽 | 全件を書き直すので、大量データでは非効率 |
| electron-store | 導入が簡単 | 最新版は ESM 専用。スキーマ移行の自由度が低い |
| SQLite（better-sqlite3） | クエリと大量データに強い | ネイティブモジュールなので、Electron 向けの rebuild や配布の手間がかかる |
| IndexedDB / localStorage | renderer だけで完結する | データの所有者が renderer になり、「main が所有する」という方針と合わない |

<!-- データ量・要件から採用理由を書く -->

## セキュリティ方針

- `contextIsolation: true` / `nodeIntegration: false` / `sandbox: true`
- renderer と main の通信は preload が公開する `window.api` のみ（詳細は [ipc-api.md](ipc-api.md)）
- CSP: `default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'`
- `setWindowOpenHandler` で新規ウィンドウを拒否し、`will-navigate` でアプリ外への遷移を拒否する
