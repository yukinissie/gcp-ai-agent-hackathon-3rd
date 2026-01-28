# 開発コマンド一覧

## フロントエンド (culture-web)

| コマンド | 説明 |
|---------|------|
| `npm install` | 依存関係のインストール |
| `npm run dev` | 開発サーバー起動 (localhost:3030) |
| `npm run build` | 本番ビルド |
| `npm run start` | 本番サーバー起動 |
| `npm run lint` | Biomeによるリント |
| `npm run format` | Biomeによるフォーマット |

## バックエンド (culture_rails)

### Dipコマンド（推奨）

| コマンド | 説明 |
|---------|------|
| `dip provision` | 初期セットアップ（DB + 依存関係 + マイグレーション） |
| `dip rails s` | Railsサーバー起動 (localhost:3000) |
| `dip c` | Railsコンソール |
| `dip rspec` | RSpecテスト実行 |
| `dip rubocop` | RuboCopリント |
| `dip brakeman` | セキュリティスキャン |
| `dip bundle` | Bundlerコマンド |
| `dip rails db:migrate` | マイグレーション実行 |
| `dip rails db:seed` | シードデータ投入 |

### Docker Composeコマンド

| コマンド | 説明 |
|---------|------|
| `docker-compose up` | 全サービス起動 |
| `docker-compose up -d` | バックグラウンドで起動 |
| `docker-compose down` | 全サービス停止 |
| `docker-compose logs -f` | ログをフォロー |
| `docker-compose exec web bash` | コンテナにシェルアクセス |

## データベース操作

```bash
# マイグレーション作成
dip rails g migration AddColumnToTable column:type

# マイグレーション実行
dip rails db:migrate

# ロールバック
dip rails db:rollback

# データベースリセット
dip rails db:reset
```

## テスト

```bash
# 全テスト実行
dip rspec

# 特定ファイルのテスト
dip rspec spec/controllers/api/v1/articles_controller_spec.rb

# 特定行のテスト
dip rspec spec/controllers/api/v1/articles_controller_spec.rb:42
```

## コード品質

```bash
# RuboCop（自動修正なし）
dip rubocop

# RuboCop（自動修正あり）
dip rubocop -a

# Brakeman（セキュリティスキャン）
dip brakeman

# Biome（フロントエンド）
npm run lint
npm run format
```

## インフラ管理

```bash
# Terraformの初期化
cd culture-infra/service/culture-web/environments/production
terraform init -backend-config=backend.hcl

# 変更のプレビュー
terraform plan

# 変更の適用
terraform apply

# 出力値の確認
terraform output
```

## Git操作

```bash
# 変更の確認
git status

# 変更のステージング
git add .

# コミット
git commit -m "feat: 機能の説明"

# プッシュ
git push origin <branch-name>
```

## デバッグ

```bash
# Railsログ確認
dip rails log

# PostgreSQLへの接続
dip rails dbconsole

# Railsコンソールでのデバッグ
dip c
> User.first
> Article.count
```
