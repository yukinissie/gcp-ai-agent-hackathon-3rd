import { NextRequest } from "next/server";
import { mastra } from "@/mastra"; // あなたのプロジェクトのMastra初期化
import { createIdGenerator } from "ai"; // 任意：messageId生成に使う
import type { UIMessage } from "ai"; // リクエスト/レスポンス型

export const dynamic = "force-dynamic"; // Vercel等でストリーミングを確実に

export async function POST(req: NextRequest) {
	const { messages }: { messages: UIMessage[] } = await req.json();

	// MastraのAgentを取得
	const agent = mastra.getAgent("newsCurationAgent");

	// userIdをメッセージに含めてMastraAgentに渡す
	const enrichedMessages = [...messages];

	// AI SDK v5 互換ストリームを取得
	const stream = await agent.streamVNext(enrichedMessages, { format: "aisdk" });

	// UIMessage用のストリーミングHTTPレスポンスに変換
	return stream.toUIMessageStreamResponse({
		originalMessages: messages, // あるとクライアント側でIDや履歴整合に便利
		generateMessageId: createIdGenerator({ prefix: "msg", size: 16 }), // 任意
		onFinish: async () => {
			// 任意：履歴の保存・ロギングなど
			// await saveToDB(chatId, messages);
		},
	});
}
