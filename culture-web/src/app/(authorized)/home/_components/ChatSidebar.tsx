import { Box, Heading, Flex, ScrollArea, IconButton, Text } from '@radix-ui/themes';
import { ChatInput } from './ChatInput';
import { ChatBotProps } from './chatTypes';
import { chatSidebarStyles } from '../_styles/chatSidebar.styles';

export function ChatSidebar({ 
  onSendMessage,
  className,
  onClose
}: ChatBotProps) {
  
  const staticMessages = [
    {
      id: '1',
      content: 'ニュースをお探しします。',
      sender: 'ai' as const,
      timestamp: new Date().toISOString(),
    }
  ];

  const handleSendMessage = (content: string) => {
    console.log('メッセージ送信:', content);
    if (onSendMessage) {
      onSendMessage(content);
    }
  };

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
            {/* 固定メッセージのみ表示 */}
            {staticMessages.map((message) => (
              <Flex key={message.id} direction="column" align="start" mb="3">
                <Flex align="center" gap="2" mb="1">
                  <Box
                    style={chatSidebarStyles.avatarBox}
                  >
                    🤖
                  </Box>
                  <Text size="1" color="gray">
                    {new Date(message.timestamp).toLocaleTimeString('ja-JP', {
                      hour: '2-digit',
                      minute: '2-digit',
                    })}
                  </Text>
                </Flex>
                <Box
                  style={chatSidebarStyles.messageBox}
                >
                  <Text size="2" style={chatSidebarStyles.messageText}>
                    {message.content}
                  </Text>
                </Box>
              </Flex>
            ))}
          </Box>
        </ScrollArea>
      </Box>

      {/* 入力エリア */}
      <Box
        p="3"
        style={chatSidebarStyles.inputArea}
      >
        <ChatInput
          onSendMessage={handleSendMessage}
          placeholder="メッセージを入力..."
        />
      </Box>
    </Box>
  );
}
