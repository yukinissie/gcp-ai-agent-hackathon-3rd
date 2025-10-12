import type { ArticleDetail } from '../../../types'
import { apiClient, UnauthorizedError } from '@/lib/apiClient'

export async function fetchArticleDetail(
  id: number,
): Promise<ArticleDetail | null> {
  try {
    const data: { article: ArticleDetail } = await apiClient.get(
      `/api/v1/articles/${id}`,
    )

    return data.article
  } catch (error) {
    // UnauthorizedError should be re-thrown to be caught by error.tsx
    if (error instanceof UnauthorizedError) {
      throw error
    }
    console.error('記事詳細の取得に失敗しました:', error)
    return null
  }
}
