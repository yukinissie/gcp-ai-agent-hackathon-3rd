"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport } from "ai";
import { useState } from "react";

export function Chat() {
	const { messages, sendMessage, status } = useChat({
		transport: new DefaultChatTransport({
			api: "/api/chat",
		}),
	});
	const [input, setInput] = useState("");
	return (
		<div>
			{messages.map((message) => (
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
			))}

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
			</form>
		</div>
	);
}
