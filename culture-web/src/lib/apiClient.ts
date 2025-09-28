import { auth } from '@/auth'

const apiBaseUrl = process.env.RAILS_API_HOST || 'http://localhost:3000'

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

    return response.json()
  },

  async post(endpoint: string, data: unknown, options: RequestInit = {}) {
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
      body: JSON.stringify(data),
      ...options,
    })

    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`)
    }

    return response.json()
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
