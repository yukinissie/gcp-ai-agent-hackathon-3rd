import { PostgresStore } from '@mastra/pg'
import { LibSQLStore } from '@mastra/libsql'

// Use PostgreSQL for production, memory storage for development
export async function getStorage() {
  if (process.env.NODE_ENV === 'production') {
    try {
      // Dynamic import to avoid initialization issues
      console.log('Using PostgresStore for storage')

      const connectionString =
        process.env.DATABASE_URL ||
        `postgresql://${process.env.DATABASE_USER || 'postgres'}:${process.env.DATABASE_PASSWORD || 'password'}@${process.env.DATABASE_HOST || 'localhost'}:5432/${process.env.DATABASE_NAME || 'culture_rails_development'}`

      return new PostgresStore({
        connectionString,
      })
    } catch (error) {
      console.error(
        'Failed to initialize PostgresStore, falling back to LibSQL:',
        error,
      )
      throw new Error('Failed to initialize PostgresStore')
    }
  }

  console.log('Using LibSQLStore for storage')
  return new LibSQLStore({
    url: ':memory:',
  })
}
