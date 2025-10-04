import { auth } from '@/auth'
import { redirect } from 'next/navigation'

const apiBaseUrl = process.env.RAILS_API_HOST || 'http://localhost:3000'

async function handleResponse(response: Response) {
  if (response.status === 401) {
    redirect('/signin')
  }

  if (!response.ok) {
    throw new Error(`API Error: ${response.status}`)
  }

  return response.json()
}

export const apiClient = {
  async get(endpoint: string, options: RequestInit = {}) {
    const session = await auth()
    if (!session) {
      throw new Error('User is not authenticated')
    }

    const headers = await this.getHeaders(
      session.user.jwtToken,
      options.headers,
    )

    const response = await fetch(`${apiBaseUrl}${endpoint}`, {
      method: 'GET',
      headers,
      ...options,
    })

    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`)
    }

    return handleResponse(response)
  },

  async post(endpoint: string, payload: unknown, options: RequestInit = {}) {
    const session = await auth()
    if (!session) {
      throw new Error('User is not authenticated')
    }

    const headers = await this.getHeaders(
      session.user.jwtToken,
      options.headers,
    )

    const response = await fetch(`${apiBaseUrl}${endpoint}`, {
      method: 'POST',
      headers,
      body: JSON.stringify(payload),
      ...options,
    })

    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`)
    }

    return handleResponse(response)
  },

  async getHeaders(
    jwtToken: string,
    additionalHeaders?: HeadersInit,
  ): Promise<Record<string, string>> {
    const baseHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${jwtToken}`,
    }

    if (additionalHeaders) {
      const additionalHeadersObj =
        additionalHeaders instanceof Headers
          ? Object.fromEntries(additionalHeaders.entries())
          : Array.isArray(additionalHeaders)
            ? Object.fromEntries(additionalHeaders)
            : additionalHeaders

      Object.assign(baseHeaders, additionalHeadersObj)
    }

    return baseHeaders
  },
}
