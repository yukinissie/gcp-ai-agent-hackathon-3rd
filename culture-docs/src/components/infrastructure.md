# インフラストラクチャ

## 概要

CultureはGoogle Cloud Platform上にデプロイされ、Terraformでインフラを管理しています。

## アーキテクチャ

```
                    ┌─────────────────┐
                    │   Internet      │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Cloud Load    │
                    │   Balancing     │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼───────┐    ┌───────▼───────┐    ┌───────▼───────┐
│   Cloud Run   │    │   Cloud Run   │    │   Cloud SQL   │
│  culture-web  │───▶│ culture-rails │───▶│  PostgreSQL   │
└───────────────┘    └───────────────┘    └───────────────┘
        │                    │
        │                    │
┌───────▼───────┐    ┌───────▼───────┐
│    Gemini     │    │    Secret     │
│      API      │    │    Manager    │
└───────────────┘    └───────────────┘
```

## Terraform構成

```
culture-infra/
├── service/
│   ├── culture-web/
│   │   ├── environments/
│   │   │   ├── production/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   └── backend.hcl
│   │   │   └── staging/
│   │   └── modules/culture-web/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── culture-rails/
│       ├── environments/
│       │   ├── production/
│       │   └── staging/
│       └── modules/culture-rails/
└── README.md
```

## Cloud Run設定

### culture-web

| 設定項目 | Staging | Production |
|---------|---------|------------|
| CPU | 2 | 4 |
| メモリ | 2Gi | 4Gi |
| 最小インスタンス | 0 | 1 |
| 最大インスタンス | 10 | 100 |

### culture-rails

| 設定項目 | Staging | Production |
|---------|---------|------------|
| CPU | 2 | 4 |
| メモリ | 2Gi | 4Gi |
| 最小インスタンス | 0 | 1 |
| 最大インスタンス | 10 | 100 |

## Secret Manager

以下のシークレットがSecret Managerで管理されています：

- `DATABASE_URL` - PostgreSQL接続文字列
- `SECRET_KEY_BASE` - Rails暗号化キー
- `NEXTAUTH_SECRET` - NextAuth暗号化キー
- `GOOGLE_GEMINI_API_KEY` - Gemini APIキー

## Artifact Registry

コンテナイメージはArtifact Registryに保存されます。

```
asia-northeast1-docker.pkg.dev/
└── <project-id>/
    ├── culture-web/
    │   ├── staging
    │   └── production
    └── culture-rails/
        ├── staging
        └── production
```

## リージョン

すべてのリソースは `asia-northeast1`（東京）リージョンにデプロイされます。

## Terraformコマンド

```bash
# 初期化
cd culture-infra/service/culture-web/environments/production
terraform init -backend-config=backend.hcl

# 計画
terraform plan

# 適用
terraform apply

# 出力確認
terraform output
```
