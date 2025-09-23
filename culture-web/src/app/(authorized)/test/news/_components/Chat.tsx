"use client";

import { useChat } from "@ai-sdk/react";
import { MessageList } from "@mastra/core/agent";
import { DefaultChatTransport } from "ai";
import { useState } from "react";

export function Chat(props: { userId: string }) {
	const { messages, sendMessage, status } = useChat({
		transport: new DefaultChatTransport({
			api: "/api/news/agent",
			body: {
				userId: props.userId,
			},
		}),
		messages: [
			{
				role: "system" as "system" | "user" | "assistant",
				content: `User ID: ${props.userId || 0}`,
			},
			// {
			// 	id: "system-init",
			// 	role: "system" as "system" | "user" | "assistant",
			// 	parts: [
			// 		{
			// 			type: "text" as const,
			// 			text: `User ID: ${props.userId || 0}`,
			// 		},
			// 	],
			// },
		],
	});
	const [input, setInput] = useState("");
	return (
		<div>
			{messages.map((message) => {
				if (message.role === "system") return null;

				return (
					<div key={message.id}>
						{message.role === "user" ? "User: " : "AI: "}
						{message.parts.map((part) =>
							part.type === "text" ? (
								<span
									key={`${message.id}-${part.type}-${typeof part.text === "string" ? part.text.slice(0, 32) : ""}`}
								>
									{part.text}
								</span>
							) : null,
						)}
					</div>
				);
			})}

			<form
				onSubmit={(e) => {
					e.preventDefault();
					if (input.trim()) {
						sendMessage({ text: input });
						setInput("");
					}
				}}
			>
				<input
					value={input}
					onChange={(e) => setInput(e.target.value)}
					disabled={status !== "ready"}
					placeholder="Say something..."
				/>
				<button type="submit" disabled={status !== "ready"}>
					Submit
				</button>
				{props.userId}
			</form>
		</div>
	);
}
