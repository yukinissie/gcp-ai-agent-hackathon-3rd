import { Box, Text, Flex } from '@radix-ui/themes';
import { ChatMessageProps } from './chatTypes';

export function ChatMessage({ message }: ChatMessageProps) {
  const isUser = message.sender === 'user';
  
  const formatTime = (timestamp: string) => {
    const date = new Date(timestamp);
    return date.toLocaleTimeString('ja-JP', {
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  return (
    <Flex
      direction="column"
      align={isUser ? 'end' : 'start'}
      mb="3"
      style={{ width: '100%' }}
    >
      <Flex
        align="center"
        gap="2"
        mb="1"
        direction={isUser ? 'row-reverse' : 'row'}
      >
        {!isUser && (
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
        )}
        <Text size="1" color="gray">
          {formatTime(message.timestamp)}
        </Text>
      </Flex>
      
      <Box
        style={{
          maxWidth: '80%',
          padding: '8px 12px',
          borderRadius: '12px',
          backgroundColor: isUser 
            ? 'var(--accent-9)' 
            : 'var(--gray-3)',
          color: isUser 
            ? 'var(--accent-contrast)' 
            : 'var(--gray-12)',
          wordBreak: 'break-word',
        }}
      >
        <Text size="2" style={{ lineHeight: '1.4' }}>
          {message.isTyping ? (
            <span>
              入力中
              <span style={{ animation: 'blink 1.5s infinite' }}>...</span>
            </span>
          ) : (
            message.content
          )}
        </Text>
      </Box>
      
      <style jsx>{`
        @keyframes blink {
          0%, 50% { opacity: 1; }
          51%, 100% { opacity: 0; }
        }
      `}</style>
    </Flex>
  );
}
