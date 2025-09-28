'use server'

import { apiClient } from '@/lib/apiClient'
import { revalidatePath } from 'next/cache'

export async function postPing(formData: FormData) {
  await apiClient.post('/api/v1/ping', {
    message: formData.get('message'),
  })
  revalidatePath('/ping')
}
