# データベース設計

## ER図

```
┌─────────────┐       ┌──────────────────┐
│   users     │       │ user_credentials │
├─────────────┤       ├──────────────────┤
│ id (PK)     │◄──────│ user_id (FK)     │
│ human_id    │       │ email_address    │
│ created_at  │       │ password_digest  │
│ updated_at  │       │ created_at       │
└──────┬──────┘       │ updated_at       │
       │              └──────────────────┘
       │
       │
       ▼
┌─────────────┐       ┌─────────────┐
│ activities  │       │  articles   │
├─────────────┤       ├─────────────┤
│ id (PK)     │       │ id (PK)     │
│ user_id(FK) │       │ title       │
│ article_id  │◄──────│ summary     │
│ activity_   │       │ content     │
│    type     │       │ author      │
│ action      │       │ source_url  │
│ created_at  │       │ image_url   │
│ updated_at  │       │ published   │
└─────────────┘       │ published_at│
                      │ created_at  │
                      │ updated_at  │
                      └──────┬──────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       │                     │                     │
       ▼                     ▼                     │
┌──────────────────┐  ┌─────────────────┐         │
│ article_taggings │  │      tags       │         │
├──────────────────┤  ├─────────────────┤         │
│ article_id (FK)  │──│ id (PK)         │         │
│ tag_id (FK)      │──│ name            │         │
│ created_at       │  │ category        │         │
│ updated_at       │  │ created_at      │         │
└──────────────────┘  │ updated_at      │         │
                      └────────┬────────┘         │
                               │                  │
                               ▼                  │
                      ┌───────────────────────┐   │
                      │ tag_search_histories  │   │
                      ├───────────────────────┤   │
                      │ id (PK)               │   │
                      │ user_id (FK)          │   │
                      │ tag_id (FK)           │   │
                      │ created_at            │   │
                      │ updated_at            │   │
                      └───────────────────────┘   │
                                                  │
                      ┌─────────────┐             │
                      │   feeds     │◄────────────┘
                      ├─────────────┤
                      │ id (PK)     │
                      │ name        │
                      │ url         │
                      │ category    │
                      │ last_       │
                      │  fetched_at │
                      │ created_at  │
                      │ updated_at  │
                      └─────────────┘
```

## テーブル詳細

### users

ユーザーの基本情報を格納します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| human_id | string | UNIQUE, NOT NULL | 外部参照用ID |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

### user_credentials

ユーザーの認証情報を格納します（1:1関係）。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| user_id | bigint | FK, UNIQUE | ユーザーID |
| email_address | string | UNIQUE, NOT NULL | メールアドレス |
| password_digest | string | NOT NULL | パスワードハッシュ（bcrypt） |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

### articles

記事情報を格納します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| title | string | NOT NULL | タイトル |
| summary | text | | 要約 |
| content | text | | 本文 |
| content_format | string | | フォーマット（text/html/markdown） |
| author | string | | 著者 |
| source_url | string | | 元記事URL |
| image_url | string | | サムネイル画像URL |
| published | boolean | DEFAULT false | 公開フラグ |
| published_at | timestamp | | 公開日時 |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

### tags

タグのマスターデータを格納します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| name | string | NOT NULL | タグ名 |
| category | string | NOT NULL | カテゴリ |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

**categoryの値:**
- `tech` - テクノロジー
- `art` - アート
- `music` - 音楽
- `sports` - スポーツ
- `business` - ビジネス
- `science` - 科学
- `lifestyle` - ライフスタイル
- `other` - その他

### article_taggings

記事とタグの多対多関係を管理します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| article_id | bigint | FK | 記事ID |
| tag_id | bigint | FK | タグID |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

### activities

ユーザーの記事評価履歴を格納します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| user_id | bigint | FK | ユーザーID |
| article_id | bigint | FK | 記事ID |
| activity_type | integer | NOT NULL | 評価種別（0: good, 1: bad） |
| action | integer | NOT NULL | アクション（0: add, 1: remove） |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

### tag_search_histories

ユーザーのタグ検索履歴を追跡します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| user_id | bigint | FK | ユーザーID |
| tag_id | bigint | FK | タグID |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

### feeds

RSSフィードソースを管理します。

| カラム | 型 | 制約 | 説明 |
|-------|---|------|------|
| id | bigint | PK | 内部ID |
| name | string | NOT NULL | フィード名 |
| url | string | NOT NULL | フィードURL |
| category | string | | カテゴリ |
| last_fetched_at | timestamp | | 最終取得日時 |
| created_at | timestamp | NOT NULL | 作成日時 |
| updated_at | timestamp | NOT NULL | 更新日時 |

## インデックス

```sql
-- ユーザー検索
CREATE UNIQUE INDEX index_users_on_human_id ON users (human_id);
CREATE UNIQUE INDEX index_user_credentials_on_email_address ON user_credentials (email_address);

-- 記事検索
CREATE INDEX index_articles_on_published ON articles (published);
CREATE INDEX index_articles_on_published_at ON articles (published_at);

-- 関連テーブル
CREATE INDEX index_article_taggings_on_article_id ON article_taggings (article_id);
CREATE INDEX index_article_taggings_on_tag_id ON article_taggings (tag_id);
CREATE INDEX index_activities_on_user_id ON activities (user_id);
CREATE INDEX index_activities_on_article_id ON activities (article_id);
```
