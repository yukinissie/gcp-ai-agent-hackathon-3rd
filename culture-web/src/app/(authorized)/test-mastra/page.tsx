'use client'

import { apiClient } from '@/lib/apiClient'
import { useState } from 'react'

export default function TestMastraPage() {
  const [result, setResult] = useState<any>(null)
  const [loading, setLoading] = useState(false)

  const testUserAttributes = async () => {
    setLoading(true)
    setResult(null)

    try {
      console.log('🧪 Starting fetchUserAttributes test from client...')

      // Next.js Server Actionを使ってテスト実行
      const result = await apiClient.post('/api/test-user-attributes', {})
      console.log('📊 Test result:', result)
      setResult(result)
    } catch (error) {
      console.error('❌ Test failed:', error)
      setResult({
        error: error instanceof Error ? error.message : 'Unknown error',
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Mastra User Attributes Test</h1>

      <button
        onClick={testUserAttributes}
        disabled={loading}
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded disabled:opacity-50"
      >
        {loading ? 'Testing...' : 'Test fetchUserAttributes()'}
      </button>

      {result && (
        <div className="mt-6">
          <h2 className="text-xl font-semibold mb-4">Test Result:</h2>
          <pre className="bg-gray-100 p-4 rounded overflow-auto max-h-96">
            {JSON.stringify(result, null, 2)}
          </pre>
        </div>
      )}
    </div>
  )
}
