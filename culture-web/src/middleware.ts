import { auth } from '@/auth'
import { NextResponse } from 'next/server'

export default auth((req) => {
  const isAuthenticated = !!req.auth
  const pathname = req.nextUrl.pathname

  // Public paths that don't require authentication
  const publicPaths = [
    '/signin',
    '/signup',
    '/api/auth',
    '/about',
    '/terms',
    '/privacy',
  ]
  const isPublicPath = publicPaths.some((path) => pathname.startsWith(path))

  // Redirect to signin page if not authenticated and not on a public path
  if (!isAuthenticated && !isPublicPath) {
    const signinUrl = new URL('/signin', req.url)
    return NextResponse.redirect(signinUrl)
  }

  return NextResponse.next()
})

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
