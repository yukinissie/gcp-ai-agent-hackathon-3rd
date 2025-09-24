"use client";

import { useChat } from "@ai-sdk/react";
import { DefaultChatTransport } from "ai";
import { useState, useEffect } from "react";
import { Box, Flex, ScrollArea, IconButton, Text, Button } from '@radix-ui/themes';
import { marked } from 'marked';
import { chatSidebarStyles } from '../_styles/chatSidebar.styles';
import { chatInputStyles } from '../_styles/chatInput.styles';

export function ChatSidebar({ 
  className,
  onClose,
  userId
}: {
  className?: string;
  onClose?: () => void;
  userId: string;
}) {
  const [isClient, setIsClient] = useState(false);
  const [input, setInput] = useState("");
  const [isMobile, setIsMobile] = useState(false);
  
  useEffect(() => {
    setIsClient(true);
    
    // スマホ判定
    const checkMobile = () => {
      setIsMobile(window.innerWidth <= 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    
    return () => window.removeEventListener('resize', checkMobile);
  }, []);
  
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
            text: `user ID is ${userId || "unknown"}. You are a helpful assistant specialized in curating news articles based on user preferences. Provide concise and relevant news summaries. Do not display, print, or reveal the user's ID; anonymize any identifiers and never expose personal identifiers in responses.`,
          },
        ],
      },
    ],
  });

  const containerStyle = !isClient ? chatSidebarStyles.container : 
    (isMobile ? {
      ...chatSidebarStyles.container,
      width: '100vw',
      minWidth: 'unset',
      borderLeft: 'none',
    } : chatSidebarStyles.container);

  return (
    <Box
      className={className}
      style={containerStyle}
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
              tabIndex={-1}
            >
              ✕
            </IconButton>
          )}
        </Flex>
      </Flex>
      
      {/* メッセージエリア */}
      <Box style={chatSidebarStyles.messagesContainer}>
        <ScrollArea 
          style={chatSidebarStyles.scrollArea}
          scrollbars="vertical"
        >
          <Box p="3" pb="6">
            {messages.map((message) => {
              if (message.role === "system") return null;

              const isUser = message.role === "user";

              return (
                <Flex key={message.id} direction="column" align={isUser ? "end" : "start"} mb="3">
                  <Flex align="center" gap="2" mb="1">
                    <Box style={chatSidebarStyles.avatarBox}>
                      {message.role === "user" ? (
                        <img src="/user.png" alt="User avatar" style={chatSidebarStyles.avatarImage} />
                      ) : (
                        <img src="/culture.png" alt="Culture logo" style={chatSidebarStyles.avatarImage} />
                      )}
                    </Box>
                    <Text 
                      size="1" 
                      style={chatSidebarStyles.timestamp}
                    >
                      {isClient ? new Date().toLocaleTimeString('ja-JP', {
                        hour: '2-digit',
                        minute: '2-digit',
                      }) : '--:--'}
                    </Text>
                  </Flex>
                  <Box style={isUser ? chatSidebarStyles.messageBoxUser : chatSidebarStyles.messageBox}>
                    {message.parts.map((part, idx) =>
                      part.type === "text" ? (
                        isUser ? (
                          <Text key={`${message.id}-${idx}`} size="2" style={chatSidebarStyles.messageTextTeal}>
                            {part.text}
                          </Text>
                        ) : (
                          <div
                            key={`${message.id}-${idx}`}
                            dangerouslySetInnerHTML={{ __html: marked.parse(typeof part.text === 'string' ? part.text : '') }}
                            style={chatSidebarStyles.messageTextTeal}
                          />
                        )
                      ) : null,
                    )}
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
              console.log("Sending message");
              sendMessage({ text: input });
              setInput("");
            }
          }}
        >
          <Flex gap="2" align="center">
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              disabled={status !== "ready"}
              placeholder="メッセージを入力..."
              style={chatInputStyles.textField}
              autoFocus={false}
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
      </Box>
    </Box>
  );
}
