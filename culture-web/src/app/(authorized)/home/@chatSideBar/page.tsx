import { auth } from '@/auth'
import { ChatSideBarWrapper } from './_components/ChatSideBarWrapper'

export default async function ChatSideBarPage() {
  const session = await auth()

  if (!session || !session.user || !session.user.id) {
    return (
      <div>
        <h1>認証エラー</h1>
        <p>ユーザー情報を取得できませんでした。</p>
      </div>
    )
  }

  return <ChatSideBarWrapper userId={session.user.id} />
}
