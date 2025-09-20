# GCP AI Agent Hackathon - Culture Project

GCP AI Agent Hackathon プロジェクト「Culture」- モダンなクラウドネイティブマイクロサービスアプリケーション

## 🎯 プロジェクト概要

**プロジェクトタイプ**: フルスタック Web アプリケーション（マイクロサービスアーキテクチャ）
**目的**: GCP AI Agent Hackathon プロジェクト - "Culture" アプリケーション
**アーキテクチャ**: モダンなクラウドネイティブマイクロサービス（Rails API + Next.js フロントエンド）

## 🏗️ システムアーキテクチャ

### コンポーネント構成

- **フロントエンド**: Next.js 15.5 React アプリケーション (`culture-web`)
- **バックエンド**: Ruby on Rails 8.0 API サービス (`culture_rails`)
- **インフラ**: Terraform 管理の GCP リソース (`culture-infra`)
- **デプロイメント**: Google Cloud Run での自動化 CI/CD

### 技術スタック

#### フロントエンド (culture-web) ✅ 実装済み

- **フレームワーク**: Next.js 15.5.3 with React 19.1.0
- **言語**: TypeScript 5.x (strict typing)
- **ビルドツール**: Turbopack（高速開発）
- **スタイリング**: CSS Modules
- **コード品質**: Biome 2.2.0（統合 linting + formatting）
- **アーキテクチャ**: App Router with standalone output
- **現在のページ**: 日本語ランディングページ「Culture へようこそ!👋」

#### バックエンド (culture_rails) 🚧 基本設定のみ

- **フレームワーク**: Ruby on Rails 8.0.2+
- **データベース**: PostgreSQL with Docker Compose
- **Web サーバー**: Puma
- **API**: JSON APIs with Jbuilder + Committee Rails（OpenAPI 検証）
- **キャッシュ/キュー**: Solid Cache, Solid Queue, Solid Cable
- **テスト**: RSpec + FactoryBot + Capybara
- **認証**: Sorcery gem + JWT gem（JsonWebToken クラス実装済み）
- **コード品質**: RuboCop Rails Omakase + Brakeman

#### インフラ & DevOps

- **クラウド**: Google Cloud Platform（Asia-Northeast1）
- **コンテナ**: Cloud Run（serverless）
- **レジストリ**: Google Artifact Registry
- **IaC**: Terraform（モジュラー構造）
- **CI/CD**: GitHub Actions
- **開発**: Docker Compose + Dip

## 📁 ディレクトリ構造

```
gcp-ai-agent-hackathon-3rd/
├── culture-web/                    # Next.js フロントエンド
│   ├── src/app/                   # App Router pages
│   ├── public/                    # 静的アセット
│   ├── package.json               # 依存関係・スクリプト
│   ├── next.config.ts             # Next.js設定
│   ├── tsconfig.json              # TypeScript設定
│   └── biome.json                 # Biome設定
├── culture_rails/                  # Rails バックエンド
│   ├── app/                       # Railsアプリケーションコード
│   ├── config/                    # Rails設定
│   ├── db/                        # データベースマイグレーション
│   ├── spec/                      # RSpecテスト
│   ├── Gemfile                    # Ruby依存関係
│   ├── docker-compose.yml         # ローカル開発設定
│   └── dip.yml                    # Dockerコマンドショートカット
├── culture-infra/                  # Terraform インフラ
│   ├── service/culture-web/
│   │   ├── environments/          # Production/Staging設定
│   │   └── modules/               # 再利用可能Terraformモジュール
│   └── README.md                  # インフラドキュメント
├── .github/workflows/              # CI/CD パイプライン
│   └── deploy-culture-web.yml     # Next.js デプロイワークフロー
└── dip.yml                        # グローバル Docker CLI設定
```

## 🚀 開発環境セットアップ

### 前提条件

- Docker & Docker Compose
- Node.js 24+
- Ruby 3.x
- Terraform（インフラ管理用）

### 初期セットアップ

#### 1. バックエンド（Rails）

```bash
cd culture_rails
dip provision        # DB + 依存関係 + migration の完全セットアップ
```

#### 2. フロントエンド（Next.js）

