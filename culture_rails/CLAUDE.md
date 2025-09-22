# Rails API開発ガイド

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

### 技術スタック
- **認証方式**: bcrypt + JWT（自作認証）
- **JSONレスポンス**: jb gem（.jbファイル形式）
- **CSRF保護**: API用に無効化済み
- **テスト**: RSpec + Committee Rails（OpenAPI検証）

### APIエンドポイント
- `POST /api/v1/session` - ログイン（JWT返却）
- `DELETE /api/v1/session` - ログアウト（JWT無効化）

## テーブル設計（Profile中心設計）

```sql
users (アイデンティティ中核)
├── id (PK)
├── human_id (外部参照用, unique)  
├── created_at, updated_at

user_credentials (認証情報)
├── id (PK)
├── user_id (FK) → users.id (1:1関係)
├── email_address (unique)
├── password_digest (bcrypt)
├── created_at, updated_at

articles (記事情報)
├── id (PK)
├── title, summary, content, content_format
├── author, source_url, image_url
├── published (boolean), published_at
├── created_at, updated_at

tags (タグ情報)
├── id (PK)
├── name (タグ名)
├── category (カテゴリ: tech, art, music, etc.)
├── created_at, updated_at

article_taggings (記事-タグ関連)
├── article_id (FK)
├── tag_id (FK)
├── created_at, updated_at

activities (評価履歴)
├── id (PK)
├── user_id (FK)
├── article_id (FK)
├── activity_type (integer: good=0, bad=1)
├── action (integer: add=0, remove=1)
├── created_at, updated_at
```

## Controller設計ガイドライン

### Rails標準アクションの厳守

**基本方針**: RESTful設計とRails標準のアクションのみを使用

#### 標準アクション一覧
```ruby
# 標準の7つのアクション（Rails標準）
resources :articles do
  # index   - GET    /articles
  # show    - GET    /articles/:id
  # new     - GET    /articles/new     (API不要)
  # create  - POST   /articles
  # edit    - GET    /articles/:id/edit (API不要)
  # update  - PUT    /articles/:id
  # destroy - DELETE /articles/:id
end
```

#### 評価機能の正しい設計
```ruby
# Good: Rails標準アクションのみ使用
resources :articles do
  resources :activities, only: [:index, :create, :destroy]
end

# ルーティング例
# GET    /api/v1/activities                         # 評価履歴一覧
# POST   /api/v1/articles/:id/activities           # 評価作成
# DELETE /api/v1/articles/:id/activities/:id       # 評価削除
```

#### Controller実装ガイドライン

**1. 単一責任の原則**
- 1つのControllerは1つのリソースのみを扱う

**2. パラメータベースの分岐**
```ruby
# Good: パラメータで動作を分岐
def create
  case params[:activity_type]
  when 'good'
    @activity = Activity.add_good(current_user, @article)
  when 'bad' 
    @activity = Activity.add_bad(current_user, @article)
  end
end
```

**3. 排他制御の実装**
- Good評価時：既存のBad評価を自動削除
- Bad評価時：既存のGood評価を自動削除
- Model層で排他制御ロジックを実装

### 実装禁止事項

❌ **カスタムアクションの追加**
❌ **非RESTfulなURL設計**
❌ **複数リソースを混在させるController**
❌ **before_actionでの複雑な処理分岐**

### 実装推奨事項

✅ **Rails標準の7アクション（index, show, new, create, edit, update, destroy）のみ**
✅ **ネストしたリソースでの関係性表現**
✅ **パラメータベースでの動作制御**
✅ **単一責任の原則に基づくController設計**

## API開発手順（TDD）

### 実装フロー
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

### API定義時の必須設定（Committee Rails準拠）

- **`additionalProperties: false`**: すべてのオブジェクトスキーマに必須
- **`required`配列**: 必須プロパティを明確に定義
- **具体的な`example`値**: 日本語での分かりやすいサンプルデータ
- **`enum`制約**: 値を厳密に制限

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
```

## テスト設計ガイドライン

### RSpec設定
- **Committee Rails**: OpenAPIスキーマ検証を一元管理
- **対象テストタイプ**: `:request`, `:controller`
- **スキーマファイル**: `doc/openapi.yml`

### テスト記述ルール

**1. describe/context/itの使い分け**
- `describe`: テスト対象の説明（`POST #create`）
- `context`: 実行条件や状態（`正しいパスワードを受け取った時`）
- `it`: 期待する結果（`正しいセッション情報が返ること`）

**2. let/let!の活用**
- `let!`: テストで参照するオブジェクト（User作成等）
- `let`: 遅延評価でテストデータ定義
- 期待値は`expected_response`として明示的に定義

**3. JSONレスポンス検証**
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

it '正しいセッション情報が返ること' do
  post '/api/v1/session', params: { email: email, password: password }, as: :json
  expect(response).to have_http_status(:ok)
  assert_schema_conform(200)
  expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
end
```

### テスト実行
```bash
# 認証関連テスト実行
bundle exec rspec spec/controllers/api/v1/sessions_controller_spec.rb

# 全APIテスト実行
bundle exec rspec spec/requests/
```

## コミットメッセージガイドライン
- **言語**: 日本語を使用
- **形式**: `機能: 簡潔な説明`
- **例**: 
  - `feat: Activities機能の基盤実装`
  - `test: 記事評価のテストを追加`
  - `docs: API仕様書を更新`
  - `refactor: 未使用ファイルを削除`

## 参考資料
- [RSpecスタイルガイド](https://github.com/willnet/rspec-style-guide)
- [ログミーTech - RSpecベストプラクティス](https://logmi.jp/main/technology/327449)
- [Committee Rails](https://github.com/willnet/committee-rails)
- [jb gem](https://github.com/amatsuda/jb)