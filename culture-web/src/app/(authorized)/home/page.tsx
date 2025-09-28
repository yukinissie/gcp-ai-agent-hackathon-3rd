import { auth } from '@/auth'
import { HomeClient } from './_components/HomeClient'
import { fetchArticles } from './_actions/articles'

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
  return <HomeClient userId={session.user.id} articles={articles} />
}
