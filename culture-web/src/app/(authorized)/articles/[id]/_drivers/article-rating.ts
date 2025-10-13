'use server'

import { revalidatePath } from 'next/cache'
import { apiClient } from '@/lib/apiClient'

export interface ArticleRatingResponse {
  current_evaluation: 'good' | 'bad' | 'none'
  article: {
    id: number
    title: string
    good_count: number
    bad_count: number
  }
}

export async function rateArticle(
  articleId: number,
  activityType: 'good' | 'bad',
): Promise<ArticleRatingResponse | null> {
  try {
    const result = await apiClient.post(
      `/api/v1/articles/${articleId}/activities`,
      {
        activity_type: activityType,
      },
    )

    revalidatePath(`/articles/${articleId}`)

    return result
  } catch (error) {
    console.error('[Server Action] 記事評価エラー:', error)
    return null
  }
}

export async function rateArticleGood(articleId: number) {
  return rateArticle(articleId, 'good')
}

export async function rateArticleBad(articleId: number) {
  return rateArticle(articleId, 'bad')
}
