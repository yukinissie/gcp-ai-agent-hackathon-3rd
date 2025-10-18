'use client'

import { LockClosedIcon } from '@radix-ui/react-icons'
import { Button, Card, Flex, Text } from '@radix-ui/themes'
import { signOut } from 'next-auth/react'
import { useState } from 'react'
import { useRouter } from 'next/navigation'

type Props = {
  error: string
}

export function UnauthorizedError(props: Props) {
  const [loading, setLoading] = useState(false)
  const router = useRouter()
  const handleReLogin = async () => {
    setLoading(true)
    await signOut({ redirect: false })
    router.push('/signin')
    setLoading(false)
  }

  return (
    <Flex
      direction="column"
      align="center"
      justify="center"
      style={{
        minHeight: '400px',
      }}
      gap="4"
    >
      <Card
        variant="surface"
        style={{
          padding: '32px',
          maxWidth: '500px',
          textAlign: 'center',
        }}
      >
        <Flex direction="column" align="center" gap="4">
          <Flex
            align="center"
            justify="center"
            style={{
              width: '64px',
              height: '64px',
              borderRadius: '50%',
              backgroundColor: 'var(--red-3)',
            }}
          >
            <LockClosedIcon width="32" height="32" color="var(--red-9)" />
          </Flex>
          <Text size="6" weight="bold">
            認証エラー
          </Text>
          <Text size="3" color="gray" style={{ lineHeight: '1.6' }}>
            {props.error}
          </Text>
          <Flex direction="column" gap="2" style={{ width: '100%' }}>
            <Text size="2" color="gray">
              セッションの有効期限が切れている可能性があります。
            </Text>
            <Text size="2" color="gray">
              再度ログインしてからお試しください。
            </Text>
          </Flex>
          <Button
            size="3"
            style={{ marginTop: '8px', cursor: 'pointer' }}
            onClick={handleReLogin}
            loading={loading}
          >
            ログイン画面に戻る
          </Button>
        </Flex>
      </Card>
    </Flex>
  )
}
