# AIエージェント

## 概要

Cultureは、Mastra Frameworkを使用してAIエージェントを管理し、Google Gemini 2.0 Flashで自然言語処理を行います。

## エージェント構成

### News Curation Agent
ユーザーとの対話を通じて、興味のあるニュースを発見・推薦するエージェントです。

```typescript
// src/mastra/agents/news-curation-agent.ts
export const newsCurationAgent = {
  name: 'newsCurationAgent',
  model: 'gemini-2.0-flash',
  instructions: `
    あなたはニュースキュレーションの専門家です。
    ユーザーの興味に基づいて関連する記事を提案してください。
  `,
  tools: [...],
};
```

### Tag Determination Agent
記事の内容を分析し、適切なタグを決定するエージェントです。

```typescript
// src/mastra/agents/determine-tags-agent.ts
export const determineTagsAgent = {
  name: 'determineTagsAgent',
  model: 'gemini-2.0-flash',
  instructions: `
    記事の内容を分析し、適切なカテゴリタグを決定してください。
  `,
};
```

## ツール

エージェントは以下のツールを使用して外部システムと連携します。

```
culture-web/src/mastra/tools/
├── search-articles.ts    # 記事検索
├── get-user-history.ts   # ユーザー履歴取得
└── recommend-articles.ts # 記事推薦
```

## APIエンドポイント

### `/api/home/agent`
ホーム画面のチャット機能で使用されるエンドポイントです。

```typescript
// src/app/api/home/agent/route.ts
import { mastra } from '@/mastra';

export async function POST(request: Request) {
  const { message } = await request.json();
  const agent = mastra.getAgent('newsCurationAgent');
  const response = await agent.generate(message);
  return new Response(response.text);
}
```

### `/api/news/agent`
ニュース関連の処理を行うエンドポイントです。

## 使用パターン

```typescript
import { mastra } from '@/mastra';

// エージェントを取得
const agent = mastra.getAgent('newsCurationAgent');

// テキスト生成
const response = await agent.generate(userMessage);

// ストリーミングレスポンス
const stream = await agent.stream(userMessage);
```

## メモリストレージ

対話履歴はメモリストレージで管理されます。

```typescript
// src/mastra/lib/storage.ts
export class MemoryStorage {
  private conversations: Map<string, Message[]>;

  addMessage(conversationId: string, message: Message) {
    // 対話履歴を保存
  }

  getHistory(conversationId: string): Message[] {
    // 対話履歴を取得
  }
}
```

## カテゴリ

タグは以下のカテゴリに分類されます：

- `tech` - テクノロジー
- `art` - アート
- `music` - 音楽
- `sports` - スポーツ
- `business` - ビジネス
- `science` - 科学
- `lifestyle` - ライフスタイル
- `other` - その他
