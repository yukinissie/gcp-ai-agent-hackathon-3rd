'use client'

import { Box } from '@radix-ui/themes'
import { useState, useEffect } from 'react'
import { ChatSidebar } from './ChatSidebar'
import { chatSideBarWrapperStyles } from '../_styles/chatSideBarWrapper.styles'
import Image from 'next/image'

type Props = {
  userId: string
}

export function ChatSideBarWrapper(props: Props) {
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

  const handleCloseChat = () => {
    setIsChatOpen(false)
  }

  const handleOpenChat = () => {
    setIsChatOpen(true)
  }

  const chatSidebarStyle = isMobile
    ? {
        ...chatSideBarWrapperStyles.chatSidebar,
        width: '100vw',
        left: 0,
      }
    : chatSideBarWrapperStyles.chatSidebar

  return (
    <>
      {isChatOpen && (
        <Box style={chatSidebarStyle}>
          <ChatSidebar onClose={handleCloseChat} userId={props.userId} />
        </Box>
      )}

      {/* チャット再開ボタン */}
      {!isChatOpen && (
        <Box
          onClick={handleOpenChat}
          style={chatSideBarWrapperStyles.reopenChatButton}
          onMouseEnter={(e) => {
            Object.assign(
              e.currentTarget.style,
              chatSideBarWrapperStyles.reopenButtonHover,
            )
          }}
          onMouseLeave={(e) => {
            Object.assign(
              e.currentTarget.style,
              chatSideBarWrapperStyles.reopenButtonLeave,
            )
          }}
          title="チャットを開く"
        >
          <div style={chatSideBarWrapperStyles.reopenImageWrapper}>
            <Image
              src="/culture.png"
              alt="Open chat"
              fill
              priority
              style={chatSideBarWrapperStyles.reopenImage}
            />
          </div>
        </Box>
      )}
    </>
  )
}
