# Culture Infrastructure

このリポジトリは、Culture アプリケーションのインフラストラクチャを Terraform で管理するためのものです。

## 📁 ディレクトリ構造

```
culture-infra/
├── service/
│   └── culture-web/
│       ├── environments/
│       │   ├── production/         # Production 環境
│       │   │   ├── main.tf
│       │   │   ├── variables.tf
│       │   │   ├── outputs.tf
│       │   │   ├── terraform.tfvars.example
│       │   │   ├── mise.toml
│       │   │   └── .gitignore
│       │   └── staging/            # Staging 環境
│       │       ├── main.tf
│       │       ├── variables.tf
│       │       ├── outputs.tf
│       │       ├── terraform.tfvars.example
│       │       ├── mise.toml
│       │       └── .gitignore
│       └── modules/
│           └── culture-web/        # 共通リソース定義
│               ├── main.tf
│               ├── variables.tf
│               ├── outputs.tf
│               ├── terraform.tf
│               └── .gitignore
└── README.md
```

## 🚀 必要な準備

### 1. ツールのインストール

- [mise](https://mise.jdx.dev/) - バージョン管理ツール
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)
- Terraform (mise で管理)

### 2. GCP の設定

```bash
# Google Cloud CLI の認証
gcloud auth login
gcloud auth application-default login

# プロジェクト ID を設定
export PROJECT_ID="your-project-id"
gcloud config set project $PROJECT_ID
```

<!--

**インフラ構築担当が最初に行うだけで良いので開発者は実施不要**

### 3. GCS バケットの作成（初回のみ）

Terraform の状態ファイルを保存するための GCS バケットを作成します。

```bash
# バケット名を設定（グローバルでユニークである必要があります）
export BUCKET_NAME="${PROJECT_ID}-terraform-state"

# GCS バケットを作成
gsutil mb -p $PROJECT_ID gs://$BUCKET_NAME

# バージョニングを有効にする
gsutil versioning set on gs://$BUCKET_NAME
```

-->

## 📋 使用方法

### Production 環境へのデプロイ

1. **環境設定**
   ```bash
   cd culture-infra/service/culture-web/environments/production
   ```

2. **変数ファイルの作成**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **変数ファイルの編集**

実際に設定すべき値は管理者に問い合わせてください。

   ```bash
   # terraform.tfvars を編集
   project_id   = "actual-project-id"
   region       = "asia-northeast1"
   service_name = "culture-web"
   ```

4. **バックエンド設定ファイルの作成**

実際に設定すべき値は管理者に問い合わせてください。

   ```bash
   # backend.hcl を作成して編集
   bucket = "actual-bucket-name"
   prefix = "/path/to/terraform/state"
   ```

5. **Terraform の実行**
   ```bash
   # 初期化
   terraform init -backend-config=backend.hcl

   # プランの確認
   terraform plan

   # 適用
   terraform apply
   ```

### Staging 環境へのデプロイ

1. **環境設定**
   ```bash
   cd culture-infra/service/culture-web/environments/staging
   ```

2. **変数ファイルの作成と編集**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # terraform.tfvars を編集（Project ID は同じ、他の設定は staging 用）
   ```

4. **バックエンド設定ファイルの作成**

実際に設定すべき値は管理者に問い合わせてください。

   ```bash
   # backend.hcl を作成して編集
   bucket = "actual-bucket-name"
   prefix = "/path/to/terraform/state"
   ```

5. **Terraform の実行**
   ```bash
   terraform init -backend-config=backend.hcl
   terraform plan
   terraform apply
   ```

## 🏗️ リソース構成

### 作成されるリソース

- **Google Cloud Run**: アプリケーションのホスティング
- **Artifact Registry**: Docker イメージの保存
- **IAM**: 必要な権限設定
- **APIs**: 必要な Google Cloud APIs の有効化

### 環境ごとの違い

| リソース | Production | Staging |
|----------|------------|---------|
| サービス名 | `culture-web-prod` | `culture-web-staging` |
| 最小インスタンス数 | 1 | 0 |
| 最大インスタンス数 | 20 | 5 |
| CPU | 4 | 2 |
| メモリ | 4Gi | 2Gi |

## 🔧 環境変数

各環境で設定可能な変数：

| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `project_id` | GCP プロジェクト ID | - | ✅ |
| `region` | デプロイ先リージョン | `asia-northeast1` | ❌ |
| `service_name` | Cloud Run サービスのベース名 | `culture-web` | ❌ |

## 📤 出力値

Terraform 実行後に取得できる値：

- `service_url`: Cloud Run サービスの URL
- `service_name`: 作成されたサービス名
- `docker_image_url`: Docker イメージの URL

```bash
# 出力値の確認
terraform output
```

## 🛡️ セキュリティ

- `terraform.tfvars` ファイルは `.gitignore` で除外されています
- GCS バックエンドでステートファイルを安全に管理
- IAM 権限は最小限の原則に従って設定

## 🔄 CI/CD 統合

GitHub Actions などの CI/CD パイプラインで使用する場合：

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.13.2

- name: Terraform Init
  run: terraform init
  working-directory: ./culture-infra/service/culture-web/environments/production

- name: Terraform Plan
  run: terraform plan
  working-directory: ./culture-infra/service/culture-web/environments/production
```

## 📞 トラブルシューティング

### よくある問題

1. **API が有効になっていない**
   ```bash
   gcloud services enable run.googleapis.com
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable artifactregistry.googleapis.com
   ```

2. **権限エラー**
   ```bash
   # サービスアカウントに必要な権限があることを確認
   gcloud projects get-iam-policy $PROJECT_ID
   ```

3. **バックエンドの初期化エラー**
   - GCS バケットが存在することを確認
   - バケット名が terraform.tf で正しく設定されていることを確認

## 🤝 貢献

1. 新しい環境を追加する場合は `environments/` ディレクトリに新しいフォルダを作成
2. 共通リソースの変更は `modules/culture-web/` で行う
3. 環境固有の設定は各環境のディレクトリで行う
