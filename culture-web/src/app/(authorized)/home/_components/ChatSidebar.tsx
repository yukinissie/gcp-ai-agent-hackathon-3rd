"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport } from "ai";
import { useState, useEffect } from "react";
import { Box, Flex, ScrollArea, IconButton, Text, TextField, Button } from '@radix-ui/themes';
import { chatSidebarStyles } from '../_styles/chatSidebar.styles';

export function ChatSidebar({ 
  onSendMessage,
  className,
  onClose,
  userId
}: {
  onSendMessage?: (message: string) => Promise<string>;
  className?: string;
  onClose?: () => void;
  userId: string;
}) {
  const [isClient, setIsClient] = useState(false);
  const [input, setInput] = useState("");
  
  useEffect(() => {
    setIsClient(true);
  }, []);
  
  console.log("ChatSidebar - User ID:", userId);
  
  const { messages, sendMessage, status } = useChat({
    transport: new DefaultChatTransport({
      api: "/api/home/agent",
      body: {
        userId: userId,
      },
    }),
    messages: [
      {
        id: "sys-0",
        role: "system" as const,
        parts: [
          {
            type: "text" as const,
            text: `user ID is ${userId}. You are a helpful assistant specialized in curating news articles based on user preferences. Provide concise and relevant news summaries in Japanese.`,
          },
        ],
      },
    ],
  });

  return (
    <Box
      className={className}
      style={chatSidebarStyles.container}
    >
      <Flex
        justify="between"
        align="center"
        px="3"
        py="2"
        style={chatSidebarStyles.header}
      >
        <Flex align="center" gap="2">
          <Text size="2" weight="medium" color="gray">
            チャット
          </Text>
        </Flex>
        <Flex align="center" gap="1">
          {onClose && (
            <IconButton
              variant="ghost"
              size="1"
              onClick={onClose}
              style={chatSidebarStyles.closeButton}
            >
              ✕
            </IconButton>
          )}
        </Flex>
      </Flex>
      
      {/* メッセージエリア */}
      <Box style={chatSidebarStyles.messagesContainer}>
        <ScrollArea style={chatSidebarStyles.scrollArea}>
          <Box p="3">
            {messages.map((message) => {
              if (message.role === "system") return null;

              return (
                <Flex key={message.id} direction="column" align={message.role === "user" ? "end" : "start"} mb="3">
                  <Flex align="center" gap="2" mb="1">
                    <Box style={chatSidebarStyles.avatarBox}>
                      {message.role === "user" ? "👤" : "🤖"}
                    </Box>
                    <Text 
                      size="1" 
                      style={{ color: 'var(--teal-9)' }}
                    >
                      {isClient ? new Date().toLocaleTimeString('ja-JP', {
                        hour: '2-digit',
                        minute: '2-digit',
                      }) : '--:--'}
                    </Text>
                  </Flex>
                  <Box
                    style={{
                      ...chatSidebarStyles.messageBox,
                      backgroundColor: message.role === "user" ? "#e3f2fd" : "#f5f5f5",
                    }}
                  >
                    <Text 
                      size="2" 
                      style={{
                        ...chatSidebarStyles.messageText,
                        color: 'var(--teal-9)'
                      }}
                    >
                      {message.parts.map((part) =>
                        part.type === "text" ? (
                          <span
                            key={`${message.id}-${part.type}-${typeof part.text === "string" ? part.text.slice(0, 32) : ""}`}
                          >
                            {part.text}
                          </span>
                        ) : null,
                      )}
                    </Text>
                  </Box>
                </Flex>
              );
            })}
          </Box>
        </ScrollArea>
      </Box>

      {/* 入力エリア */}
      <Box p="3" style={chatSidebarStyles.inputArea}>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            if (input.trim()) {
              console.log("Sending message with userId:", userId); // デバッグログ
              sendMessage({ text: input });
              setInput("");
            }
          }}
        >
          <Flex gap="2" align="center">
            <TextField.Root
              value={input}
              onChange={(e) => setInput(e.target.value)}
              disabled={status !== "ready"}
              placeholder="メッセージを入力..."
              style={{ flex: 1 }}
              size="2"
            />
            <Button
              type="submit"
              disabled={status !== "ready"}
              variant="solid"
              size="2"
            >
              送信
            </Button>
          </Flex>
        </form>
        {/* デバッグ情報 */}
        {isClient && (
          <Text size="1" style={{ color: 'var(--teal-9)' }}>
            User ID: {userId || "未設定"}
          </Text>
        )}
      </Box>
    </Box>
  );
}
