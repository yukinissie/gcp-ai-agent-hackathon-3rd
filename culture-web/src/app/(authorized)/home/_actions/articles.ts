'use server'

import type { Article } from '../_components/types'
import { apiClient } from '@/lib/apiClient'

export interface ArticleDetail extends Article {
  content: string
  content_format: string
  source_url?: string
  published: boolean
  created_at: string
  updated_at: string
}

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
