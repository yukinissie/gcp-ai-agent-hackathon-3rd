import { auth } from '@/auth'
import { HomeClient } from './_components/HomeClient'

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

  return <HomeClient userId={session.user.id} />
}
