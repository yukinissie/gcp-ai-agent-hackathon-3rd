'use server'

import { signIn } from '@/auth'
import { AuthError } from 'next-auth'
import { isRedirectError } from 'next/dist/client/components/redirect-error'

export type SignInFormState = {
  errorMessage: string | null
}

export async function signInUser(
  prevStateOrFormData: SignInFormState | FormData = {
    errorMessage: null,
  },
  maybeFormData?: FormData,
): Promise<SignInFormState> {
  const formData =
    prevStateOrFormData instanceof FormData
      ? prevStateOrFormData
      : maybeFormData

  if (!formData) {
    return {
      errorMessage: 'フォームの送信内容が見つかりませんでした。',
    }
  }

  const entries = Object.fromEntries(formData.entries())
  const credentials: Record<string, string> = {}

  for (const [key, value] of Object.entries(entries)) {
    if (typeof value === 'string') {
      credentials[key] = value
    } else if (value instanceof File) {
      credentials[key] = value.name
    }
  }

  credentials.redirectTo = '/home'

  try {
    await signIn('credentials', credentials)
    return {
      errorMessage: null,
    }
  } catch (error) {
    if (error instanceof AuthError) {
      return {
        errorMessage: 'メールアドレスまたはパスワードが正しくありません。',
      }
    }

    if (isRedirectError(error)) {
      throw error
    }

    const errorMessage =
      error instanceof Error ? error.message : '不明なエラーが発生しました。'

    return {
      errorMessage,
    }
  }
}
