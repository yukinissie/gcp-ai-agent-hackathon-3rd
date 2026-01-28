# フロントエンド (culture-web)

## 概要

culture-webは、Next.js 15とReact 19を使用したモダンなWebフロントエンドです。App RouterとServer Componentsを活用し、高速なユーザー体験を提供します。

## ディレクトリ構造

```
culture-web/
├── src/
│   ├── app/
│   │   ├── (anonymous)/       # 未認証ページ
│   │   │   ├── _actions/      # Server Actions
│   │   │   ├── _components/   # ログイン/登録コンポーネント
│   │   │   └── page.tsx
│   │   ├── (authorized)/      # 認証済みページ
│   │   │   ├── home/          # メインページ
│   │   │   │   ├── @articles/ # 記事リストスロット
│   │   │   │   ├── @chatSideBar/ # チャットスロット
│   │   │   │   └── layout.tsx
│   │   │   ├── articles/[id]/ # 記事詳細ページ
│   │   │   └── test/          # テストエンドポイント
│   │   ├── (public)/          # 公開ページ
│   │   └── api/
│   │       ├── auth/[...nextauth]/
│   │       ├── home/agent/
│   │       └── news/agent/
│   ├── mastra/
│   │   ├── agents/            # AIエージェント定義
│   │   ├── tools/             # エージェントツール
│   │   └── lib/storage.ts
│   ├── lib/
│   │   ├── apiClient.ts       # 統一APIクライアント
│   │   └── zod.ts             # バリデーションスキーマ
│   ├── types/
│   └── middleware.ts          # 認証ミドルウェア
├── package.json
├── next.config.ts
└── biome.json
```

## ルートグループ

### (anonymous) - 未認証ページ
ログインや登録など、認証不要のページを配置します。

### (authorized) - 認証済みページ
ホームページや記事詳細など、認証が必要なページを配置します。ミドルウェアで認証状態をチェックします。

### (public) - 公開ページ
利用規約やプライバシーポリシーなど、誰でもアクセス可能なページを配置します。

## Parallel Routes

ホームページでは Parallel Routes を使用し、記事リスト (`@articles`) とチャットサイドバー (`@chatSideBar`) を並列でレンダリングします。

```tsx
// home/layout.tsx
export default function HomeLayout({
  children,
  articles,
  chatSideBar,
}: {
  children: React.ReactNode;
  articles: React.ReactNode;
  chatSideBar: React.ReactNode;
}) {
  return (
    <div>
      {articles}
      {chatSideBar}
      {children}
    </div>
  );
}
```

## APIクライアント

`lib/apiClient.ts` を使用して、Rails APIへのリクエストを統一的に処理します。

```typescript
import { apiClient } from '@/lib/apiClient';

// 使用例
const articles = await apiClient.get('/articles');
const article = await apiClient.post('/articles', { title: '...' });
```

APIクライアントは以下を自動処理します：
- NextAuthセッションからJWTトークンを注入
- エラーハンドリングとログ
- ベースURL設定
- Zodによる型安全なレスポンス検証

## 認証

NextAuth v5を使用し、RailsのJWT認証と連携します。

```typescript
// src/auth.ts
import NextAuth from "next-auth";
import Credentials from "next-auth/providers/credentials";

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    Credentials({
      credentials: {
        email: {},
        password: {},
      },
      authorize: async (credentials) => {
        // Rails APIで認証
      },
    }),
  ],
});
```

## スタイリング

- **CSS Modules**: コンポーネント固有のスタイル
- **Radix Colors**: 一貫したカラーパレット
- **next-themes**: ダークモード対応
