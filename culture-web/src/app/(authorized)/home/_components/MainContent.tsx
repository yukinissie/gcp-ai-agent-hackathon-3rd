'use client'

import { Box, Container, Flex, Heading } from '@radix-ui/themes'
import { homeStyles } from '../_styles/page.styles'
import { ThemeToggle } from '@/app/_components/ThemeToggle'
import { LogoutSection } from '../_components/Logout'
import { ArticleList } from './ArticleList'
import { useChatContext } from '../_contexts/ChatContext'
import { CHAT_SIDEBAR_WIDTH } from '../_constants/layout'
import type { Article } from '../../types'

type Props = {
  articles: Article[]
}

export function MainContent({ articles }: Props) {
  const { isChatOpen, isMobile } = useChatContext()

  const mainContentStyle = {
    ...homeStyles.mainContent,
    marginRight: isChatOpen && !isMobile ? CHAT_SIDEBAR_WIDTH : '0',
  }

  return (
    <Box style={mainContentStyle} data-main-content tabIndex={0}>
      <Flex justify="between" align="center" p="4">
        <ThemeToggle />
        <LogoutSection />
      </Flex>
      <Container size="4">
        <Box py="6" px="4">
          <Box>
            <Flex direction="column" gap="6">
              <Flex align="center" justify="between">
                <Heading size="6" weight="bold">
                  記事一覧
                </Heading>
              </Flex>
              <Flex direction="column" gap="3" width="100%">
                <ArticleList articles={articles} />
              </Flex>
            </Flex>
          </Box>
        </Box>
      </Container>
    </Box>
  )
}
