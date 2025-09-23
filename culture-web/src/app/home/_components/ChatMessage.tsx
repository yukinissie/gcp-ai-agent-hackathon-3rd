import { Box, Text, Flex } from '@radix-ui/themes';
import { ChatMessageProps } from './chatTypes';
import { chatMessageStyles } from '../_styles/chatMessage.styles';

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
      style={chatMessageStyles.container}
    >
      <Flex
        align="center"
        gap="2"
        mb="1"
        direction={isUser ? 'row-reverse' : 'row'}
      >
        {!isUser && (
          <Box style={chatMessageStyles.avatarBox}>
            🤖
          </Box>
        )}
        <Text size="1" color="gray">
          {formatTime(message.timestamp)}
        </Text>
      </Flex>
      
      <Box style={chatMessageStyles.messageBox(isUser)}>
        <Text size="2" style={chatMessageStyles.messageText}>
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
