import { apiClient } from '@/lib/apiClient'
import type { Article } from '../../types'

export async function fetchTagSearchHistoryArticles(): Promise<Article[]> {
  try {
    const data: { data: { articles: Article[] } } = await apiClient.get(
      '/api/v1/tag_search_histories/articles',
    )

    console.log('タグ検索履歴記事一覧の取得に成功しました:', data)

    return data.data.articles
  } catch (error) {
    console.error('タグ検索履歴記事一覧の取得に失敗しました:', error)
    return []
  }
}
