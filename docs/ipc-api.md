# IPC API 設計

renderer と main の通信は、preload が `contextBridge` で公開する `window.api` だけで行う。すべて `ipcRenderer.invoke` / `ipcMain.handle` を使った要求・応答型。

## window.api

```ts
// src/preload/index.d.ts
export interface AppApi {
  // 例: list(): Promise<Item[]>;
}

declare global {
  interface Window {
    api: AppApi;
  }
}
```

## チャネル一覧

チャネル名は `<ドメイン>:<操作>` 形式（例: `item:list`）。

| チャネル | 引数 | 戻り値 | 内容 |
|---|---|---|---|
| <!-- 記入 --> | | | |

チャネル名は `src/shared/ipcChannels.ts` に定数として定義し、main と preload で共有する。

```ts
export const IpcChannels = {
  // 例: list: 'item:list',
} as const;
```

## 入力検証（main 側）

renderer からの引数は `unknown` として受け取り、`src/main/validation.ts` で検証してから Repository に渡す。

| 項目 | ルール |
|---|---|
| <!-- 例: `id` --> | <!-- 例: 文字列、UUID 形式 --> |

- 想定外のキーは拒否する
- 文字列は前後の空白を除去し、長さの上限を決める

## エラー処理

- 検証エラーや存在しない ID の場合、main は `Error` を投げる。`invoke` 側の Promise は reject される
- renderer で catch し、画面にエラーメッセージを表示する

## 実装上の注意

- preload から `ipcRenderer` 自体や、任意チャネルを送れる汎用関数を公開しない
- 書き込み系の API は更新後のデータを返し、renderer が再取得しなくても状態を更新できるようにする
