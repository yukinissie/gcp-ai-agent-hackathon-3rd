import { NextRequest } from "next/server";
import { mastra } from "@/mastra"; // あなたのプロジェクトのMastra初期化
import { convertToCoreMessages, createIdGenerator } from "ai"; // 任意：messageId生成に使う

export const dynamic = "force-dynamic"; // Vercel等でストリーミングを確実に

export async function POST(req: NextRequest) {
    try {
        const { messages, ...rest } = await req.json();
        console.log("Full request body:", { messages: messages.length, rest });
        console.log("Processing request with userId:", rest.userId);
        const coreMessages = convertToCoreMessages(messages);

        const agent = mastra.getAgent("newsCurationAgent");

        const stream = await agent.streamVNext(coreMessages, {
            format: "aisdk",
            resourceId: rest.userId,
            threadId: rest.id || "default-thread"
        });

        return stream.toUIMessageStreamResponse({
            originalMessages: messages,
            generateMessageId: createIdGenerator({ prefix: "msg", size: 16 }),
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
