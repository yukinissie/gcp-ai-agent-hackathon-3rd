# 現在のプロジェクト状況（実際の調査結果）

## 📊 技術スタック（実装済み確認）

### フロントエンド (culture-web)

- **フレームワーク**: Next.js 15.5.3 + React 19.1.0 ✅
- **言語**: TypeScript 5.x ✅
- **ビルドツール**: Turbopack ✅
- **コード品質**: Biome 2.2.0 ✅
- **スタイリング**: CSS Modules（index.module.css 使用中）✅
- **現在のページ**: 日本語ランディングページ「Culture へようこそ!👋」

### バックエンド (culture_rails)

- **フレームワーク**: Ruby on Rails 8.0.2+ ✅
- **データベース**: PostgreSQL（空のスキーマ、migration 未実行）❌
- **認証**: Sorcery gem + JWT gem ✅
- **JSON 処理**: JB gem ✅
- **Solid Stack**: Solid Cache/Queue/Cable ✅
- **テスト**: RSpec + FactoryBot + Committee Rails ✅
- **コード品質**: RuboCop Rails Omakase + Brakeman ✅
- **JWT 実装**: JsonWebToken クラス実装済み ✅

## 🚨 CLAUDE.md との主要相違点

### 認証システム

- **CLAUDE.md 記載**: 「自作認証システム（bcrypt + JWT）」
- **実際**: **Sorcery gem + JWT gem** 使用
- **状況**: JWT token ライブラリは実装済み、但しモデル・コントローラー未実装

### データベース

- **CLAUDE.md 記載**: 「Profile 中心設計、User/Credential モデル実装済み」
- **実際**: **完全に空のスキーマ**（version: 0）
- **状況**: マイグレーション未実行、モデル未作成

### API 実装

- **CLAUDE.md 記載**: 「SessionsController 実装済み、POST /api/v1/session」
- **実際**: **空の API ルート**のみ（コメント：新しい設計でのルートは後で追加）
- **状況**: ルート定義のみ、コントローラー未実装

### CI/CD

- **改善点**: Production/Staging 環境分離、手動デプロイ対応
- **新機能**: リリースタグ自動生成、Cloud Run デプロイ URL 出力

## 📁 ディレクトリ構造（実際）

### Rails アプリケーション構造

```
culture_rails/app/
├── controllers/
│   ├── application_controller.rb  # 基本コントローラーのみ
│   └── concerns/.keep
├── models/
│   ├── application_record.rb      # 基本モデルのみ
│   └── concerns/.keep
├── lib/
│   └── json_web_token.rb          # JWT実装済み ✅
└── views/layouts/                 # Rails標準レイアウト
```

### Next.js アプリケーション構造

```
culture-web/src/app/
├── page.tsx                       # 日本語ランディングページ ✅
├── layout.tsx                     # 基本レイアウト
└── index.module.css               # CSS Modules使用 ✅
```

## 🎯 開発優先度

### 高優先度（基本機能未実装）

1. **データベースマイグレーション**: User/認証関連テーブル作成
2. **認証 API**: SessionsController 実装
3. **基本モデル**: User/認証モデル作成

### 中優先度（機能拡張）

4. **API テスト**: RSpec + Committee Rails 設定
5. **フロントエンド機能**: 認証フォーム等

### 低優先度（品質向上）

6. **コード品質**: RuboCop/Brakeman 対応
7. **ドキュメント**: 実装に合わせた更新

## 💡 注意事項

- **CLAUDE.md 情報**: 設計・計画段階の内容で、実装が追いついていない
- **現在の状況**: 基本的な Rails/Next.js セットアップのみ完了
- **認証システム**: 設計方針は定まっているが、実装は未開始
- **CI/CD**: 本番運用レベルの設定が完了している
