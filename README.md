# 顔文字キーボード (KaomojiKeyboard)

iOSカスタムキーボードで顔文字を簡単に作成・入力できるアプリ。
アプリで顔文字を組み立てて登録し、キーボードから呼び出して入力する。

## 機能

- **顔文字工房**: 表情・枠・手・装飾を組み合わせて顔文字を作成
- **マイ顔文字**: 作成した顔文字の登録・編集・並び替え・削除
- **履歴**: 入力した顔文字の履歴表示・再登録
- **キーボード拡張**: 登録済み顔文字の呼び出し、表情テンプレートからの直接入力、枠・手・飾の簡易調整

## プロジェクト構成

```
KaomojiKeyboard/
├── KaomojiKeyboard/          # メインアプリ
│   ├── KaomojiKeyboardApp.swift
│   ├── ContentView.swift     # TabViewルーティング
│   ├── WorkshopView.swift    # 顔文字工房（ビルダー）
│   ├── WorkshopGridCell.swift # アプリ用グリッドセル
│   ├── MyKaomojiView.swift   # マイ顔文字管理
│   ├── HistoryView.swift     # 履歴表示・再登録
│   ├── SettingsView.swift    # 設定・セットアップ手順
│   └── Assets.xcassets/
│
├── KeyboardExtension/        # キーボード拡張
│   ├── KeyboardViewController.swift
│   ├── KeyboardView.swift    # キーボードUI
│   ├── FlickKeyView.swift    # フリック入力対応キー
│   └── Info.plist
│
├── Shared/                   # 共通コード（App Group経由で共有）
│   ├── Models.swift          # データモデル（BuilderState, RegisteredKaomoji等）
│   ├── KaomojiData.swift     # データ読み込み・おすすめロジック
│   ├── KaomojiBuilder.swift  # 顔文字組み立て・状態保存/復元
│   ├── KaomojiStorage.swift  # 登録・履歴・お気に入りのCRUD
│   ├── SharedSettings.swift  # 共有設定
│   └── expressions.json      # 顔文字データ（表情・枠・手・装飾・顔パーツ）
│
├── Tests/                    # ユニットテスト
│   ├── KaomojiBuilderTests.swift
│   ├── KaomojiDataTests.swift
│   ├── KaomojiStorageTests.swift
│   └── PerformanceTests.swift
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
4. キーボードの地球儀ボタンで切り替え

## 技術スタック

- SwiftUI
- UIInputViewController (Keyboard Extension)
- App Group (アプリ⇔キーボード間のデータ共有)
- JSON (データ管理)
- Xcode Cloud (CI/CD → TestFlight配信)
- 外部依存: なし

## アーキテクチャ

### アプリ中心設計

メインアプリで顔文字を作成・登録し、キーボードは辞書呼び出し＋簡易調整に徹する設計。

```
[アプリ] 工房で作成 → 登録 → [キーボード] 辞書から呼び出し → 入力
```

### 顔文字の構造

```
顔文字 = [装飾] + [手] + [枠] + [表情/パーツ] + [枠] + [手] + [装飾] + [アクション]
```

- **テンプレモード**: カテゴリ別の表情セットから選択
- **パーツモード**: 左目・口・右目を個別に選択

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

## テスト

```bash
xcodebuild test -project KaomojiKeyboard.xcodeproj -scheme KaomojiKeyboard \
  -destination 'platform=macOS,variant=Designed for iPad' -quiet
```

## ライセンス

MIT
