# プロジェクトについて

## 概要

Cultureは、AIを活用したニュースキュレーションプラットフォームです。Google Cloud AI Agent Hackathonのために開発され、ユーザーの興味に合わせたパーソナライズされたニュース体験を提供します。

## プロジェクトの目的

1. **パーソナライズされたニュース発見**: ユーザーの評価履歴と興味に基づいて、関連性の高い記事を提案
2. **AIエージェントによる対話**: 自然言語でトピックを探索し、興味のある分野を深掘り
3. **効率的な情報収集**: タグベースの検索と要約機能により、短時間で重要な情報を把握

## ディレクトリ構造

```
gcp-ai-agent-hackathon-3rd/
├── culture-web/          # Next.js フロントエンド
├── culture_rails/        # Rails バックエンドAPI
├── culture-infra/        # Terraform インフラ構成
├── culture-docs/         # ドキュメント（本書）
├── .github/workflows/    # CI/CD パイプライン
├── README.md            # プロジェクト説明
└── CLAUDE.md            # AI支援開発向けコンテキスト
```

## 主要コンポーネント

| コンポーネント | 説明 | 技術スタック |
|--------------|------|-------------|
| culture-web | Webフロントエンド | Next.js 15, React 19, TypeScript |
| culture_rails | バックエンドAPI | Rails 8, PostgreSQL |
| culture-infra | インフラ構成 | Terraform, Google Cloud |
| AIエージェント | ニュースキュレーション | Mastra, Google Gemini |

## 実装済み機能

### 認証システム
- NextAuth v5による認証フロー
- Rails JWTトークン認証
- セッション管理

### 記事管理
- CRUD操作
- Good/Bad評価（排他的選択）
- タグ検索・履歴

### AIインテグレーション
- Mastra Frameworkによるエージェント管理
- Google Gemini 2.0 Flashによる記事処理
- リアルタイムチャットインターフェース
