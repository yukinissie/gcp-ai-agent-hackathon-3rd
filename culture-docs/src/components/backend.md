# バックエンド (culture_rails)

## 概要

culture_railsは、Ruby on Rails 8.0をAPIモードで使用したバックエンドサービスです。RESTful APIを提供し、PostgreSQLをデータストアとして使用します。

## ディレクトリ構造

```
culture_rails/
├── app/
│   ├── controllers/api/v1/
│   │   ├── sessions_controller.rb
│   │   ├── users_controller.rb
│   │   ├── user_attributes_controller.rb
│   │   ├── articles_controller.rb
│   │   ├── activities_controller.rb
│   │   ├── tags_controller.rb
│   │   ├── tag_search_histories_controller.rb
│   │   ├── feeds_controller.rb
│   │   └── ping_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── user_credential.rb
│   │   ├── article.rb
│   │   ├── tag.rb
│   │   ├── article_tagging.rb
│   │   ├── activity.rb
│   │   ├── feed.rb
│   │   ├── tag_search_history.rb
│   │   └── json_web_token.rb
│   └── views/api/v1/       # JBテンプレート
├── db/
│   ├── migrate/
│   └── schema.rb
├── spec/                    # RSpecテスト
├── doc/openapi.yml         # OpenAPI仕様
├── Gemfile
├── docker-compose.yml
├── Dockerfile
└── dip.yml
```

## 設計原則

### RESTful設計
標準的なRailsアクション（index, show, create, update, destroy）のみを使用します。

### ビジネスロジックの配置
Service Classは使用せず、すべてのビジネスロジックはモデル（`app/models/`）に配置します。

### OpenAPI準拠
すべてのエンドポイントはOpenAPIスキーマで定義し、`additionalProperties: false`を指定します。

### TDDアプローチ
実装前にテストを記述し、Committee Railsで自動的にリクエスト/レスポンスを検証します。

## 認証システム

### JWT認証

```ruby
# app/models/json_web_token.rb
class JsonWebToken
  def self.encode(payload)
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.credentials.secret_key_base)
  end
end
```

### 認証フロー

1. `POST /api/v1/sessions` でログイン
2. JWTトークンを発行
3. リクエストヘッダーに `Authorization: Bearer <token>` を付与
4. コントローラーでトークンを検証

## 記事評価ロジック

Good/Bad評価は排他的に動作します。

```ruby
# app/models/activity.rb
class Activity < ApplicationRecord
  # Good評価時、既存のBad評価を自動削除
  # Bad評価時、既存のGood評価を自動削除
end
```

## コード品質

- **RuboCop Rails Omakase**: Rails推奨のスタイルガイド
- **Brakeman**: セキュリティ脆弱性スキャン
- **RSpec + FactoryBot**: テストフレームワーク
- **Committee Rails**: OpenAPI検証
