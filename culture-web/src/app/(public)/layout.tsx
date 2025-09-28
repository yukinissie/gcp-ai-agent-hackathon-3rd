import { PublicHeader } from './_components/PublicHeader'

export default function PublicLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div
      style={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}
    >
      <PublicHeader />
      <main style={{ flex: 1 }}>{children}</main>
    </div>
  )
}
