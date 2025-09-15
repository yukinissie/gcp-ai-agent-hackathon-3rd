# Rails API認証システム設定ガイド

## 認証システム概要

### 技術スタック
- **認証Gem**: Sorcery
- **JSONレスポンス**: jb gem（.jbファイル形式）
- **CSRF保護**: API用に無効化済み
- **テスト**: RSpec + Committee Rails（OpenAPI検証）

### APIエンドポイント
- `POST /api/v1/session` - ログイン
- `DELETE /api/v1/session` - ログアウト

## アーキテクチャ

### Controller構成
```
Api::V1::BaseController
├── CSRF保護無効化
└── protect_from_forgery with: :null_session

Api::V1::SessionsController < Api::V1::BaseController
├── POST #create - ログイン処理
└── DELETE #destroy - ログアウト処理
```

### レスポンステンプレート（jb形式）
- `create.json.jb` - ログイン成功時（OpenAPI準拠）
- `error.json.jb` - ログイン失敗時（OpenAPI準拠）
- `destroy.json.jb` - ログアウト時（OpenAPI準拠）

### レスポンス形式例
```json
// ログイン成功
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "name": "ユーザー名",
      "email": "user@example.com"
    },
    "token": "認証トークン"
  }
}

// エラー時
{
  "success": false,
  "error": "invalid_credentials",
  "message": "メールアドレスまたはパスワードが正しくありません"
}
```

## テスト設定とガイドライン

### RSpec設定
- **設定ファイル**: `spec/rails_helper.rb`
- **Committee Rails**: OpenAPIスキーマ検証を一元管理
- **対象テストタイプ**: `:request`, `:controller`
- **スキーマファイル**: `doc/openapi.yml`

### テスト記述ガイドライン（Tコラ準拠）

#### 基本構造テンプレート
```ruby
RSpec.describe 'Api::V1::Sessions', type: :request do
  describe 'POST #create' do
    context '正しいパスワードとメールアドレスを受け取った時' do
      let!(:user) { create(:user, password: 'password123') }
      let(:email) { user.email }
      let(:password) { 'password123' }
      let(:expected_response) do
        {
          success: true,
          data: {
            user: {
              id: user.id,
              name: user.name,
              email: user.email
            },
            token: "dummy_token_for_now"
          }
        }
      end

      it '正しいセッション情報が返ること' do
        post '/api/v1/session', params: { email: email, password: password }, as: :json
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end
  end
end
```

#### テスト記述ルール

**1. describe/context/itの使い分け**
- `describe`: テスト対象の説明（`POST #create`）
- `context`: 実行条件や状態（`正しいパスワードを受け取った時`）
- `it`: 期待する結果（`正しいセッション情報が返ること`）

**2. let/let!の活用**
- `let!`: テストで参照するオブジェクト（User作成等）
- `let`: 遅延評価でテストデータ定義（email, password, expected_response）
- 期待値は`expected_response`として明示的に定義

**3. JSONレスポンス検証**
- `JSON.parse(response.body, symbolize_names: true)`でシンボルキーに統一
- 期待値はRubyのシンボル記法（`success: true`）で記述
- `assert_schema_conform(status_code)`でOpenAPI準拠を検証

**4. テストデータの明示化**
- `email`、`password`等のパラメータをletで明示
- テストの意図を明確にするため、ハードコードを避ける
- 各contextごとに適切な値を設定

**5. Committee Rails活用**
- `assert_schema_conform`でOpenAPIスキーマ検証を必須化
- `rails_helper.rb`で設定を一元管理
- 個別テストファイルでの重複設定を排除

#### 参考資料とベストプラクティス

**RSpecスタイルガイド（willnet版）の要点**
- `describe`の引数にはテストの対象を書く（メソッド名やクラス名）
- `context`の引数にはテストが実行される際の前提条件や状態を書く
- `let!`はテストで参照するオブジェクト用、`before`は直接参照しないセットアップ用
- FactoryBotではテストに直接関係ない属性値の指定は避ける
- 時間のテストでは絶対時間より相対時間を使う

**ログミーTech - RSpecベストプラクティス**
- **脳内メモリを使わないテストコードほどリーダブル**
- テストコードは実行可能なAPIドキュメントとして扱う
- 複雑な変数や動的計算を避け、直接的でハードコードされた値を使用
- 過度なDRY化よりも読みやすさを優先する
- 非プログラマーでも読めるような明確で明示的な例を書く

**当プロジェクトでの適用**
```ruby
# Good: 明示的で読みやすい
let(:email) { "test@example.com" }
let(:password) { "password123" }
let(:expected_response) do
  {
    success: true,
    data: { user: { id: 1, name: "テストユーザー" } }
  }
end

# Bad: 複雑で脳内メモリを消費
let(:response_data) { JSON.parse(last_response.body).dig("data", "user") }
```

**参考リンク**
#### ベストプラクティス

**RSpecスタイルガイド（willnet版）の要点**
- `describe`の引数にはテストの対象を書く（メソッド名やクラス名）
- `context`の引数にはテストが実行される際の前提条件や状態を書く
- `let!`はテストで参照するオブジェクト用、`before`は直接参照しないセットアップ用
- FactoryBotではテストに直接関係ない属性値の指定は避ける
- 時間のテストでは絶対時間より相対時間を使う

**ログミーTech - RSpecベストプラクティス**
- **脳内メモリを使わないテストコードほどリーダブル**
- テストコードは実行可能なAPIドキュメントとして扱う
- 複雑な変数や動的計算を避け、直接的でハードコードされた値を使用
- 過度なDRY化よりも読みやすさを優先する
- 非プログラマーでも読めるような明確で明示的な例を書く

#### Good/Badパターン

```ruby
# Good: 明示的で読みやすい
let(:email) { "test@example.com" }
let(:password) { "password123" }
let(:expected_response) do
  {
    success: true,
    data: {
      user: {
        id: user.id,
        name: user.name,
        email: user.email
      }
    }
  }
end

# Bad: 複雑で脳内メモリを消費
let(:response_data) { JSON.parse(last_response.body).dig("data", "user") }
let(:user_params) { { email: generate_email, password: SecureRandom.hex } }
```

## 開発フロー

### コミットメッセージガイドライン
- **言語**: 日本語を使用
- **形式**: `機能: 簡潔な説明`
- **例**: 
  - `feat: Sorcery認証システムを実装`
  - `test: セッション管理のテストを追加`
  - `docs: 認証システムのドキュメントを更新`
  - `refactor: 未使用ファイルを削除`
  - `chore: 依存関係を更新`

### 1. 新規APIエンドポイント追加時
1. OpenAPIスキーマ（`doc/openapi.yml`）を更新
2. Controllerとアクションを実装
3. .jbテンプレートを作成
4. FactoryBotでテストデータ準備
5. RSpecテスト作成（上記ガイドライン準拠）
6. `assert_schema_conform`でスキーマ検証確認

### 2. テスト実行
```bash
# 認証関連テスト実行
bundle exec rspec spec/controllers/api/v1/sessions_controller_spec.rb

# 全APIテスト実行
bundle exec rspec spec/requests/
```

## 参考資料
- [RSpecスタイルガイド](https://github.com/willnet/rspec-style-guide)
- [ログミーTech - RSpecベストプラクティス](https://logmi.jp/main/technology/327449)
- [Committee Rails](https://github.com/willnet/committee-rails)
- [Sorcery](https://github.com/Sorcery/sorcery)
- [jb gem](https://github.com/amatsuda/jb)