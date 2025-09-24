import { NextRequest } from "next/server";
import { mastra } from "@/mastra"; // あなたのプロジェクトのMastra初期化
import { convertToCoreMessages, createIdGenerator } from "ai"; // 任意：messageId生成に使う

export const dynamic = "force-dynamic"; // Vercel等でストリーミングを確実に

export async function POST(req: NextRequest) {
    try {
        const { messages, ...rest } = await req.json(); // messages は UIMessage[]

        // APIキーの確認
        if (!process.env.GOOGLE_GENERATIVE_AI_API_KEY) {
            console.error("Google Generative AI API key is not set");
            return new Response(
                JSON.stringify({
                    error: "API key not configured",
                    message: "Google Generative AI API key is required"
                }),
                {
                    status: 500,
                    headers: { "Content-Type": "application/json" }
                }
            );
        }

        console.log("Full request body:", { messages: messages.length, rest });
        console.log("Processing request with userId:", rest.userId);
        const coreMessages = convertToCoreMessages(messages);

        // MastraのAgentを取得
        const agent = mastra.getAgent("newsCurationAgent");

        // AI SDK v5 互換ストリームを取得
        const stream = await agent.streamVNext(coreMessages, { 
            format: "aisdk",
            resourceId: rest.userId,
            threadId: rest.id || "default-thread"
        });

        // UIMessage用のストリーミングHTTPレスポンスに変換
        return stream.toUIMessageStreamResponse({
            originalMessages: messages, // あるとクライアント側でIDや履歴整合に便利
            generateMessageId: createIdGenerator({ prefix: "msg", size: 16 }), // 任意
            onFinish: async () => {
                console.log("Chat finished for user:", rest.userId);
            },
        });
    } catch (error) {
        console.error("Error in home agent API:", error);
        return new Response(
            JSON.stringify({
                error: "Internal server error",
                message: error instanceof Error ? error.message : "Unknown error",
                details: error
            }),
            {
                status: 500,
                headers: { "Content-Type": "application/json" }
            }
        );
    }
}