```bash
cd culture-web
npm install
npm run dev          # 開発サーバー起動（ポート3030）
```

## 🔧 開発コマンド

### フロントエンド開発

```bash
cd culture-web
npm run dev          # 開発サーバー（Turbopack）
npm run build        # プロダクションビルド
npm run start        # プロダクションサーバー
npm run lint         # Biome linting
npm run format       # Biome formatting
```

### バックエンド開発

```bash
# Dip使用（推奨）
dip rails s          # Railsサーバー起動
dip c               # Railsコンソール
dip rspec           # RSpecテスト実行
dip rubocop         # RuboCop linting
dip brakeman        # セキュリティスキャン

# 直接Docker Compose
docker-compose up    # 全サービス起動
```

### インフラ管理

```bash
cd culture-infra/service/culture-web/environments/production
terraform init -backend-config=backend.hcl
terraform plan       # 変更プレビュー
terraform apply      # インフラ変更適用
```

## 🧪 テスト実行

### バックエンドテスト

```bash
dip rspec           # 全テスト実行
dip rspec spec/controllers/  # コントローラーテストのみ
```

### コード品質チェック

```bash
# Rails
dip rubocop         # RuboCop linting
dip brakeman        # セキュリティスキャン

# Next.js
cd culture-web
npm run lint        # Biome linting
npm run format      # Biome formatting
```

## 🚀 デプロイメント

### 環境

- **Production**: `culture-web-prod` （1-20 インスタンス、4 CPU、4Gi memory）
- **Staging**: `culture-web-staging` （0-5 インスタンス、2 CPU、2Gi memory）

### CI/CD パイプライン

- **トリガー**: 手動デプロイ（workflow_dispatch）
- **環境分離**: Production/Staging 別々のワークフロー
- **プロセス**:
  1. マルチステージ Docker イメージビルド
  2. Google Artifact Registry へプッシュ
  3. Cloud Run へデプロイ
  4. リリースタグ自動生成・プッシュ
  5. デプロイメント URL 出力

## 🏆 開発ベストプラクティス

### コード品質標準

- **Rails**: RuboCop Rails Omakase（opinionated styling）
- **フロントエンド**: Biome による統合 TypeScript ツール
- **セキュリティ**: Brakeman セキュリティスキャン
- **テスト**: 包括的 RSpec + システムテスト

### コミットメッセージ規約（日本語）

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
refactor: リファクタリング
test: テスト追加
chore: 雑務・依存関係更新
```

## 📚 ドキュメント

- [CLAUDE.md](./CLAUDE.md) - AI Assistant 向けプロジェクトコンテキスト
- [Rails 認証システム](./culture_rails/CLAUDE.md) - Rails API 認証ガイド
- [インフラドキュメント](./culture-infra/README.md) - Terraform 設定詳細

## 🤝 貢献

1. フィーチャーブランチを作成
2. 変更を実装
3. テストを実行（`dip rspec` / `npm run lint`）
4. コミット（日本語メッセージ）
5. プルリクエスト作成

## 📝 注意事項

- **開発環境**: Docker Compose を使用したローカル開発
- **現在の実装状況**: 基本セットアップ完了、認証 API は未実装
- **認証**: Sorcery gem + JWT gem（JsonWebToken クラス実装済み）
- **データベース**: 空のスキーマ（マイグレーション未実行）
- **API**: 基本ルート定義のみ、コントローラー未実装
- **API 検証**: Committee Rails による OpenAPI 準拠（設定済み）
- **セキュリティ**: 機密情報のコミット禁止

## 🚧 開発状況

### ✅ 完了済み
- Next.js フロントエンド基本実装
- Rails バックエンド基本設定
- JWT トークンライブラリ実装
- CI/CD パイプライン（Production/Staging）
- 日本語ランディングページ

### 🚧 実装中・未完了
- データベースマイグレーション
- 認証 API（SessionsController）
- ユーザーモデル・認証モデル
- API テスト（RSpec + Committee Rails）
- フロントエンド認証機能

---

**本プロジェクトは、迅速なハッカソン開発に適したエンタープライズグレードの開発プラクティスと、本番対応デプロイメント機能を実証しています。**
