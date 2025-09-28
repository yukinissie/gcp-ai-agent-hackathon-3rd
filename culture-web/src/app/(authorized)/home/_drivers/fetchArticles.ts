import { apiClient } from '@/lib/apiClient'
import type { Article } from '../../types'

export async function fetchArticles(): Promise<Article[]> {
  try {
    const data: { articles: Article[] } =
      await apiClient.get('/api/v1/articles')

    return data.articles
  } catch (error) {
    console.error('記事の取得に失敗しました:', error)
    return []
  }
}
