# システムアーキテクチャ

## レイヤー構造

Cultureは4層のレイヤー構造で設計されています。

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                            │
│   Next.js 15.5 + React 19 + TypeScript + Radix UI          │
│   App Router, Server Components, Parallel Routes            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   AI Agent Layer                             │
│   Mastra Framework + Google Gemini 2.0 Flash                │
│   - News Curation Agent                                      │
│   - Tag Determination Agent                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Backend Layer                             │
│   Rails 8.0 API + PostgreSQL + NextAuth                     │
│   RESTful API, JWT Auth, OpenAPI Validation                 │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                Infrastructure Layer                          │
│   Google Cloud Run + Artifact Registry + Secret Manager     │
└─────────────────────────────────────────────────────────────┘
```

## データフロー

### 認証フロー

1. ユーザーがログイン情報を入力
2. フロントエンド → Rails API (`POST /api/v1/sessions`)
3. Rails が JWT トークンを発行
4. NextAuth がセッションを管理
5. 以降のリクエストにJWTトークンを付与

### 記事取得フロー

1. ユーザーがホームページにアクセス
2. Server Component が Rails API を呼び出し
3. Rails が PostgreSQL から記事を取得
4. フロントエンドでレンダリング

### AI エージェント対話フロー

1. ユーザーがチャットで質問
2. フロントエンド → `/api/home/agent` または `/api/news/agent`
3. Mastra Framework が Gemini API を呼び出し
4. ストリーミングレスポンスをフロントエンドに返却
5. リアルタイムでUIに表示

## 通信プロトコル

| 通信経路 | プロトコル | 認証方式 |
|---------|----------|---------|
| ブラウザ ↔ Next.js | HTTPS | Cookie (NextAuth) |
| Next.js ↔ Rails | HTTPS | JWT Bearer Token |
| Next.js ↔ Gemini | HTTPS | API Key |
| Cloud Run ↔ Secret Manager | Internal | IAM |

## セキュリティ考慮事項

- **HTTPS必須**: Cloud RunでHTTPS接続を強制
- **JWT認証**: APIリクエストごとにトークン検証
- **CORS設定**: フロントエンドオリジンのみ許可
- **Secret Manager**: 機密情報の安全な管理
