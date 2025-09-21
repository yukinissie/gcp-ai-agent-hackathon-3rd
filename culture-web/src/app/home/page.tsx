'use client';

import { Container, Box, Flex, IconButton } from '@radix-ui/themes';
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
  const handleChatMessage = async (message: string): Promise<string> => {
    return `「${message}」について調べています。`;
  };

  const handleCloseChat = () => {
    const chatElement = document.getElementById('chat-sidebar');
    const mainElement = document.getElementById('main-content');
    const reopenButton = document.getElementById('reopen-chat-button');
    
    if (chatElement && mainElement && reopenButton) {
      chatElement.style.display = 'none';
      mainElement.style.marginRight = '0';
      reopenButton.style.display = 'block';
    }
  };

  const handleOpenChat = () => {
    const chatElement = document.getElementById('chat-sidebar');
    const mainElement = document.getElementById('main-content');
    const reopenButton = document.getElementById('reopen-chat-button');
    
    if (chatElement && mainElement && reopenButton) {
      chatElement.style.display = 'flex';
      mainElement.style.marginRight = '400px';
      reopenButton.style.display = 'none';
    }
  };

  return (
    <Flex style={homeStyles.mainContainer}>
      <Box 
        id="main-content"
        style={homeStyles.mainContent}
      >
        <Container size="4">
          <Box py="6">
            <ArticleList articles={sampleArticles} />
          </Box>
        </Container>
      </Box>
      
      {/* AIチャットサイドパネル */}
      <Box
        id="chat-sidebar"
        style={homeStyles.chatSidebar}
      >
        <ChatSidebar 
          onSendMessage={handleChatMessage} 
          onClose={handleCloseChat}
        />
      </Box>

      <Box
        id="reopen-chat-button"
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
        💬
      </Box>
    </Flex>
  );
}
