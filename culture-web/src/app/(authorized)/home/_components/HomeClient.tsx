"use client";

import Image from 'next/image';
import { useState, useEffect } from 'react';
import { Container, Box, Flex, Text } from '@radix-ui/themes';
import { LogoutSection } from '../../_components/Logout';
import { ArticleList } from './ArticleList';
import { ChatSidebar } from './ChatSidebar';
import { fetchArticles } from '../_actions/articles';
import { homeStyles } from '../_styles/page.styles';
import { Article } from './types';

interface HomeClientProps {
  userId: string;
}

export function HomeClient({ userId }: HomeClientProps) {
  const [isChatOpen, setIsChatOpen] = useState(true);
  const [articles, setArticles] = useState<Article[]>([]);

  useEffect(() => {
    const loadArticles = async () => {
      const fetchedArticles = await fetchArticles();
      setArticles(fetchedArticles);
    };
    loadArticles();
  }, []);

  const handleCloseChat = () => {
    setIsChatOpen(false);
  };

  const handleOpenChat = () => {
    setIsChatOpen(true);
  };

  return (
    <Flex style={homeStyles.mainContainer}>
      <Box style={homeStyles.getMainContent(isChatOpen)}>
        <Box style={homeStyles.logoutBox}>
          <LogoutSection />
        </Box>
        <Container size="4">
          <Box py="6">
            <ArticleList articles={articles} />
          </Box>
        </Container>
      </Box>
      
      {/* AIチャットサイドパネル */}
      {isChatOpen && (
        <Box
          style={homeStyles.chatSidebar}
        >
          <ChatSidebar 
            onClose={handleCloseChat}
            userId={userId}
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
          <div style={homeStyles.reopenImageWrapper}>
            <Image src="/culture.png" alt="Open chat" fill priority style={homeStyles.reopenImage} />
          </div>
        </Box>
      )}
    </Flex>
  );
}
