import { Container, Box, Heading, Text, Button } from '@radix-ui/themes'
import Link from 'next/link'

export default function NotFound() {
  return (
    <Container size="4">
      <Box
        py="8"
        style={{
          textAlign: 'center',
        }}
      >
        <Heading size="8" mb="4">
          404
        </Heading>
        <Heading size="6" mb="4">
          記事が見つかりません
        </Heading>
        <Text size="3" color="gray" mb="6">
          お探しの記事は削除されたか、URLが間違っている可能性があります。
        </Text>
        <Link href="/home">
          <Button size="3">記事一覧に戻る</Button>
        </Link>
      </Box>
    </Container>
  )
}
