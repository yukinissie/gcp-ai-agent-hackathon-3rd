'use client'

import { useState } from 'react'
import { Button, Flex, Text, Box, Callout } from '@radix-ui/themes'
import { InfoCircledIcon, CheckCircledIcon } from '@radix-ui/react-icons'
import { batchFetchFeeds } from '../_actions/batchFetchFeeds'

export function FeedBatchFetch() {
  const [isLoading, setIsLoading] = useState(false)
  const [result, setResult] = useState<{
    message: string
    totalArticlesCreated: number
    errors: number
    activeFeedsCount: number
  } | null>(null)
  const [error, setError] = useState<string | null>(null)

  const handleBatchFetch = async () => {
    setIsLoading(true)
    setError(null)
    setResult(null)

    try {
      const data = await batchFetchFeeds()
      setResult(data)
    } catch (err) {
      setError(
        err instanceof Error ? err.message : '不明なエラーが発生しました',
      )
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <Flex direction="column" gap="4">
      <Box>
        <Button
          size="3"
          onClick={handleBatchFetch}
          disabled={isLoading}
          style={{ cursor: isLoading ? 'not-allowed' : 'pointer' }}
        >
          {isLoading ? '更新中...' : '全フィード一括更新'}
        </Button>
      </Box>

      {result && (
        <Flex direction="column" gap="4">
          <Callout.Root color="green">
            <Callout.Icon>
              <CheckCircledIcon />
            </Callout.Icon>
            <Callout.Text weight="bold">更新完了</Callout.Text>
          </Callout.Root>
          <Box ml="6">
            <Text size="2" as="div" mb="1">
              作成された記事数:{' '}
              <Text weight="bold">{result.totalArticlesCreated}</Text>
            </Text>
            <Text size="2" as="div" mb="1">
              処理したフィード数:{' '}
              <Text weight="bold">{result.activeFeedsCount}</Text>
            </Text>
            <Text size="2" as="div">
              エラー件数: <Text weight="bold">{result.errors}</Text>
            </Text>
          </Box>
        </Flex>
      )}

      {error && (
        <Callout.Root color="red">
          <Callout.Icon>
            <InfoCircledIcon />
          </Callout.Icon>
          <Callout.Text>{error}</Callout.Text>
        </Callout.Root>
      )}
    </Flex>
  )
}
