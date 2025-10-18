# Rails API + Next.js認証実装（Sorcery使用）

## 概要

Rails API + Google Cloud + Next.jsの構成で、SorceryGemとJWTを使用した認証機能の実装方法。DHHの思想に沿ったシンプルな設計を採用。

## 技術選定

- **認証Gem**: SorceryGem（軽量でシンプル）
- **トークン**: JWT（ステートレス）
- **設計思想**: DHH流（Fat Model, Skinny Controller）

## 実装

### 1. Gemの設定

ruby

```ruby
*# Gemfile*
gem 'sorcery'
gem 'jwt'
gem 'rack-cors' *# CORS設定用# bundle install後*
rails generate sorcery:install
```

### 2. マイグレーション・Userモデル

ruby

```ruby
*# マイグレーションファイル*
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email,            null: false, index: { unique: true }
      t.string :crypted_password
      t.string :salt
      t.string :name
      t.timestamps
    end
  end
end
```

ruby

```ruby
*# app/models/user.rb*
class User < ApplicationRecord
  authenticates_with_sorcery!

  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  *# 認証メソッド（Sorceryを活用）*
  def self.authenticate(email, password)
    authenticate(email, password) *# Sorceryのメソッドを直接使用*
  end

  *# トークンからユーザーを取得*
  def self.find_by_token(token)
    return nil if token.blank?

    decoded = JsonWebToken.decode(token)
    return nil unless decoded

    find_by(id: decoded[:user_id])
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    nil
  end

  *# JWTトークン生成*
  def generate_token
    JsonWebToken.encode(user_id: id)
  end

  *# API用レスポンス*
  def as_json_for_api
    { id: id, name: name, email: email }
  end

  private

  def password_required?
    new_record? || password.present?
  end
end
```

### 3. JWT処理（PORO）

ruby

```ruby
*# app/lib/json_web_token.rb*
class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base.to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    payload[:iat] = Time.current.to_i *# 発行時刻も記録*
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end
end
```

### 4. ApplicationController（認証基盤）

ruby

```ruby
*# app/controllers/application_controller.rb*
class ApplicationController < ActionController::API
  private

  def authenticate
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = User.find_by_token(token) if token
  end

  def require_authentication
    authenticate
    render json: { success: false, error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  attr_reader :current_user
end
```

### 5. セッション管理（認証エンドポイント）

ruby

```ruby
*# app/controllers/api/v1/sessions_controller.rb*
class Api::V1::SessionsController < ApplicationController
  *# ログイン*
  def create
    user = User.authenticate(params[:email], params[:password])

    if user
      render json: {
        success: true,
        data: {
          user: user.as_json_for_api,
          token: user.generate_token
        }
      }
    else
      render json: {
        success: false,
        error: 'Invalid credentials'
      }, status: :unauthorized
    end
  end

  *# ログアウト（クライアント側でトークン削除）*
  def destroy
    render json: { success: true, message: 'Logged out successfully' }
  end
end
```

### 6. ユーザー管理

ruby

```ruby
*# app/controllers/api/v1/users_controller.rb*
class Api::V1::UsersController < ApplicationController
  before_action :require_authentication, except: [:create]

  *# ユーザー登録*
  def create
    user = User.new(user_params)

    if user.save
      render json: {
        success: true,
        data: {
          user: user.as_json_for_api,
          token: user.generate_token
        }
      }, status: :created
    else
      render json: {
        success: false,
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  *# ユーザー情報取得*
  def show
    render json: {
      success: true,
      data: current_user.as_json_for_api
    }
  end

  *# ユーザー情報更新*
  def update
    if current_user.update(user_update_params)
      render json: {
        success: true,
        data: current_user.as_json_for_api
      }
    else
      render json: {
        success: false,
        errors: current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def user_update_params
    params.require(:user).permit(:name, :email)
  end
end
```

### 7. ルーティング

ruby

```ruby
*# config/routes.rb*
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      *# 認証関連*
      resource :session, only: [:create, :destroy]
      resources :users, only: [:create, :show, :update]

      *# その他の認証が必要なリソース# resources :posts, only: [:index, :create, :show, :update, :destroy]*
    end
  end
end
```

### 8. CORS設定

ruby

```ruby
*# config/initializers/cors.rb*
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' *# Next.jsの開発サーバー*
    resource '*', headers: :any, methods: [:get, :post, :patch, :put, :delete, :options]
  end
end
```

## 使用例

### ユーザー登録

bash

```tsx
POST /api/v1/users
{
  "user": {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }
}
```

### ログイン

bash

```tsx
POST /api/v1/session
{
  "email": "john@example.com",
  "password": "password123"
}
```

### 認証が必要なリクエスト

bash

```tsx
GET /api/v1/users/1
Authorization: Bearer <JWT_TOKEN>
```

## セルフレビュー結果

### ✅ 良い点

- DHHの思想に沿った設計（Fat Model, Skinny Controller）
- Controllerが薄く、Modelに適切にロジックを配置
- concernを避けてシンプルな実装
- 認証の流れがクリア
- エラーハンドリングがシンプル

### ⚠️ 改善点を適用済み

- Sorceryの機能を適切に活用
- JWTのエラーハンドリング強化
- パスワード変更時の考慮
- APIレスポンスの一貫性確保
- トークンの有効期限管理

### 🤔 Next.js連携での考慮点

- CORS設定済み
- 統一されたAPIレスポンス形式
- リフレッシュトークンは必要に応じて後から追加可能
