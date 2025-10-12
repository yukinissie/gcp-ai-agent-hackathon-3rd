import { Box, Button, Flex, Heading, Text } from '@radix-ui/themes'
import Link from 'next/link'
import { ThemeToggle } from './_components/ThemeToggle'

export default function NotFound() {
  return (
    <Box
      position="relative"
      style={{
        flex: 1,
        minHeight: 'calc(100vh - 120px)',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Box position="absolute" top="4" right="4">
        <ThemeToggle />
      </Box>
      <Flex
        justify="center"
        align="center"
        style={{
          flex: 1,
          minHeight: 'calc(100vh - 120px)',
          width: '100%',
          maxWidth: '600px',
          margin: '0 auto',
          padding: '0 24px',
        }}
        direction="column"
        gap="6"
      >
        <Heading
          size="9"
          style={{
            fontSize: 'clamp(3rem, 10vw, 6rem)',
            fontWeight: 'bold',
            lineHeight: 1,
          }}
        >
          404
        </Heading>
        <Flex direction="column" gap="3" align="center">
          <Heading size="6">ページが見つかりません</Heading>
          <Text size="3" color="gray" align="center">
            お探しのページは存在しないか、移動または削除された可能性があります。
          </Text>
        </Flex>
        <Flex
          gap="3"
          direction="column"
          style={{ width: '100%', maxWidth: '300px' }}
        >
          <Link href="/home" style={{ width: '100%' }}>
            <Button size="3" style={{ width: '100%' }}>
              ホームに戻る
            </Button>
          </Link>
        </Flex>
      </Flex>
    </Box>
  )
}
