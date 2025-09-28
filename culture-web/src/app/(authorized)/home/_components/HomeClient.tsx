'use client'

import Image from 'next/image'
import { useState, useEffect } from 'react'
import { Container, Box, Flex } from '@radix-ui/themes'
import { LogoutSection } from '../../_components/Logout'
import { ThemeToggle } from '../../../_components/ThemeToggle'
import { ArticleList } from './ArticleList'
import { ChatSidebar } from './ChatSidebar'
import { homeStyles } from '../_styles/page.styles'
import type { Article } from './types'

interface HomeClientProps {
  userId: string
  articles: Article[]
}

export function HomeClient({ userId, articles }: HomeClientProps) {
  const [isChatOpen, setIsChatOpen] = useState(false)
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth <= 768)
    }

    checkMobile()
    window.addEventListener('resize', checkMobile)

    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  const handleCloseChat = () => {
    setIsChatOpen(false)
  }

  const handleOpenChat = () => {
    setIsChatOpen(true)
  }

  // レスポンシブスタイル
  const mainContentStyle =
    isMobile && isChatOpen
      ? {
          ...homeStyles.getMainContent(isChatOpen),
          display: 'none',
        }
      : homeStyles.getMainContent(isChatOpen)

  const chatSidebarStyle = isMobile
    ? {
        ...homeStyles.chatSidebar,
        width: '100vw',
        left: 0,
      }
    : homeStyles.chatSidebar

  return (
    <Flex style={homeStyles.mainContainer}>
      {!(isMobile && isChatOpen) && (
        <Box
          style={{
            position: 'fixed',
            top: 12,
            left: 12,
            zIndex: 1100,
          }}
        >
          <ThemeToggle />
        </Box>
      )}
      <Box
        style={mainContentStyle}
        data-main-content
        tabIndex={isMobile ? -1 : 0}
      >
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
        <Box style={chatSidebarStyle}>
          <ChatSidebar onClose={handleCloseChat} userId={userId} />
        </Box>
      )}

      {/* チャット再開ボタン */}
      {!isChatOpen && (
        <Box
          onClick={handleOpenChat}
          style={homeStyles.reopenChatButton}
          onMouseEnter={(e) => {
            Object.assign(e.currentTarget.style, homeStyles.reopenButtonHover)
          }}
          onMouseLeave={(e) => {
            Object.assign(e.currentTarget.style, homeStyles.reopenButtonLeave)
          }}
          title="チャットを開く"
        >
          <div style={homeStyles.reopenImageWrapper}>
            <Image
              src="/culture.png"
              alt="Open chat"
              fill
              priority
              style={homeStyles.reopenImage}
            />
          </div>
        </Box>
      )}
    </Flex>
  )
}
