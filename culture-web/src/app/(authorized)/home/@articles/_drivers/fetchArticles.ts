import { apiClient } from '@/lib/apiClient'
import type { Article } from '../../../types'
import { UnauthorizedError } from '@/app/_components/error/UnauthorizedError'

export enum FetchArticlesResultType {
  Success = 'success',
  Error = 'error',
  Unauthorized = 'unauthorized',
}

export type FetchArticlesResult =
  | {
      type: FetchArticlesResultType.Success
      articles: Article[]
    }
  | {
      type: FetchArticlesResultType.Error
      error: string
    }
  | {
      type: FetchArticlesResultType.Unauthorized
      error: string
    }

export async function fetchArticles(): Promise<FetchArticlesResult> {
  try {
    const response = await apiClient.get('/api/v1/articles')
    return {
      type: FetchArticlesResultType.Success,
      articles: response.articles,
    }
  } catch (error) {
    console.error('Error fetching articles:', error)
    if (error instanceof UnauthorizedError) {
      return {
        type: FetchArticlesResultType.Unauthorized,
        error: 'Unauthorized access',
      }
    }
    return {
      type: FetchArticlesResultType.Error,
      error: (error as Error).message,
    }
  }
}
