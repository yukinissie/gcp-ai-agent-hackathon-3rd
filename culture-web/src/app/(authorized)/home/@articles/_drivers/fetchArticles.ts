import type { Article } from '../../../types'
import { apiClient, UnauthorizedError } from '@/lib/apiClient'

export async function fetchArticles(): Promise<Article[]> {
  try {
    const data: { articles: Article[] } =
      await apiClient.get('/api/v1/articles')

    return data.articles
  } catch (error) {
    // UnauthorizedError should be re-thrown to be caught by error.tsx
    if (error instanceof UnauthorizedError) {
      throw error
    }
    console.error('記事の取得に失敗しました:', error)
    return []
  }
}
