# セッション管理とエラーハンドリング

## 概要

Next.jsアプリケーションでは、NextAuthを使用してセッション管理を行っています。
Rails APIのJWTトークン有効期限が30日の設定ミスがあるため、Next.js側で1日に制限しています。

## セッション有効期限

- **設定**: 24時間（1日）
- **場所**: `src/auth.ts`
- **理由**: Rails側の30日設定を一時的に上書き

```typescript
session: {
  strategy: 'jwt',
  maxAge: 24 * 60 * 60, // 1 day (temporary fix for Rails 30-day token issue)
}
```

## セッション切れ時の動作

### 1. ページアクセス時（ミドルウェア）

セッションが切れた状態でページにアクセスすると：

- `src/middleware.ts`が自動的に`/signin`にリダイレクト
- 元のURLは`callbackUrl`パラメータで保持
- 再ログイン後、元のページに戻る

```typescript
// middleware.ts
if (!isAuthenticated && !isPublicPath) {
  const signinUrl = new URL('/signin', req.url)
  signinUrl.searchParams.set('callbackUrl', pathname)
  return NextResponse.redirect(signinUrl)
}
```

### 2. API呼び出し時

#### Server Component（自動リダイレクト）

Server Componentで`apiClient`を使用した場合、401エラーで自動的に`/signin`にリダイレクトされます。

```typescript
// Server Component
import { apiClient } from '@/lib/apiClient'

export default async function Page() {
  // セッション切れの場合、自動的に /signin にリダイレクト
  const articles = await apiClient.get('/api/v1/articles')
  return <ArticleList articles={articles} />
}
```

#### Client Component（エラーハンドラー使用）

Client Componentでは`handleApiError`または`withErrorHandler`を使用します。

**方法1: try-catchで個別にハンドリング**

```typescript
'use client'

import { apiClient } from '@/lib/apiClient'
import { handleApiError } from '@/lib/errorHandler'

export function MyComponent() {
  const handleClick = async () => {
    try {
      const data = await apiClient.get('/api/v1/articles')
      // 処理...
    } catch (error) {
      // UnauthorizedErrorの場合、自動的に /signin にリダイレクト
      handleApiError(error)
    }
  }

  return <button onClick={handleClick}>記事を取得</button>
}
```

**方法2: withErrorHandlerでラップ**

```typescript
'use client'

import { apiClient } from '@/lib/apiClient'
import { withErrorHandler } from '@/lib/errorHandler'

export function MyComponent() {
  const fetchArticles = withErrorHandler(async () => {
    const data = await apiClient.get('/api/v1/articles')
    // 処理...
  })

  return <button onClick={fetchArticles}>記事を取得</button>
}
```

## エラーの種類

### UnauthorizedError

- **発生条件**: APIが401ステータスを返した場合
- **動作**:
  - Server Component: 自動的に`redirect('/signin')`
  - Client Component: `handleApiError`で`window.location.href`にリダイレクト
- **callbackUrl**: 現在のパスを自動的に保持

### その他のAPIエラー

- **発生条件**: 401以外のHTTPエラーステータス
- **動作**: 通常の`Error`をスロー
- **ハンドリング**: 各コンポーネントで適切にエラー処理を実装

## 実装ファイル

| ファイル | 役割 |
|---------|------|
| `src/auth.ts` | NextAuth設定（セッション有効期限: 1日） |
| `src/middleware.ts` | 認証チェックとリダイレクト |
| `src/lib/apiClient.ts` | API呼び出しと401エラーハンドリング |
| `src/lib/errorHandler.ts` | Client Component用エラーハンドラー |

## 注意事項

- Rails側の30日トークン有効期限は一時的な設定ミスです
- Rails側の修正後、`src/auth.ts`の`maxAge`設定を削除できます
- セッションはJWTベースで、サーバー側での管理は行いません
