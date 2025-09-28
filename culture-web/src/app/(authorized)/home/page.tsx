import { auth } from '@/auth'
import { HomeClient } from './_components/HomeClient'
import { fetchArticles } from './_drivers/fetchArticles'
import { fetchTagSearchHistoryArticles } from './_drivers/fetchTagSearchHistoryArticles'

export default async function Home() {
  const session = await auth()

  if (!session || !session.user || !session.user.id) {
    return (
      <div>
        <h1>認証エラー</h1>
        <p>ユーザー情報を取得できませんでした。</p>
      </div>
    )
  }

  const articles = await fetchArticles()
  const tagSearchHistoryArticles = await fetchTagSearchHistoryArticles()
  return (
    <HomeClient
      userId={session.user.id}
      articles={
        tagSearchHistoryArticles.length > 0
          ? tagSearchHistoryArticles
          : articles
      }
    />
  )
}
