# Rails マスターキー Secret Manager セットアップ手順

このドキュメントでは、Rails アプリケーションのマスターキーを GCP Secret Manager に設定する手順を説明します。

## 前提条件

- GCP プロジェクトが設定済み
- `gcloud` CLI がインストール・設定済み
- Rails マスターキーファイル（`culture_rails/config/master.key`）が存在する

## セットアップ手順

### 1. マスターキーを Secret Manager に作成・設定

#### プロダクション環境

```bash
# プロダクション用のシークレットを作成し、マスターキーを設定
cd culture_rails

# Secret Manager にマスターキーを設定
gcloud secrets create culture-rails-master-key-prod \
  --project=YOUR_PROJECT_ID \
  --data-file=config/master.key
```

#### ステージング環境

```bash
# ステージング用のシークレットを作成し、マスターキーを設定
gcloud secrets create culture-rails-master-key-staging \
  --project=YOUR_PROJECT_ID \
  --data-file=config/master.key
```

### 2. Secret Manager のアクセス権限確認

作成されたシークレットが正しく設定されているか確認：

```bash
# プロダクション環境
gcloud secrets versions access latest \
  --secret="culture-rails-master-key-prod" \
  --project=YOUR_PROJECT_ID

# ステージング環境
gcloud secrets versions access latest \
  --secret="culture-rails-master-key-staging" \
  --project=YOUR_PROJECT_ID
```

### 3. Terraform Apply

インフラストラクチャを更新して、Secret Manager のリソースと IAM 設定を適用：

#### プロダクション環境

```bash
cd culture-infra/service/culture-rails/environments/production
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

#### ステージング環境

```bash
cd culture-infra/service/culture-rails/environments/staging
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

### 4. Rails アプリケーションのデプロイ

通常のデプロイプロセスを実行してください。新しいコンテナが起動時に Secret Manager からマスターキーを取得するようになります。

## 動作確認

### 1. ログの確認

Cloud Run のログで以下のメッセージが表示されることを確認：

```
Fetching Rails master key from Secret Manager: culture-rails-master-key-prod
Successfully loaded Rails master key from Secret Manager
Production environment configured to use Secret Manager for master key
```

### 2. エラーの確認

Secret Manager からの取得に失敗した場合、以下のログが表示されます：

```
Failed to load Rails master key from Secret Manager: [エラー詳細]
Application will attempt to use local master key file
```

## トラブルシューティング

### 権限エラーが発生する場合

Cloud Run のデフォルトサービスアカウントに Secret Manager への適切な権限が付与されているか確認：

```bash
# IAM 権限の確認
gcloud projects get-iam-policy YOUR_PROJECT_ID \
  --flatten="bindings[].members" \
  --format="table(bindings.role)" \
  --filter="bindings.members:*compute@developer.gserviceaccount.com"
```

### シークレットが見つからない場合

シークレット名が正しく設定されているか確認：

```bash
# 作成済みシークレットの一覧確認
gcloud secrets list --project=YOUR_PROJECT_ID --filter="name:culture-rails-master-key"
```

## セキュリティ考慮事項

1. **最小権限の原則**: Cloud Run サービスアカウントには Secret Manager の読み取り権限のみ付与
2. **リージョン複製**: シークレットは asia-northeast1 リージョンに複製されます
3. **バージョン管理**: 最新バージョンのシークレットが自動的に使用されます
4. **ローカル開発**: ローカル環境では従来の `master.key` ファイルを継続使用

## 注意事項

- マスターキーは機密情報です。適切に管理してください
- プロダクションとステージングで異なるマスターキーを使用することを推奨します
- Secret Manager のコストが発生します（アクセス回数に応じて課金）
