import { auth } from '@/auth'

type Props = {
  children: React.ReactNode
}

export default async function Layout(props: Props) {
  const session = await auth()
  if (!session) return <div>Not authenticated</div>
  return <div>{props.children}</div>
}
