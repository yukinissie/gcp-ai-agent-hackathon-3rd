import { Box, Heading, Flex, ScrollArea, IconButton, Text } from '@radix-ui/themes';
import { ChatInput } from './ChatInput';
import { ChatBotProps } from './chatTypes';

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
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: 'var(--gray-1)',
        borderLeft: '1px solid var(--gray-6)',
        width: '400px',
        minWidth: '350px',
      }}
    >
      <Flex
        justify="between"
        align="center"
        px="3"
        py="2"
        style={{
          borderBottom: '1px solid var(--gray-6)',
          backgroundColor: 'var(--gray-2)',
          height: '40px',
          minHeight: '40px',
        }}
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
              style={{ 
                cursor: 'pointer',
                color: 'var(--gray-11)',
                width: '24px',
                height: '24px',
              }}
            >
              ✕
            </IconButton>
          )}
        </Flex>
      </Flex>
      {/* メッセージエリア */}
      <Box style={{ flex: 1, position: 'relative', minHeight: 0 }}>
        <ScrollArea style={{ height: '100%' }}>
          <Box p="3">
            {/* 固定メッセージのみ表示 */}
            {staticMessages.map((message) => (
              <Flex key={message.id} direction="column" align="start" mb="3">
                <Flex align="center" gap="2" mb="1">
                  <Box
                    style={{
                      width: '24px',
                      height: '24px',
                      borderRadius: '50%',
                      backgroundColor: 'var(--accent-9)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: '12px',
                    }}
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
                  style={{
                    maxWidth: '80%',
                    padding: '8px 12px',
                    borderRadius: '12px',
                    backgroundColor: 'var(--gray-3)',
                    color: 'var(--gray-12)',
                    wordBreak: 'break-word',
                  }}
                >
                  <Text size="2" style={{ lineHeight: '1.4' }}>
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
        style={{
          borderTop: '1px solid var(--gray-6)',
          backgroundColor: 'var(--gray-2)',
          minHeight: '70px',
        }}
      >
        <ChatInput
          onSendMessage={handleSendMessage}
          placeholder="メッセージを入力..."
        />
      </Box>
    </Box>
  );
}
