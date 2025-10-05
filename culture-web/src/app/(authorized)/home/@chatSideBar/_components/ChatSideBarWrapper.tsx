'use client'

import { Box } from '@radix-ui/themes'
import { ChatSidebar } from './ChatSidebar'
import { chatSideBarWrapperStyles } from '../_styles/chatSideBarWrapper.styles'
import Image from 'next/image'
import { useChatContext } from '../../_contexts/ChatContext'

type Props = {
  userId: string
}

export function ChatSideBarWrapper(props: Props) {
  const { isChatOpen, isMobile, setIsChatOpen } = useChatContext()

  const handleCloseChat = () => {
    setIsChatOpen(false)
  }

  const handleOpenChat = () => {
    setIsChatOpen(true)
  }

  const chatSidebarStyle = {
    ...chatSideBarWrapperStyles.chatSidebar,
    ...(isMobile && chatSideBarWrapperStyles.chatSidebarMobile),
    ...(isMobile
      ? isChatOpen
        ? chatSideBarWrapperStyles.chatSidebarMobileOpen
        : chatSideBarWrapperStyles.chatSidebarMobileClosed
      : isChatOpen
        ? chatSideBarWrapperStyles.chatSidebarOpen
        : chatSideBarWrapperStyles.chatSidebarClosed),
  }

  return (
    <>
      <Box style={chatSidebarStyle}>
        <ChatSidebar onClose={handleCloseChat} userId={props.userId} />
      </Box>

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
