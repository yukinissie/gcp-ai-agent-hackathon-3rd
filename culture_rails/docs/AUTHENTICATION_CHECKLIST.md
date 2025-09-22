# Rails 8 認証システム実装チェックリスト

## 🚀 クイックスタート（30分で実装）

### ✅ Phase 1: 基盤構築（10分）

- [ ] Rails 8認証ジェネレーター実行
  ```bash
  rails generate authentication
  ```

- [ ] User/UserCredential分離マイグレーション作成
  ```bash
  rails generate migration CreateUserCredentials user:references email_address:string password_digest:string
  ```

- [ ] データベースマイグレーション実行
  ```bash
  rails db:migrate
  ```

### ✅ Phase 2: モデル実装（5分）

- [ ] User モデル
  - [ ] `has_one :user_credential`
  - [ ] `has_many :sessions`
  - [ ] `human_id` 自動生成
  - [ ] `as_json_for_api` メソッド

- [ ] UserCredential モデル  
  - [ ] `belongs_to :user`
  - [ ] `has_secure_password`
  - [ ] email正規化（`normalizes :email_address`）

### ✅ Phase 3: Controller実装（10分）

- [ ] ApplicationController API化
  - [ ] `ActionController::API` 継承
  - [ ] `ActionController::Cookies` include
  - [ ] `ActionController::RequestForgeryProtection` include
  - [ ] `start_new_session_for` メソッド（CSRF Token含む）
  - [ ] `terminate_session` メソッド

- [ ] Sessions Controller
  - [ ] `create` アクション（ログイン）
  - [ ] `destroy` アクション（ログアウト）
  - [ ] `show` アクション（セッション確認）
  - [ ] CSRF検証スキップ設定（`skip_before_action :verify_authenticity_token, only: [:create]`）

- [ ] Users Controller
  - [ ] `create` アクション（ユーザー登録）
  - [ ] `show` アクション（ユーザー情報取得）
  - [ ] CSRF検証スキップ設定

### ✅ Phase 4: レスポンス & ルーティング（5分）

- [ ] JSON テンプレート作成（JB形式）
  - [ ] `app/views/api/v1/sessions/create.json.jb`
  - [ ] `app/views/api/v1/sessions/error.json.jb`
  - [ ] `app/views/api/v1/users/create.json.jb`

- [ ] ルーティング設定
  ```ruby
  namespace :api do
    namespace :v1 do
      resource :sessions, only: [:create, :show, :destroy]
      resource :users, only: [:create, :show]
    end
  end
  ```

## 🧪 テスト実装チェックリスト

### ✅ RSpec設定

- [ ] Committee Rails設定（OpenAPI検証）
- [ ] FactoryBot設定（User + UserCredential）
- [ ] テストヘルパー設定

### ✅ テストケース

- [ ] Sessions Controller
  - [ ] ログイン成功/失敗
  - [ ] Cookie設定確認
  - [ ] ログアウト
  - [ ] セッション確認

- [ ] Users Controller  
  - [ ] ユーザー登録成功/失敗
  - [ ] バリデーションエラー
  - [ ] 認証確認

## 🔧 動作確認チェックリスト

### ✅ ローカルテスト

- [ ] サーバー起動（`rails server`）
- [ ] ユーザー登録テスト
  ```bash
  curl -X POST http://localhost:3000/api/v1/users \
    -H "Content-Type: application/json" \
    -c cookies.txt \
    -d '{"user":{"email_address":"test@example.com","password":"password123","password_confirmation":"password123"}}'
  ```

- [ ] ログインテスト
  ```bash
  curl -X POST http://localhost:3000/api/v1/sessions \
    -H "Content-Type: application/json" \
    -b cookies.txt \
    -d '{"email_address":"test@example.com","password":"password123"}'
  ```

- [ ] 認証付きAPIテスト
  ```bash
  curl -X GET http://localhost:3000/api/v1/users \
    -H "Content-Type: application/json" \
    -b cookies.txt
  ```

### ✅ Cookie確認

- [ ] `session_token` 設定確認
- [ ] `csrf_token` 設定確認  
- [ ] HttpOnly属性確認
- [ ] SameSite属性確認

## 🛡️ セキュリティチェックリスト

### ✅ CSRF保護

- [ ] 初回ログイン時のCSRF検証スキップ
- [ ] 認証後APIでのCSRF Token検証
- [ ] フロントエンドでの`X-CSRF-Token`ヘッダー送信

### ✅ Cookie設定

- [ ] HttpOnly設定（XSS対策）
- [ ] SameSite=Lax設定（CSRF対策）
- [ ] Secure設定（本番環境HTTPS）
- [ ] 署名付きCookie（改竄防止）

### ✅ パスワード保護

- [ ] bcrypt使用（`has_secure_password`）
- [ ] パスワード長制限
- [ ] email正規化

## ⚡ パフォーマンスチェックリスト

### ✅ データベース

- [ ] email_address にユニークインデックス
- [ ] user_id に外部キー制約
- [ ] sessions テーブルのインデックス最適化

### ✅ セッション管理

- [ ] Current attributes使用
- [ ] 不要セッションの定期削除検討
- [ ] Redis Session Store検討（スケール時）

## 🚀 デプロイチェックリスト

### ✅ 環境設定

- [ ] `SECRET_KEY_BASE` 設定
- [ ] HTTPS強制設定（本番環境）
- [ ] CORS設定（必要に応じて）
- [ ] 環境変数設定

### ✅ 監視・ログ

- [ ] 認証イベントログ
- [ ] セキュリティアラート設定
- [ ] パフォーマンス監視

## 📋 トラブルシューティング

### よくある問題

- [ ] **401 Unauthorized**: CSRF Token不一致
  - 解決: Cookieからトークン取得してヘッダー設定

- [ ] **404 Not Found**: ルーティングエラー
  - 解決: `resource` vs `resources` 確認

- [ ] **Cookie送信失敗**: 認証エラー
  - 解決: `-b cookies.txt` オプション確認

- [ ] **テスト失敗**: Set-Cookie検証
  - 解決: 正規表現マッチング使用

## 🎯 完了確認

### ✅ 最終チェック

- [ ] 全テスト通過（`bundle exec rspec`）
- [ ] 全APIエンドポイント動作確認
- [ ] Cookie認証フロー動作確認
- [ ] セキュリティ設定確認
- [ ] ドキュメント更新

---

**💡 ヒント**: チェックリストを印刷して、実装時にチェックしながら進めると漏れを防げます。

**⏱️ 実装時間目安**: 初回30分、2回目以降15分

**🔗 参考資料**: `docs/AUTHENTICATION_GUIDE.md` で詳細な実装手順を確認