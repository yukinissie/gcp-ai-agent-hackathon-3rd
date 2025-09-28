import type { Metadata } from 'next'
import { Theme, ThemePanel } from '@radix-ui/themes'
import { ThemeProvider } from 'next-themes'
import { SessionProvider } from 'next-auth/react'
import { Footer } from './_components/Footer'
import './global.css'

export const metadata: Metadata = {
  title: 'Culture - AI Agent によるパーソナライズドニュースメディア',
  description:
    'AI Agent があなたのためのニュースフィードを提供します。 - 提供者：カルチャーズ（個人）',
  robots: 'noindex, nofollow',
}

export const viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  const useThemePanel = process.env.NODE_ENV !== 'production' && false
  return (
    <html lang="ja" suppressHydrationWarning>
      <body
        style={{
          margin: 0,
          minHeight: '100vh',
          display: 'flex',
          flexDirection: 'column',
        }}
      >
        <SessionProvider>
          <ThemeProvider attribute="class">
            <Theme accentColor="teal" grayColor="sage">
              <div
                style={{ flex: 1, display: 'flex', flexDirection: 'column' }}
              >
                {children}
              </div>
              <Footer />
              {useThemePanel && <ThemePanel />}
            </Theme>
          </ThemeProvider>
        </SessionProvider>
      </body>
    </html>
  )
}
