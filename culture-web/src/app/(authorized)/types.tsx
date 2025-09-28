export interface Tag {
  id: number
  name: string
  category: string
}

export interface Article {
  id: number
  title: string
  summary: string
  author: string
  published_at: string
  image_url?: string
  tags: Tag[]
}

export interface ArticleDetail extends Article {
  content: string
  content_format: string
  source_url?: string
  published: boolean
  created_at: string
  updated_at: string
}
