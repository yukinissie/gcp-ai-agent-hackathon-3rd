# 推奨開発コマンド

## フロントエンド開発 (culture-web)

```bash
cd culture-web
npm run dev          # 開発サーバー（Turbopack）
npm run build        # プロダクションビルド
npm run start        # プロダクションサーバー
npm run lint         # Biome linting
npm run format       # Biome formatting
```

## バックエンド開発 (culture_rails)

### Dip 使用（推奨）

```bash
dip provision        # 初期セットアップ（DB + 依存関係 + migration）
dip rails s          # Railsサーバー起動
dip c               # Railsコンソール
dip rspec           # RSpecテスト実行
dip rubocop         # RuboCop linting
dip brakeman        # セキュリティスキャン
dip bundle          # Bundleコマンド
```

### 直接 Docker Compose

```bash
docker-compose up    # 全サービス起動
docker-compose exec web bundle exec rails c  # Railsコンソール
```

## インフラ管理

```bash
cd culture-infra/service/culture-web/environments/production
terraform init -backend-config=backend.hcl
terraform plan       # 変更プレビュー
terraform apply      # インフラ変更適用
terraform output     # アウトプット確認（サービスURL等）
```

## Git 操作（Darwin）

```bash
git status          # ステータス確認
git add .           # 変更をステージング
git commit -m "feat: 機能追加"  # コミット（日本語）
git push origin main  # プッシュ
```

## システム情報（Darwin）

```bash
ls -la              # ファイル一覧
cd [directory]      # ディレクトリ移動
grep -r "pattern" . # パターン検索
find . -name "*.rb" # ファイル検索
```
