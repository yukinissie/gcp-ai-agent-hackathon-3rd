# Culture - AI駆動型ニュースキュレーションプラットフォーム

GCP AI Agent Hackathon 第3回で開発された、パーソナライズされたニュース体験を提供するフルスタックWebアプリケーション

## 🎯 プロジェクト概要

**Culture**は、ユーザーの興味や好みに基づいてニュース記事をキュレーションし、AIエージェントとの対話を通じて新しいコンテンツを発見できるプラットフォームです。

### 主な機能

- **AI駆動のニュースキュレーション**: Googleの生成AIを活用した記事の要約・分類
- **パーソナライズされた体験**: ユーザーの評価履歴に基づくコンテンツ推薦
- **インタラクティブなチャット**: AIエージェントとの対話で興味のあるトピックを探索
- **タグベース検索**: 記事をカテゴリ別に整理・検索

## 🏗️ システムアーキテクチャ

### 技術スタック

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend Layer                       │
│   Next.js 15.5 + React 19 + TypeScript + Radix UI           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                      AI Agent Layer                         │
│     Mastra Framework + Google Gemini 2.0 Flash              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                        Backend Layer                        │
│           Rails 8.0 API + PostgreSQL + NextAuth             │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Infrastructure Layer                     │
│        Google Cloud Run + Artifact Registry (GCP)           │
└─────────────────────────────────────────────────────────────┘
```

### コンポーネント

| コンポーネント | 技術 | 説明 |
|--------------|------|------|
| **フロントエンド** | Next.js 15.5 + React 19 | App Routerベースのモダンなフロントエンド |
| **AI/LLM** | Mastra + Google Gemini 2.0 Flash | ニュースキュレーション・タグ判定エージェント |
| **バックエンド** | Ruby on Rails 8.0 | RESTful API・認証・データ管理 |
| **認証** | NextAuth v5 (Auth.js) | セッション管理・JWT認証 |
| **データベース** | PostgreSQL 15+ | ユーザー・記事・評価データの永続化 |
| **インフラ** | Google Cloud Run | サーバーレスコンテナデプロイメント |
| **IaC** | Terraform | インフラのコード化管理 |

## 📁 プロジェクト構成

```
gcp-ai-agent-hackathon-3rd/
├── culture-web/              # Next.js フロントエンド
│   ├── src/
│   │   ├── app/              # App Router ページ
│   │   │   ├── (anonymous)/  # 未認証ページ（ログイン・登録）
│   │   │   ├── (authorized)/ # 認証済みページ（ホーム・記事詳細）
│   │   │   ├── (public)/     # パブリックページ（利用規約等）
│   │   │   └── api/          # API Routes（NextAuth・エージェント）
│   │   ├── mastra/           # AIエージェント定義
│   │   │   ├── agents/       # ニュースキュレーション・タグ判定
│   │   │   └── tools/        # エージェントツール
│   │   └── lib/              # 共通ライブラリ
│   ├── package.json
│   └── next.config.ts
│
├── culture_rails/            # Rails バックエンド
│   ├── app/
│   │   ├── controllers/api/v1/  # API コントローラー
│   │   ├── models/              # データモデル
│   │   └── views/               # JB JSONテンプレート
│   ├── db/                      # マイグレーション・スキーマ
│   ├── spec/                    # RSpec テスト
│   ├── doc/openapi.yml          # OpenAPI仕様書
│   ├── Gemfile
│   └── docker-compose.yml
│
├── culture-infra/            # Terraform インフラ
│   └── service/
│       ├── culture-web/      # フロントエンドインフラ
│       └── culture-rails/    # バックエンドインフラ
│
└── .github/workflows/        # CI/CD パイプライン
    ├── deploy-culture-web-*.yml
    └── deploy-culture-rails-*.yml
```

## 🚀 クイックスタート

### 前提条件

- **Docker Desktop** 4.0+
- **Node.js** 24.x (LTS)
- **Ruby** 3.4+
- **Google Cloud SDK** (デプロイ時)

### 1. リポジトリのクローン

```bash
git clone https://github.com/yukinissie/gcp-ai-agent-hackathon-3rd.git
cd gcp-ai-agent-hackathon-3rd
```

### 2. バックエンドのセットアップ

```bash
cd culture_rails

# Docker Compose で PostgreSQL 起動 + DB セットアップ
dip provision

# Rails サーバー起動 (http://localhost:3000)
dip rails s
```

**主要コマンド（dip使用）**:
- `dip c` - Rails コンソール
- `dip rspec` - テスト実行
- `dip rubocop` - コード品質チェック
- `dip bundle` - Gem のインストール

### 3. フロントエンドのセットアップ

```bash
cd culture-web

# 依存関係インストール
npm install

# 環境変数設定（.env.localを作成）
cp .env.example .env.local
# GOOGLE_GENERATIVE_AI_API_KEY を設定

# 開発サーバー起動 (http://localhost:3030)
npm run dev
```

### 4. 初回アクセス

1. ブラウザで `http://localhost:3030` を開く
2. 「新規登録」からアカウント作成
3. ホーム画面でAIエージェントとチャット開始

## 🧪 開発ワークフロー

### テスト実行

```bash
# Rails APIテスト（RSpec + OpenAPI検証）
cd culture_rails
dip rspec

# フロントエンドリント
cd culture-web
npm run lint
npm run format
```

### コード品質チェック

