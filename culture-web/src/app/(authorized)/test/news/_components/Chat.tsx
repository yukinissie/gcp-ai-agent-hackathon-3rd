"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport } from "ai";
import { useState } from "react";

export function Chat(props: {
  userId: string;
}) {
  const {
    messages,
    sendMessage,
    status,
  } =
    useChat(
      {
        transport:
          new DefaultChatTransport(
            {
              api: "/api/news/agent",
              body: {
                userId:
                  props.userId,
              },
            },
          ),
        messages:
          [
            {
              id: "sys-0",
              role: "system" as const,
              parts:
                [
                  {
                    type: "text" as const,
                    text: `user ID is ${props.userId || "unknown"}. You are a helpful assistant specialized in curating news articles based on user preferences. Provide concise and relevant news summaries.`,
                  },
                ],
            },
          ],
      },
    );
  const [
    input,
    setInput,
  ] =
    useState(
      "",
    );
  return (
    <div>
      {messages.map(
        (
          message,
        ) => {
          if (
            message.role ===
            "system"
          )
            return null;

          return (
            <div
              key={
                message.id
              }
            >
              {message.role ===
              "user"
                ? "User: "
                : "AI: "}
              {message.parts.map(
                (
                  part,
                ) =>
                  part.type ===
                  "text" ? (
                    <span
                      key={`${message.id}-${part.type}-${typeof part.text === "string" ? part.text.slice(0, 32) : ""}`}
                    >
                      {
                        part.text
                      }
                    </span>
                  ) : null,
              )}
            </div>
          );
        },
      )}

      <form
        onSubmit={(
          e,
        ) => {
          e.preventDefault();
          if (
            input.trim()
          ) {
            sendMessage(
              {
                text: input,
              },
            );
            setInput(
              "",
            );
          }
        }}
      >
        <input
          value={
            input
          }
          onChange={(
            e,
          ) =>
            setInput(
              e
                .target
                .value,
            )
          }
          disabled={
            status !==
            "ready"
          }
          placeholder="Say something..."
        />
        <button
          type="submit"
          disabled={
            status !==
            "ready"
          }
        >
          Submit
        </button>
        {
          props.userId
        }
      </form>
    </div>
  );
}
