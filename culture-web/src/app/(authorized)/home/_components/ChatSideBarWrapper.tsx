'use client'

import { Box } from '@radix-ui/themes'
import { ChatSidebar } from './ChatSidebar'
import Image from 'next/image'
import { useChatContext } from '../_contexts/ChatContext'
import { chatSideBarWrapperStyles } from './chatSideBarWrapper.styles'


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
    ...(isChatOpen
      ? chatSideBarWrapperStyles.chatSidebarOpen
      : chatSideBarWrapperStyles.chatSidebarClosed),
  }

  const handleWheel = (e: React.WheelEvent) => {
    // Prevent scroll propagation to window
    e.stopPropagation()
  }

  return (
    <>
      <Box style={chatSidebarStyle} onWheel={handleWheel}>
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
              sizes="60px"
              priority
              style={chatSideBarWrapperStyles.reopenImage}
            />
          </div>
        </Box>
      )}
    </>
  )
}
