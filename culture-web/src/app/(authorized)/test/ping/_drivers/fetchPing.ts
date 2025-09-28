import { apiClient } from '@/lib/apiClient'

type FetchPingResult = {
  data: {
    id: number
    message: string
  } | null
  error: string | null
}

export async function fetchPing(): Promise<FetchPingResult> {
  try {
    const result = await apiClient.get(
      `${process.env.RAILS_API_HOST}/api/v1/ping`,
      {
        cache: 'no-store',
      },
    )

    return {
      data: result.data,
      error: null,
    }
  } catch (error) {
    return {
      data: null,
      error: `Failed to fetch data: ${error}`,
    }
  }
}
