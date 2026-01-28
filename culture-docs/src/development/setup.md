# 開発環境のセットアップ

## 前提条件

以下のツールがインストールされている必要があります：

- **Node.js** 20.x 以上
- **npm** 10.x 以上
- **Ruby** 3.2.x 以上
- **Docker** 24.x 以上
- **Docker Compose** 2.x 以上

## フロントエンド (culture-web)

### 1. 依存関係のインストール

```bash
cd culture-web
npm install
```

### 2. 環境変数の設定

`.env.local` ファイルを作成します：

```env
NEXTAUTH_URL=http://localhost:3030
NEXTAUTH_SECRET=your-secret-key
CULTURE_RAILS_API_URL=http://localhost:3000
GOOGLE_GEMINI_API_KEY=your-gemini-api-key
```

### 3. 開発サーバーの起動

```bash
npm run dev
```

ブラウザで http://localhost:3030 にアクセスできます。

## バックエンド (culture_rails)

### 1. Dipのインストール（推奨）

```bash
gem install dip
```

### 2. 初期セットアップ

```bash
cd culture_rails
dip provision
```

このコマンドは以下を実行します：
- Docker Compose でコンテナを起動
- Bundlerで依存関係をインストール
- データベースの作成とマイグレーション

### 3. 開発サーバーの起動

```bash
dip rails s
```

http://localhost:3000 でAPIが利用可能になります。

## Docker Composeを直接使用する場合

```bash
cd culture_rails

# コンテナの起動
docker-compose up -d

# データベースのセットアップ
docker-compose exec web bundle exec rails db:create db:migrate

# Railsサーバーの起動
docker-compose exec web bundle exec rails s -b 0.0.0.0
```

## 動作確認

### APIヘルスチェック

```bash
curl http://localhost:3000/api/v1/ping
# => {"message":"pong"}
```

### フロントエンドアクセス

ブラウザで http://localhost:3030 にアクセスし、ログインページが表示されることを確認します。

## トラブルシューティング

### ポートが使用中の場合

```bash
# 使用中のポートを確認
lsof -i :3000
lsof -i :3030

# プロセスを終了
kill -9 <PID>
```

### データベース接続エラー

```bash
# PostgreSQLコンテナの状態を確認
docker-compose ps

# ログを確認
docker-compose logs db
```

### 依存関係のリセット

```bash
# フロントエンド
rm -rf node_modules && npm install

# バックエンド
dip bundle install
```
