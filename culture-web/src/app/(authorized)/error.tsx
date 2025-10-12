'use client'

import { Container, Box, Heading, Text, Button, Flex } from '@radix-ui/themes'
import Link from 'next/link'
import {
  ExclamationTriangleIcon,
  CrossCircledIcon,
} from '@radix-ui/react-icons'
import { useEffect, useState } from 'react'

interface ErrorPageProps {
  error: Error & { digest?: string }
  reset: () => void
}

export default function ErrorPage({ error, reset }: ErrorPageProps) {
  const [countdown, setCountdown] = useState(5)
  const isUnauthorized = error.name === 'UnauthorizedError'

  useEffect(() => {
    if (!isUnauthorized) return

    // Countdown timer for unauthorized errors
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(timer)
          window.location.href = '/signin'
          return 0
        }
        return prev - 1
      })
    }, 1000)

    return () => clearInterval(timer)
  }, [isUnauthorized])

  // Unauthorized error (401)
  if (isUnauthorized) {
    return (
      <Container size="2">
        <Box
          style={{
            minHeight: '100vh',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
          px="6"
        >
          <Flex direction="column" align="center" gap="6">
            <Box
              style={{
                width: '80px',
                height: '80px',
                borderRadius: '50%',
                backgroundColor: 'var(--amber-3)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <ExclamationTriangleIcon
                width="40"
                height="40"
                color="var(--amber-11)"
              />
            </Box>

            <Flex direction="column" align="center" gap="3">
              <Heading size="8" align="center">
                認証エラー
              </Heading>
              <Text size="4" color="gray" align="center">
                セッションの有効期限が切れました。
                <br />
                再度ログインしてください。
              </Text>
              <Text size="3" color="amber" weight="bold" mt="2">
                {countdown}秒後にログインページへ 自動的にリダイレクトします...
              </Text>
            </Flex>

            <Flex gap="3">
              <Link href="/signin">
                <Button size="3" variant="solid">
                  今すぐログインページへ
                </Button>
              </Link>
            </Flex>
          </Flex>
        </Box>
      </Container>
    )
  }

  // Other errors
  return (
    <Container size="2">
      <Box
        style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Flex direction="column" align="center" gap="6">
          <Box
            style={{
              width: '80px',
              height: '80px',
              borderRadius: '50%',
              backgroundColor: 'var(--red-3)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <CrossCircledIcon width="40" height="40" color="var(--red-11)" />
          </Box>

          <Flex direction="column" align="center" gap="3">
            <Heading size="8" align="center">
              エラーが発生しました
            </Heading>
            <Text size="4" color="gray" align="center">
              申し訳ございません。予期しないエラーが発生しました。
            </Text>
            {error.message && (
              <Text
                size="2"
                color="gray"
                align="center"
                style={{ opacity: 0.7 }}
              >
                {error.message}
              </Text>
            )}
          </Flex>

          <Flex gap="3">
            <Button size="3" variant="solid" onClick={() => reset()}>
              再試行
            </Button>
            <Link href="/home">
              <Button size="3" variant="outline">
                ホームへ戻る
              </Button>
            </Link>
          </Flex>
        </Flex>
      </Box>
    </Container>
  )
}
