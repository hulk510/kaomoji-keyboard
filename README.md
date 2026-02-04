# 顔文字キーボード (KaomojiKeyboard)

iOSカスタムキーボードで顔文字を簡単に作成・入力できるアプリ。

## プロジェクト構成

```
KaomojiKeyboard/
├── KaomojiKeyboard/          # メインアプリ
│   ├── KaomojiKeyboardApp.swift
│   ├── ContentView.swift     # セットアップ画面
│   └── Assets.xcassets/
│
├── KeyboardExtension/        # キーボード拡張
│   ├── KeyboardViewController.swift
│   ├── KeyboardView.swift    # キーボードUI (SwiftUI)
│   └── Info.plist
│
├── Shared/                   # 共通コード
│   ├── Models.swift          # データモデル
│   ├── KaomojiData.swift     # データ読み込み
│   ├── KaomojiBuilder.swift  # 顔文字組み立てロジック
│   └── expressions.json      # 顔文字データ
│
└── KaomojiKeyboard.xcodeproj
```

## セットアップ

1. Xcodeでプロジェクトを開く
2. Signing & Capabilities で Team を設定
3. Bundle Identifier を変更（必要に応じて）
4. ビルド＆実行

## キーボードの有効化

1. 設定 > 一般 > キーボード
2. キーボード > 新しいキーボードを追加
3. 「KaomojiKeyboard」を選択
4. キーボードの🌐ボタンで切り替え

## 技術スタック

- SwiftUI
- UIInputViewController (Keyboard Extension)
- JSON (データ管理)
- 外部依存: なし

## アーキテクチャ

### 表情セット方式

顔文字を「パーツ」ではなく「表情セット」として管理。
これによりシンプルな実装で破綻しない顔文字が作れる。

```
顔文字 = [装飾] + [手] + [枠] + [表情] + [枠] + [手] + [装飾]
```

### おすすめ機能

表情と手・装飾にタグを持たせ、相性の良い組み合わせを上位表示。

## データ追加

`Shared/expressions.json` にデータを追加:

```json
{
  "id": "new_expression",
  "face": "新しい表情",
  "category": "happy",
  "tags": ["cute", "bright"]
}
```

## ライセンス

MIT
