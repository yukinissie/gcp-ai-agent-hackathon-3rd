import NextAuth from 'next-auth'

declare module 'next-auth' {
  interface Session {
    user: {
      id: string
      jwtToken: string
    } & DefaultSession['user']
  }

  interface User {
    id: string
    jwtToken: string
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    userId: string
    jwtToken: string
  }
}
