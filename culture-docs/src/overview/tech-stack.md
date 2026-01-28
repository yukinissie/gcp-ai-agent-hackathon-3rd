# 技術スタック

## フロントエンド (culture-web)

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| フレームワーク | Next.js | 15.5.3 |
| UIライブラリ | React | 19.1.0 |
| 言語 | TypeScript | 5.x |
| ビルドツール | Turbopack | - |
| UIコンポーネント | Radix UI | - |
| スタイリング | CSS Modules + Radix Colors | - |
| コード品質 | Biome | 2.2.4 |
| 認証 | NextAuth (Auth.js) | v5 |
| AIインテグレーション | Mastra Framework | - |
| テーマ | next-themes | - |

## バックエンド (culture_rails)

| カテゴリ | 技術 | バージョン |
|---------|------|-----------|
| フレームワーク | Ruby on Rails (API mode) | 8.0.2+ |
| データベース | PostgreSQL | 15+ |
| Webサーバー | Puma | - |
| 認証 | JWT (Custom) + Sorcery patterns | - |
| API定義 | OpenAPI + Committee Rails | - |
| ビューテンプレート | JBuilder (jb gem) | - |
| キャッシュ/キュー | Solid Cache, Solid Queue, Solid Cable | - |
| テスト | RSpec + FactoryBot | - |
| コード品質 | RuboCop Rails Omakase | - |
| セキュリティ | Brakeman | - |

## AIエージェント

| カテゴリ | 技術 |
|---------|------|
| AIオーケストレーション | Mastra Framework |
| LLMプロバイダー | Google Gemini 2.0 Flash |
| SDK | @ai-sdk/google, @ai-sdk/react |

## インフラストラクチャ

| カテゴリ | サービス |
|---------|---------|
| クラウドプロバイダー | Google Cloud |
| リージョン | asia-northeast1 |
| コンテナ実行環境 | Cloud Run |
| コンテナレジストリ | Artifact Registry |
| シークレット管理 | Secret Manager |
| IaC | Terraform |
| CI/CD | GitHub Actions |

## 開発ツール

| カテゴリ | ツール |
|---------|-------|
| コンテナ | Docker Compose |
| CLIヘルパー | Dip |
| エディタサポート | Ruby LSP |
| バージョン管理 | Git |
