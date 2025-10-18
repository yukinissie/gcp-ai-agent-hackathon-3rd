import { Flex, Text, Button } from '@radix-ui/themes'
import { LockClosedIcon } from '@radix-ui/react-icons'
import Link from 'next/link'

export function UnauthenticatedScreen() {
  return (
    <Flex
      direction="column"
      align="center"
      justify="center"
      style={{
        minHeight: '100vh',
        padding: '1rem',
      }}
    >
      <Flex
        direction="column"
        align="center"
        gap="6"
        style={{
          maxWidth: '400px',
          width: '100%',
        }}
      >
        <Flex
          align="center"
          justify="center"
          style={{
            width: '64px',
            height: '64px',
            borderRadius: '50%',
            backgroundColor: 'var(--gray-3)',
          }}
        >
          <LockClosedIcon width="32" height="32" color="var(--gray-11)" />
        </Flex>

        <Flex direction="column" align="center" gap="2">
          <Text weight="bold" size="6">
            ログインが必要です
          </Text>
          <Text size="3" color="gray" align="center">
            このページを表示するには、ログインが必要です。
            <br />
            アカウントをお持ちでない場合は、新規登録してください。
          </Text>
        </Flex>

        <Flex direction="column" gap="3" style={{ width: '100%' }}>
          <Link href="/signin" style={{ textDecoration: 'none' }}>
            <Button size="3" style={{ width: '100%' }}>
              ログイン
            </Button>
          </Link>
          <Link href="/signup" style={{ textDecoration: 'none' }}>
            <Button variant="soft" size="3" style={{ width: '100%' }}>
              新規登録
            </Button>
          </Link>
        </Flex>

        <Link
          href="/"
          style={{
            textDecoration: 'none',
            color: 'var(--gray-11)',
            fontSize: '0.875rem',
          }}
        >
          <Text size="2" color="gray">
            ホームに戻る
          </Text>
        </Link>
      </Flex>
    </Flex>
  )
}
