'use client'

import { createContext, useContext, useState, useEffect } from 'react'
import type React from 'react'

type ChatContextType = {
  isChatOpen: boolean
  isMobile: boolean
  setIsChatOpen: (isOpen: boolean) => void
}

const ChatContext = createContext<ChatContextType | undefined>(undefined)

export function ChatProvider({ children }: { children: React.ReactNode }) {
  const [isChatOpen, setIsChatOpen] = useState(false)
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    // 初期化: クライアントサイドでのみ実行
    const checkMobile = () => {
      const mobile = window.innerWidth <= 768
      setIsMobile(mobile)
      setIsChatOpen(!mobile) // モバイルでなければチャットを開く
    }

    checkMobile()
    window.addEventListener('resize', checkMobile)

    return () => window.removeEventListener('resize', checkMobile)
  }, [])

  useEffect(() => {
    // モバイル状態が変わったときの自動調整
    if (isMobile) {
      setIsChatOpen(false)
    } else {
      setIsChatOpen(true)
    }
  }, [isMobile])

  return (
    <ChatContext.Provider value={{ isChatOpen, isMobile, setIsChatOpen }}>
      {children}
    </ChatContext.Provider>
  )
}

export function useChatContext() {
  const context = useContext(ChatContext)
  if (context === undefined) {
    throw new Error('useChatContext must be used within a ChatProvider')
  }
  return context
}
