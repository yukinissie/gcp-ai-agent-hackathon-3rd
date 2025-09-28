import { apiClient } from '@/lib/apiClient'
import type { Article, ArticleDetail } from '../types'

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

export async function fetchArticleDetail(
  id: number,
): Promise<ArticleDetail | null> {
  try {
    const data: { article: ArticleDetail } = await apiClient.get(
      `/api/v1/articles/${id}`,
    )

    return data.article
  } catch (error) {
    console.error('記事詳細の取得に失敗しました:', error)
    return null
  }
}
