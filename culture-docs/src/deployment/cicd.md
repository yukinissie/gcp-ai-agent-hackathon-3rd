# CI/CDパイプライン

## 概要

CultureはGitHub Actionsを使用してCI/CDパイプラインを構築しています。Stagingは自動デプロイ、Productionは手動トリガーで運用しています。

## ワークフロー一覧

| ワークフロー | トリガー | 対象 |
|------------|---------|------|
| `deploy-culture-web-staging.yml` | mainブランチへのpush | フロントエンドStaging |
| `deploy-culture-web-production.yml` | 手動 (workflow_dispatch) | フロントエンドProduction |
| `deploy-culture-rails-staging.yml` | mainブランチへのpush | バックエンドStaging |
| `deploy-culture-rails-production.yml` | 手動 (workflow_dispatch) | バックエンドProduction |

## デプロイフロー

```
┌─────────────────┐
│  Push to main   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  GitHub Actions │
│    Triggered    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Build Docker   │
│     Image       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Push to        │
│ Artifact Registry│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Deploy to      │
│   Cloud Run     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Output URL     │
└─────────────────┘
```

## Stagingデプロイ

mainブランチへのpush時に自動実行されます。

```yaml
# .github/workflows/deploy-culture-web-staging.yml
name: Deploy Culture Web to Staging

on:
  push:
    branches:
      - main
    paths:
      - 'culture-web/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}

      - name: Build and Push Image
        run: |
          docker build -t image-name .
          docker push image-name

      - name: Deploy to Cloud Run
        run: |
          gcloud run deploy culture-web-staging \
            --image image-name \
            --region asia-northeast1
```

## Productionデプロイ

GitHub Actionsの「Run workflow」から手動で実行します。

```yaml
# .github/workflows/deploy-culture-web-production.yml
name: Deploy Culture Web to Production

on:
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # Staging と同様のステップ

      - name: Create Release Tag
        run: |
          git tag v$(date +%Y%m%d%H%M%S)
          git push origin --tags
```

## シークレット設定

GitHub Secretsに以下を設定する必要があります：

| シークレット名 | 説明 |
|--------------|------|
| `GCP_SA_KEY` | Google Cloudサービスアカウントキー（JSON） |
| `GCP_PROJECT_ID` | Google CloudプロジェクトID |

## マルチステージビルド

Dockerイメージはマルチステージビルドで最適化されています。

```dockerfile
# ビルドステージ
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build

# 本番ステージ
FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

EXPOSE 3030
CMD ["node", "server.js"]
```

## デプロイ確認

デプロイ完了後、GitHub Actionsのログにデプロイ先URLが出力されます。

```
Deployment URL: https://culture-web-staging-xxx.a.run.app
```

## ロールバック

Cloud Runのリビジョン機能を使用してロールバックできます。

```bash
# リビジョン一覧
gcloud run revisions list --service culture-web-staging --region asia-northeast1

# 特定リビジョンにロールバック
gcloud run services update-traffic culture-web-staging \
  --to-revisions=culture-web-staging-00005-abc=100 \
  --region asia-northeast1
```
