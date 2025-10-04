import { auth } from '@/auth'
import { UnauthenticatedScreen } from './_components/UnauthenticatedScreen'

type Props = {
  children: React.ReactNode
}

export default async function Layout(props: Props) {
  const session = await auth()
  if (!session) return <UnauthenticatedScreen />
  return <div>{props.children}</div>
}
