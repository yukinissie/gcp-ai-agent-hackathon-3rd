import { Box, Flex, Text } from '@radix-ui/themes'
import Link from 'next/link'

export function Footer() {
  return (
    <Box
      style={{
        borderTop: '1px solid var(--gray-6)',
        backgroundColor: 'var(--gray-1)',
        padding: '1rem 0',
        marginTop: 'auto',
      }}
    >
      <Flex
        justify="center"
        align="center"
        direction="column"
        gap="2"
        style={{ maxWidth: '1200px', margin: '0 auto', padding: '0 1rem' }}
      >
        <Flex gap="4" align="center" wrap="wrap" justify="center">
          <Link href="/terms" style={{ textDecoration: 'none' }}>
            <Text size="2" color="gray" style={{ cursor: 'pointer' }}>
              利用規約
            </Text>
          </Link>
          <Text size="2" color="gray">
            |
          </Text>
          <Link href="/privacy" style={{ textDecoration: 'none' }}>
            <Text size="2" color="gray" style={{ cursor: 'pointer' }}>
              プライバシーポリシー
            </Text>
          </Link>
        </Flex>
        <Text size="1" color="gray" style={{ textAlign: 'center' }}>
          © 2025 Culture - 提供者：カルチャーズ（個人）
        </Text>
      </Flex>
    </Box>
  )
}
