import { Box, Card, Heading, Flex, Text } from '@radix-ui/themes';
import { ChatInput } from './ChatInput';
import { ChatBotProps } from './chatTypes';

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
      style={{
        position: 'fixed',
        bottom: '20px',
        right: '20px',
        zIndex: 1000,
      }}
    >
      <Card
        style={{
          width: '350px',
          height: '400px',
          marginBottom: '10px',
          display: 'flex',
          flexDirection: 'column',
          boxShadow: '0 10px 25px rgba(0, 0, 0, 0.15)',
        }}
        variant="classic"
      >
        {/* メッセージエリア */}
        <Box 
          p="3" 
          style={{ 
            flex: 1, 
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <Box
            style={{
              maxWidth: '80%',
              padding: '12px 16px',
              borderRadius: '12px',
              backgroundColor: 'var(--gray-3)',
              color: 'var(--gray-12)',
              textAlign: 'center',
            }}
          >
            <Text size="2" style={{ lineHeight: '1.4' }}>
              {welcomeMessage}
            </Text>
          </Box>
        </Box>

        {/* 入力エリア */}
        <Box
          p="3"
          style={{
            borderTop: '1px solid var(--gray-6)',
            backgroundColor: 'var(--gray-1)',
            borderRadius: '0 0 12px 12px',
          }}
        >
          <ChatInput
            onSendMessage={handleSendMessage}
            placeholder="メッセージを入力..."
          />
        </Box>
      </Card>

      {/* ロボットアイコン（装飾のみ） */}
      <Box
        style={{
          width: '60px',
          height: '60px',
          borderRadius: '50%',
          background: 'linear-gradient(135deg, #ff6b6b, #ffd93d)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
          fontSize: '24px',
          marginLeft: 'auto',
        }}
      >
        🤖
      </Box>
    </Box>
  );
}
