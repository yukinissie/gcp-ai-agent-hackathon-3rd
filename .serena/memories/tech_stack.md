# 技術スタック

## フロントエンド (culture-web)

- **フレームワーク**: Next.js 15.5.3 with React 19.1.0
- **言語**: TypeScript 5.x (strict typing)
- **ビルドツール**: Turbopack（高速開発）
- **スタイリング**: CSS Modules
- **コード品質**: Biome 2.2.0（統合 linting + formatting）
- **アーキテクチャ**: App Router with standalone output

## バックエンド (culture_rails)

- **フレームワーク**: Ruby on Rails 8.0.2+
- **データベース**: PostgreSQL with Docker Compose
- **Web サーバー**: Puma
- **アセットパイプライン**: Propshaft（モダン Rails assets）
- **フロントエンド統合**: Hotwire（Turbo + Stimulus）
- **API**: JSON APIs with Jbuilder + Committee Rails（OpenAPI 検証）
- **キャッシュ/キュー**: Solid Cache, Solid Queue, Solid Cable
- **テスト**: RSpec + FactoryBot + Capybara
- **コード品質**: RuboCop Rails Omakase + Brakeman security scanner
- **認証**: 自作認証システム（bcrypt + JWT）

## インフラ & DevOps

- **クラウド**: Google Cloud（GCP）
- **コンテナ**: Cloud Run（serverless）
- **レジストリ**: Google Artifact Registry
- **IaC**: Terraform（モジュラー構造）
- **CI/CD**: GitHub Actions
- **開発**: Docker Compose + Dip（CLI 簡素化）
- **リージョン**: Asia-Northeast1（日本）
