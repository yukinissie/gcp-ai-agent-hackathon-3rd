import { ArticleList } from './_components/ArticleList'
import { fetchArticles } from './_drivers/fetchArticles'
import { fetchTagSearchHistoryArticles } from './_drivers/fetchTagSearchHistoryArticles'

export default async function ArticlesPage() {
  const articles = await fetchArticles()
  const tagSearchHistoryArticles = await fetchTagSearchHistoryArticles()
  return (
    <ArticleList
      articles={
        tagSearchHistoryArticles.length > 0
          ? tagSearchHistoryArticles
          : articles
      }
    />
  )
}
