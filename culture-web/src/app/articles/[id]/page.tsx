import { notFound } from 'next/navigation';
import { fetchArticleDetail } from '../../home/_actions/articles';
import { ArticleDetailClient } from '../_components/ArticleDetailClient';

interface PageProps {
  params: {
    id: string;
  };
}

export default async function ArticleDetailPage({ params }: PageProps) {
  const articleId = parseInt(params.id);
  
  if (isNaN(articleId)) {
    notFound();
  }

  const article = await fetchArticleDetail(articleId);

  if (!article) {
    notFound();
  }

  return (
    <ArticleDetailClient article={article} />
  );
}
