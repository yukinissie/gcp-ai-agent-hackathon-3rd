'use client'
import { Box, Container, Flex } from '@radix-ui/themes'
import { homeStyles } from './_styles/page.styles'
import type React from 'react'
import { ThemeToggle } from '@/app/_components/ThemeToggle'
import { LogoutSection } from './_components/Logout'
import { ChatProvider, useChatContext } from './_contexts/ChatContext'

type Props = {
  children: React.ReactNode
  articles: React.ReactNode
  chatSideBar: React.ReactNode
}

function LayoutContent(props: Props) {
  const { isChatOpen, isMobile } = useChatContext()

  const mainContentStyle =
    isMobile && isChatOpen
      ? {
          ...homeStyles.getMainContent(isChatOpen),
          display: 'none',
        }
      : homeStyles.getMainContent(isChatOpen)

  return (
    <Flex style={homeStyles.mainContainer}>
      <Box
        style={mainContentStyle}
        data-main-content
        tabIndex={isMobile ? -1 : 0}
      >
        <Flex justify="between" align="center" p="4">
          <ThemeToggle />
          <LogoutSection />
        </Flex>
        <Container size="4">
          <Box py="6">{props.articles}</Box>
        </Container>
      </Box>
      {props.chatSideBar}
    </Flex>
  )
}

export default function Layout(props: Props) {
  return (
    <ChatProvider>
      <LayoutContent {...props} />
    </ChatProvider>
  )
}
