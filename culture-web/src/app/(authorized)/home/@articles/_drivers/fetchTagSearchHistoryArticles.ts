import { apiClient } from '@/lib/apiClient'
import type { Article } from '../../../types'

export enum FetchTagSearchHistoryArticlesResultType {
  Success = 'success',
  Error = 'error',
  Unauthorized = 'unauthorized',
}

export type FetchTagSearchHistoryArticlesResult =
  | {
      type: FetchTagSearchHistoryArticlesResultType.Success
      articles: Article[]
    }
  | {
      type: FetchTagSearchHistoryArticlesResultType.Error
      error: string
    }
  | {
      type: FetchTagSearchHistoryArticlesResultType.Unauthorized
      error: string
    }

export async function fetchTagSearchHistoryArticles(): Promise<FetchTagSearchHistoryArticlesResult> {
  try {
    const data: { data: { articles: Article[] } } = await apiClient.get(
      '/api/v1/tag_search_histories/articles',
    )

    return {
      type: FetchTagSearchHistoryArticlesResultType.Success,
      articles: data.data.articles,
    }
  } catch (error) {
    console.error('タグ検索履歴記事一覧の取得に失敗しました:', error)
    if (error instanceof Error && error.message.includes('401')) {
      return {
        type: FetchTagSearchHistoryArticlesResultType.Unauthorized,
        error: 'Unauthorized access',
      }
    }
    return {
      type: FetchTagSearchHistoryArticlesResultType.Error,
      error: (error as Error).message,
    }
  }
}
