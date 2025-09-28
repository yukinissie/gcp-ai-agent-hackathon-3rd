import { notFound } from 'next/navigation'
import { fetchArticleDetail } from '../../_drivers/articles'
import { ArticleDetailClient } from '../_components/ArticleDetailClient'

interface PageProps {
  params: Promise<{
    id: string
  }>
}

export default async function ArticleDetailPage({ params }: PageProps) {
  const { id } = await params
  const articleId = parseInt(id)

  if (isNaN(articleId)) {
    notFound()
  }

  const article = await fetchArticleDetail(articleId)

  if (!article) {
    notFound()
  }

  return <ArticleDetailClient article={article} />
}
