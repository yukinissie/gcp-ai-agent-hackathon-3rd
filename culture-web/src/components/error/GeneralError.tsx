import { ExclamationTriangleIcon } from '@radix-ui/react-icons'
import { Card, Flex, Text } from '@radix-ui/themes'

type Props = {
  error: string
}

export function GeneralError(props: Props) {
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
              backgroundColor: 'var(--orange-3)',
            }}
          >
            <ExclamationTriangleIcon
              width="32"
              height="32"
              color="var(--orange-9)"
            />
          </Flex>
          <Text size="6" weight="bold">
            エラーが発生しました
          </Text>
          <Text size="3" color="gray" style={{ lineHeight: '1.6' }}>
            {props.error}
          </Text>
          <Text size="2" color="gray">
            問題が解決しない場合は、管理者にお問い合わせください。
          </Text>
        </Flex>
      </Card>
    </Flex>
  )
}
