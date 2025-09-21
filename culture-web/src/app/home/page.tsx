'use client';

import { useState } from 'react';
import { Container, Box, Flex, IconButton, Text } from '@radix-ui/themes';
import { ArticleList } from './_components/ArticleList';
import { ChatSidebar } from './_components/ChatSidebar';
import type { Article } from './_components/types';
import { homeStyles } from './_styles/page.styles';

const sampleArticles: Article[] = [
  {
    id: '1',
    title: '現代アートの新しい潮流：デジタルアートの可能性',
    excerpt: 'デジタル技術の進歩により、アートの表現方法も大きく変化しています。NFTアートから没入型体験まで、最新のトレンドを解説します。',
    content: '...',
    author: '田中美術',
    publishedAt: '2025-01-15T10:00:00Z',
    updatedAt: '2025-01-15T10:00:00Z',
    category: 'アート',
    tags: ['デジタルアート', 'NFT', '現代アート', 'テクノロジー'],
    imageUrl: 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=800&h=400&fit=crop',
  },
  {
    id: '2',
    title: '日本の伝統工芸と現代デザインの融合',
    excerpt: '古くから受け継がれてきた伝統工芸の技法を、現代のデザインに活かした作品が注目を集めています。',
    content: '...',
    author: '山田工芸',
    publishedAt: '2025-01-10T14:30:00Z',
    updatedAt: '2025-01-10T14:30:00Z',
    category: '工芸',
    tags: ['伝統工芸', '現代デザイン', '日本文化', '手作り'],
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
  },
  {
    id: '3',
    title: '音楽フェスティバルの文化的影響',
    excerpt: '音楽フェスティバルが地域文化や若者文化に与える影響について考察します。',
    content: '...',
    author: '佐藤音楽',
    publishedAt: '2025-01-05T18:00:00Z',
    updatedAt: '2025-01-05T18:00:00Z',
    category: '音楽',
    tags: ['フェスティバル', '音楽', '文化', '地域活性化'],
    imageUrl: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop',
  },
  {
    id: '4',
    title: '建築とライフスタイルの関係性',
    excerpt: '住環境が私たちの生活に与える影響と、持続可能な建築デザインの重要性について探ります。',
    content: '...',
    author: '鈴木建築',
    publishedAt: '2025-01-01T09:00:00Z',
    updatedAt: '2025-01-01T09:00:00Z',
    category: '建築',
    tags: ['建築デザイン', 'ライフスタイル', '持続可能性', '住環境'],
    imageUrl: 'https://images.unsplash.com/photo-1487958449943-2429e8be8625?w=800&h=400&fit=crop',
  },
];

export default function Home(){
  const [isChatOpen, setIsChatOpen] = useState(true);

  const handleChatMessage = async (message: string): Promise<string> => {
    return `「${message}」について調べています。`;
  };

  const handleCloseChat = () => {
    setIsChatOpen(false);
  };

  const handleOpenChat = () => {
    setIsChatOpen(true);
  };

  return (
    <Flex style={homeStyles.mainContainer}>
      <Box 
        style={{
          ...homeStyles.mainContent,
          marginRight: isChatOpen ? '400px' : '0',
        }}
      >
        <Container size="4">
          <Box py="6">
            <ArticleList articles={sampleArticles} />
          </Box>
        </Container>
      </Box>
      
      {/* AIチャットサイドパネル */}
      {isChatOpen && (
        <Box
          style={homeStyles.chatSidebar}
        >
          <ChatSidebar 
            onSendMessage={handleChatMessage} 
            onClose={handleCloseChat}
          />
        </Box>
      )}

      {/* チャット再開ボタン */}
      {!isChatOpen && (
        <Box
          onClick={handleOpenChat}
          style={homeStyles.reopenChatButton}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, homeStyles.reopenButtonHover);
          }}
          onMouseLeave={(e) => {
            Object.assign(e.currentTarget.style, homeStyles.reopenButtonLeave);
          }}
          title="チャットを開く"
        >
          <Text size="6" weight="bold">

          </Text>
        </Box>
      )}
    </Flex>
  );
}
