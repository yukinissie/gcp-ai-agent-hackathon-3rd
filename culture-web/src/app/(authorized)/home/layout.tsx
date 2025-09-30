'use client'
import { Box, Container, Flex } from '@radix-ui/themes'
import { homeStyles } from './_styles/page.styles'
import type React from 'react'
import { ThemeToggle } from '@/app/_components/ThemeToggle'
import { useState, useEffect } from 'react'
import { LogoutSection } from './_components/Logout'

type Props = {
  children: React.ReactNode
  articles: React.ReactNode
  chatSideBar: React.ReactNode
}

export default function Layout(props: Props) {
  const [isChatOpen, setIsChatOpen] = useState(window.innerWidth > 768)
  const [isMobile, setIsMobile] = useState(window.innerWidth <= 768)

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth <= 768)
    }

    checkMobile()
    window.addEventListener('resize', checkMobile)

    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  useEffect(() => {
    if (!isMobile) {
      setIsChatOpen(true)
    } else {
      setIsChatOpen(false)
    }
  }, [isMobile])

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
        style={{
          position: 'fixed',
          top: 12,
          left: 12,
          zIndex: 1100,
        }}
      >
        <ThemeToggle />
      </Box>
      <Box
        style={mainContentStyle}
        data-main-content
        tabIndex={isMobile ? -1 : 0}
      >
        <Box style={homeStyles.logoutBox}>
          <LogoutSection />
        </Box>
        <Container size="4">
          <Box py="6">{props.articles}</Box>
        </Container>
      </Box>
      {props.chatSideBar}
    </Flex>
  )
}
