import { Flex, Spinner, Text } from '@radix-ui/themes'

export function Loading() {
  return (
    <Flex
      direction="column"
      align="center"
      justify="center"
      gap="4"
      style={{
        minHeight: '100vh',
        padding: '1rem',
      }}
    >
      <Spinner size="3" />
      <Text size="3" color="gray">
        読み込み中...
      </Text>
    </Flex>
  )
}