```bash
# Rails: RuboCop + Brakeman
dip rubocop
dip brakeman

# Next.js: Biome
npm run lint
```

### データベース操作

```bash
# マイグレーション実行
dip rails db:migrate

# シードデータ投入
dip rails db:seed

# DB リセット
dip rails db:reset
```

## 🌐 デプロイメント

### 環境構成

| 環境 | URL | リソース | 自動デプロイ |
|------|-----|---------|------------|
| **Production** | https://culture-web-prod-xxx.run.app | 4 CPU / 4Gi Memory | main ブランチ |
| **Staging** | https://culture-web-staging-xxx.run.app | 2 CPU / 2Gi Memory | 手動デプロイ |

### デプロイ手順

#### 1. GitHub Actions による自動デプロイ

```bash
# main ブランチへのマージでプロダクション自動デプロイ
git push origin main
```

#### 2. 手動デプロイ（Staging）

```bash
# GitHub Actions の "Deploy Culture Web (Staging)" ワークフローを手動実行
```

#### 3. インフラ更新（Terraform）

```bash
cd culture-infra/service/culture-web/environments/production

# 初期化
terraform init -backend-config=backend.hcl

# 変更確認
terraform plan

# 適用
terraform apply
```

## 📚 API仕様

### 認証エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| `POST` | `/api/v1/users` | ユーザー登録 |
| `POST` | `/api/v1/sessions` | ログイン（JWT発行） |
| `DELETE` | `/api/v1/sessions` | ログアウト |
| `GET` | `/api/v1/user_attributes` | ユーザー属性取得 |

### 記事エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| `GET` | `/api/v1/articles` | 記事一覧取得 |
| `GET` | `/api/v1/articles/:id` | 記事詳細取得 |
| `POST` | `/api/v1/articles` | 記事作成 |
| `POST` | `/api/v1/articles/:id/activities` | 記事評価（Good/Bad） |

### タグ・検索エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| `GET` | `/api/v1/tags` | タグ一覧取得 |
| `POST` | `/api/v1/tag_search_histories` | タグ検索履歴保存 |
| `GET` | `/api/v1/tag_search_histories/articles` | 検索履歴ベース記事取得 |

詳細は [`culture_rails/doc/openapi.yml`](culture_rails/doc/openapi.yml) を参照

## 🧰 主要技術の詳細

### フロントエンド（culture-web）

- **Next.js 15.5**: App Router・Server Components・Parallel Routes
- **TypeScript 5.x**: 厳格な型チェック
- **Radix UI**: アクセシブルなUIコンポーネント（Toast・テーマ切り替え）
- **Biome**: 高速なリンター・フォーマッター
- **Mastra Framework**: AIエージェントオーケストレーション
- **next-themes**: ダークモード対応

### バックエンド（culture_rails）

- **Rails 8.0**: 最新の Rails API モード
- **Sorcery + JWT**: カスタム認証システム
- **Committee Rails**: OpenAPI スキーマ自動検証
- **JBuilder (jb gem)**: JSON レスポンステンプレート
- **RSpec + FactoryBot**: テスト駆動開発
- **Solid Stack**: Redis 不要のキャッシュ/キュー

### インフラ（culture-infra）

- **Google Cloud Run**: サーバーレスコンテナ
- **Artifact Registry**: Docker イメージ管理
- **Secret Manager**: 環境変数・認証情報管理
- **Terraform**: IaCによるインフラ管理
- **GitHub Actions**: CI/CD パイプライン

## 🔒 セキュリティ

- **認証**: bcrypt + JWT トークンベース認証
- **CORS**: Rails側で Next.js ドメインのみ許可
- **環境変数**: Secret Manager による機密情報管理
- **セキュリティスキャン**: Brakeman による脆弱性検査
- **HTTPSのみ**: Cloud Run で強制的に HTTPS 接続

## 🤝 コントリビューション

1. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
2. 変更をコミット (`git commit -m 'feat: 素晴らしい機能を追加'`)
3. ブランチにプッシュ (`git push origin feature/amazing-feature`)
4. プルリクエストを作成

### コミットメッセージ規約

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
refactor: リファクタリング
test: テスト追加
chore: 雑務・依存関係更新
```

## 📖 ドキュメント

- **[CLAUDE.md](CLAUDE.md)**: AI Assistant 向けプロジェクトコンテキスト
- **[Rails開発ガイド](culture_rails/CLAUDE.md)**: API開発・認証システム詳細
- **[インフラドキュメント](culture-infra/README.md)**: Terraform 構成詳細
- **[デプロイメント手順](DEPLOYMENT_SECRET_SETUP.md)**: Secret Manager セットアップ

## 🐛 トラブルシューティング

### よくある問題

**1. Rails サーバーが起動しない**
```bash
# Docker コンテナを再起動
dip down
dip up
```

**2. フロントエンドでAPIエラー**
- `culture-web/.env.local` に `NEXT_PUBLIC_API_URL=http://localhost:3000` が設定されているか確認
- Rails サーバーが起動しているか確認

**3. 認証エラー**
```bash
# Rails マスターキーを確認
cat culture_rails/config/master.key

# JWT Secret が設定されているか確認
dip rails credentials:show
```

**4. Terraform エラー**
```bash
# GCP 認証を再実行
gcloud auth login
gcloud auth application-default login
```

## 👥 開発チーム

第3回 GCP AI Agent Hackathon 参加チーム「カルチャーズ」

---

**Built with** ❤️ **using Google Cloud Platform and AI**
