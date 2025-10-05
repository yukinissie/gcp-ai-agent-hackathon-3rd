import { Box, Container, Flex, Heading, Card } from '@radix-ui/themes'
import { FeedBatchFetch } from './_components/FeedBatchFetch'
import { ThemeToggle } from '@/app/_components/ThemeToggle'
import { LogoutSection } from '../../home/_components/Logout'

export default function AdminPage() {
  return (
    <Box>
      <Flex justify="between" align="center" p="4">
        <ThemeToggle />
        <LogoutSection />
      </Flex>
      <Container size="4">
        <Box py="6" px="4">
          <Flex direction="column" gap="6">
            <Heading size="8" weight="bold">
              管理画面
            </Heading>

            <Card variant="surface">
              <Flex direction="column" gap="4" p="4">
                <Heading size="5" weight="bold">
                  RSS フィード管理
                </Heading>
                <FeedBatchFetch />
              </Flex>
            </Card>
          </Flex>
        </Box>
      </Container>
    </Box>
  )
}
