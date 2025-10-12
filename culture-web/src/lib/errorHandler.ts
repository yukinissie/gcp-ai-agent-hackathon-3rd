'use client'

/**
 * Handle API errors and redirect to signin if unauthorized
 */
export function handleApiError(error: unknown): never {
  if (error instanceof Error && error.name === 'UnauthorizedError') {
    // Store current URL for redirect after login
    const currentPath = window.location.pathname
    const callbackUrl = currentPath !== '/' ? `?callbackUrl=${currentPath}` : ''
    window.location.href = `/signin${callbackUrl}`
    // TypeScript requires throwing or returning to satisfy 'never'
    throw new Error('Redirecting to signin')
  }

  throw error
}

/**
 * Wrap async functions to handle unauthorized errors
 */
export function withErrorHandler<
  T extends (...args: unknown[]) => Promise<unknown>,
>(fn: T): T {
  return (async (...args: unknown[]) => {
    try {
      return await fn(...args)
    } catch (error) {
      handleApiError(error)
    }
  }) as T
}
