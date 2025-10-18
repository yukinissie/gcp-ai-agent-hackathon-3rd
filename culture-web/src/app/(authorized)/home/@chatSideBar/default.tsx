import { auth } from '@/auth'
import { ChatSideBarWrapper } from './_components/ChatSideBarWrapper'
import { UnauthorizedError } from '@/app/_components/error/UnauthorizedError'

export default async function ChatSideBarDefault() {
  const session = await auth()

  if (!session || !session.user || !session.user.id) {
    return <UnauthorizedError error="ユーザー情報を取得できませんでした。" />
  }

  return <ChatSideBarWrapper userId={session.user.id} />
}
