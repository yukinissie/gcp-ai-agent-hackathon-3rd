# Rails API認証システム設定ガイド

## システム全体アーキテクチャ

### 全体構成図
```
[DNS] → [ロードバランサー] → [Next.js フロントエンド] → [Rails バックエンド]
                              ↓                        ↓
                          [ログ収集]                [RDB/NoSQL/Cache]
                                                      ↓
                          [LLM関連システム] ← [Agent/MCP Server/Tools]
                              ↓
                          [VectorDB]
```

本システムは**NextJS フロントエンド + Rails API バックエンド**の分離型アーキテクチャです。

## 認証システム概要

### 設計方針の変更
- **従来**: Sorcery gem中心の認証
- **新方針**: Profile中心設計 + 自作認証システム（bcrypt + JWT）
- **優先順位**: 
  1. NextJS連携のためのJWT Token返却API
  2. スライド設計思想に基づくテーブル分離
  3. シンプルで拡張性の高い認証システム

### 技術スタック
- **認証方式**: bcrypt + JWT（自作認証）
- **JSONレスポンス**: jb gem（.jbファイル形式）
- **CSRF保護**: API用に無効化済み
- **テスト**: RSpec + Committee Rails（OpenAPI検証）

### APIエンドポイント
- `POST /api/v1/session` - ログイン（JWT返却）
- `DELETE /api/v1/session` - ログアウト（JWT無効化）

## テーブル設計（スライド思想準拠）

### Profile中心設計
```sql
users (アイデンティティ中核)
├── id (PK)
├── uuid (外部参照用)  
├── status (active/inactive/suspended)
├── created_at, updated_at

credentials (認証情報)
├── id (PK)
├── user_id (FK) → users.id (1:1関係)
├── email (unique)
├── password_digest (bcrypt)
├── created_at, updated_at
```

### モデル関係性
- `User.session?` - 認証状態判定メソッド
- `User has_one :credential`
- `Credential belongs_to :user`
- `Credential.authenticate(password)` - パスワード検証

## Controller構成

### API Controller階層
```
Api::V1::BaseController
├── CSRF保護無効化
├── JWT認証ヘルパー
└── protect_from_forgery with: :null_session

Api::V1::SessionsController < Api::V1::BaseController
├── POST #create - ログイン処理（JWT発行）
└── DELETE #destroy - ログアウト処理（JWT無効化）
```

### レスポンステンプレート（jb形式）
- `create.json.jb` - ログイン成功時（OpenAPI準拠）
- `error.json.jb` - ログイン失敗時（OpenAPI準拠）
- `destroy.json.jb` - ログアウト時（OpenAPI準拠）

### レスポンス形式例
```json
// ログイン成功（新設計）
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "uuid": "abc-123-def",
      "status": "active"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
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

### Rails実装手順（TDDアプローチ）

新規APIエンドポイント実装時は以下の手順で進める：

```
1. API定義（OpenAPIスキーマ）
2. Model定義 + FactoryBot設定
3. ルーティング追加  
4. 空Controller追加（基本構造のみ）
5. JB定義（ベタ書き）
6. RSpecテスト作成
7. Controller実装（レッド→グリーン）
8. リファクタリング
```

#### 各段階の詳細

**1. API定義**
- `doc/openapi.yml`でエンドポイント仕様定義
- リクエスト/レスポンス形式を明確化

#### API定義時の必須設定（Committee Rails準拠）

- **`additionalProperties: false`**: すべてのオブジェクトスキーマに必須
  - 意図しないプロパティ（パスワード等の機密情報）の漏洩を防止
  - レスポンスの予測可能性を保証
- **`required`配列**: 必須プロパティを明確に定義
- **具体的な`example`値**: 開発者が理解しやすいサンプルデータを日本語で記載
- **`enum`制約**: status等の値を厳密に制限

```yaml
# Good: 安全で予測可能なスキーマ定義
schema:
  type: object
  additionalProperties: false
  properties:
    user:
      type: object
      additionalProperties: false
      properties:
        id: { type: integer }
        status: { type: string, enum: [active, inactive] }
      required: [id, status]
  required: [user]

# Bad: 機密情報漏洩のリスク
schema:
  type: object
  properties:
    user:
      type: object
      # additionalProperties未設定は危険！
```

**2. Model定義 + FactoryBot**  
- User等の必要モデル作成
- `spec/factories/`でテストデータ定義
- 認証機能の基盤整備

**3-4. ルーティング + 空Controller**
- `config/routes.rb`にエンドポイント追加
- Controller骨格作成（空メソッドで200返すレベル）

**5. JB定義**
- `.json.jb`テンプレートでレスポンス構造定義
- 実装時の調整余地を残す

**6. RSpecテスト**
- 期待値とassert_schema_conformでAPI仕様検証
- この段階では失敗して当然（レッド）

**7-8. 実装 + リファクタリング**
- テストをパスさせる最小実装（グリーン）
- コード品質向上

#### 手順変更の理由

- **Model先行**: FactoryBot動作とController内Model参照エラー回避
- **JB後配置**: Controller実装時のレスポンス構造調整の柔軟性確保
- **TDDサイクル**: 外側から内側への段階的実装でテスト駆動開発を実現

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