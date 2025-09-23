import { Box, Card, Heading, Flex, Text } from '@radix-ui/themes';
import { ChatInput } from './ChatInput';
import { ChatBotProps } from './chatTypes';
import { chatBotStyles } from '../_styles/chatBot.styles';

export function ChatBot({ 
  onSendMessage,
  className 
}: ChatBotProps) {

  const welcomeMessage = 'にっしーさんに重要なニュースをお探しします。';

  const handleSendMessage = (content: string) => {
    console.log('メッセージ送信:', content);
    if (onSendMessage) {
      onSendMessage(content);
    }
  };

  return (
    <Box 
      className={className}
      style={chatBotStyles.container}
    >
      <Card
        style={chatBotStyles.card}
        variant="classic"
      >
        {/* メッセージエリア */}
        <Box 
          p="3" 
          style={chatBotStyles.messageArea}
        >
          <Box style={chatBotStyles.messageBox}>
            <Text size="2" style={chatBotStyles.messageText}>
              {welcomeMessage}
            </Text>
          </Box>
        </Box>

        {/* 入力エリア */}
        <Box
          p="3"
          style={chatBotStyles.inputArea}
        >
          <ChatInput
            onSendMessage={handleSendMessage}
            placeholder="メッセージを入力..."
          />
        </Box>
      </Card>

      {/* ロボットアイコン（装飾のみ） */}
      <Box style={chatBotStyles.robotIcon}>
        🤖
      </Box>
    </Box>
  );
}
