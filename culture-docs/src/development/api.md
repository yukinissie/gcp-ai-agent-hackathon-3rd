# API仕様

完全なAPI仕様は `culture_rails/doc/openapi.yml` を参照してください。

## 認証

### ユーザー登録

```http
POST /api/v1/users
Content-Type: application/json

{
  "user": {
    "email_address": "user@example.com",
    "password": "password123"
  }
}
```

**レスポンス:**
```json
{
  "id": 1,
  "human_id": "abc123",
  "email_address": "user@example.com"
}
```

### ログイン

```http
POST /api/v1/sessions
Content-Type: application/json

{
  "email_address": "user@example.com",
  "password": "password123"
}
```

**レスポンス:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "human_id": "abc123"
  }
}
```

### ログアウト

```http
DELETE /api/v1/sessions
Authorization: Bearer <token>
```

### ユーザー情報取得

```http
GET /api/v1/user_attributes
Authorization: Bearer <token>
```

## 記事

### 記事一覧取得

```http
GET /api/v1/articles
Authorization: Bearer <token>
```

**クエリパラメータ:**
- `page` - ページ番号
- `per_page` - 1ページあたりの件数
- `tag_id` - タグでフィルタリング

### 記事詳細取得

```http
GET /api/v1/articles/:id
Authorization: Bearer <token>
```

### 記事作成

```http
POST /api/v1/articles
Authorization: Bearer <token>
Content-Type: application/json

{
  "article": {
    "title": "記事タイトル",
    "summary": "要約",
    "content": "本文",
    "source_url": "https://example.com/article",
    "published": true
  }
}
```

### 記事更新

```http
PUT /api/v1/articles/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "article": {
    "title": "更新後のタイトル"
  }
}
```

### 記事削除

```http
DELETE /api/v1/articles/:id
Authorization: Bearer <token>
```

## 記事評価

### 評価を追加

```http
POST /api/v1/articles/:article_id/activities
Authorization: Bearer <token>
Content-Type: application/json

{
  "activity": {
    "activity_type": "good",
    "action": "add"
  }
}
```

**activity_type:**
- `good` (0) - 良い評価
- `bad` (1) - 悪い評価

**action:**
- `add` (0) - 評価を追加
- `remove` (1) - 評価を削除

## タグ

### タグ一覧取得

```http
GET /api/v1/tags
Authorization: Bearer <token>
```

**レスポンス:**
```json
{
  "tags": [
    {
      "id": 1,
      "name": "AI",
      "category": "tech"
    }
  ]
}
```

## タグ検索履歴

### 検索履歴保存

```http
POST /api/v1/tag_search_histories
Authorization: Bearer <token>
Content-Type: application/json

{
  "tag_id": 1
}
```

### 検索履歴に基づく記事取得

```http
GET /api/v1/tag_search_histories/articles
Authorization: Bearer <token>
```

## フィード

### フィード一覧取得

```http
GET /api/v1/feeds
Authorization: Bearer <token>
```

### フィード作成

```http
POST /api/v1/feeds
Authorization: Bearer <token>
Content-Type: application/json

{
  "feed": {
    "name": "Tech Blog",
    "url": "https://example.com/rss",
    "category": "tech"
  }
}
```

### 単一フィード取得

```http
POST /api/v1/feeds/:id/fetch
Authorization: Bearer <token>
```

### バッチ取得

```http
POST /api/v1/feeds/batch_fetch
Authorization: Bearer <token>
```

## ヘルスチェック

```http
GET /api/v1/ping
```

**レスポンス:**
```json
{
  "message": "pong"
}
```
