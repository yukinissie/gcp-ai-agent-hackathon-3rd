'use server'

import { apiClient, UnauthorizedError } from '@/lib/apiClient'

interface BatchFetchResponse {
  message: string
  total_articles_created: number
  errors: number
  active_feeds_count: number
}

export async function batchFetchFeeds() {
  try {
    const response = await apiClient.post('/api/v1/feeds/batch_fetch')

    return {
      message: response.message,
      totalArticlesCreated: response.total_articles_created,
      errors: response.errors,
      activeFeedsCount: response.active_feeds_count,
    }
  } catch (error) {
    // UnauthorizedError は自動的に /signin にリダイレクトされる
    if (error instanceof UnauthorizedError) {
      throw error
    }
    console.error('Failed to batch fetch feeds:', error)
    throw new Error('フィード更新に失敗しました')
  }
}
