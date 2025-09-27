'use server'

import { auth } from '@/auth'
import { Article } from '../_components/types'

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
    const baseUrl = process.env.RAILS_API_HOST || 'http://localhost:3000'
    const response = await fetch(`${baseUrl}/api/v1/articles`, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/json',
      },
      next: {
        revalidate: 60,
      },
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()

    if (data.articles && Array.isArray(data.articles)) {
      return data.articles
    }

    return []
  } catch (error) {
    console.error('記事の取得に失敗しました:', error)
    return []
  }
}

export async function fetchArticleDetail(
  id: number,
): Promise<ArticleDetail | null> {
  try {
    const session = await auth()
    const baseUrl = process.env.RAILS_API_HOST

    const headers: Record<string, string> = {
      Accept: 'application/json',
      'Content-Type': 'application/json',
    }

    // JWT認証がある場合はヘッダーに追加
    if (session?.user?.jwtToken) {
      headers['Authorization'] = `Bearer ${session.user.jwtToken}`
    }

    const response = await fetch(`${baseUrl}/api/v1/articles/${id}`, {
      method: 'GET',
      headers,
      next: {
        revalidate: 60,
      },
    })

    if (!response.ok) {
      if (response.status === 404) {
        return null
      }
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const data = await response.json()

    if (data.article) {
      return data.article
    }

    return null
  } catch (error) {
    console.error('記事詳細の取得に失敗しました:', error)
    return null
  }
}
