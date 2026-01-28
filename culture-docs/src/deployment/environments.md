# 環境構成

## 環境一覧

| 環境 | 用途 | デプロイトリガー |
|-----|------|----------------|
| **Staging** | 開発・検証用 | mainブランチへのpush（自動） |
| **Production** | 本番運用 | 手動トリガー |

## リソース構成

### Staging環境

| サービス | CPU | メモリ | 最小インスタンス | 最大インスタンス |
|---------|-----|-------|----------------|----------------|
| culture-web-staging | 2 | 2Gi | 0 | 10 |
| culture-rails-staging | 2 | 2Gi | 0 | 10 |

### Production環境

| サービス | CPU | メモリ | 最小インスタンス | 最大インスタンス |
|---------|-----|-------|----------------|----------------|
| culture-web-prod | 4 | 4Gi | 1 | 100 |
| culture-rails-prod | 4 | 4Gi | 1 | 100 |

## URL構成

```
Staging:
├── Frontend: https://culture-web-staging-xxx.a.run.app
└── Backend:  https://culture-rails-staging-xxx.a.run.app

Production:
├── Frontend: https://culture-web-prod-xxx.a.run.app
└── Backend:  https://culture-rails-prod-xxx.a.run.app
```

## 環境変数

### フロントエンド (culture-web)

| 変数名 | Staging | Production |
|-------|---------|------------|
| `NODE_ENV` | production | production |
| `NEXTAUTH_URL` | Staging URL | Production URL |
| `NEXTAUTH_SECRET` | Secret Manager | Secret Manager |
| `CULTURE_RAILS_API_URL` | Staging Rails URL | Production Rails URL |
| `GOOGLE_GEMINI_API_KEY` | Secret Manager | Secret Manager |

### バックエンド (culture_rails)

| 変数名 | Staging | Production |
|-------|---------|------------|
| `RAILS_ENV` | production | production |
| `DATABASE_URL` | Secret Manager | Secret Manager |
| `SECRET_KEY_BASE` | Secret Manager | Secret Manager |
| `RAILS_LOG_TO_STDOUT` | true | true |

## Secret Manager

機密情報はGoogle Cloud Secret Managerで管理されます。

```
projects/<project-id>/secrets/
├── culture-web-staging-nextauth-secret
├── culture-web-staging-gemini-api-key
├── culture-web-prod-nextauth-secret
├── culture-web-prod-gemini-api-key
├── culture-rails-staging-database-url
├── culture-rails-staging-secret-key-base
├── culture-rails-prod-database-url
└── culture-rails-prod-secret-key-base
```

## ネットワーク構成

### Cloud Run設定

```hcl
resource "google_cloud_run_service" "culture_web" {
  name     = "culture-web-${var.environment}"
  location = "asia-northeast1"

  template {
    spec {
      containers {
        image = var.image_url

        resources {
          limits = {
            cpu    = var.cpu
            memory = var.memory
          }
        }

        env {
          name  = "NEXTAUTH_URL"
          value = var.nextauth_url
        }

        env {
          name = "NEXTAUTH_SECRET"
          value_from {
            secret_key_ref {
              name = "nextauth-secret"
              key  = "latest"
            }
          }
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = var.min_instances
        "autoscaling.knative.dev/maxScale" = var.max_instances
      }
    }
  }
}
```

### CORS設定

Rails側でフロントエンドのオリジンを許可します。

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['FRONTEND_URL']

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
```

## モニタリング

Cloud RunのメトリクスはGoogle Cloud Consoleで確認できます。

- **リクエスト数**: 1分あたりのリクエスト数
- **レイテンシ**: p50, p95, p99のレスポンス時間
- **エラー率**: 5xx/4xxエラーの割合
- **インスタンス数**: 現在のコンテナインスタンス数
- **CPU/メモリ使用率**: リソース使用状況

## ログ

Cloud Loggingでログを確認できます。

```bash
# フロントエンドのログ
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=culture-web-staging" --limit=50

# バックエンドのログ
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=culture-rails-staging" --limit=50
```
