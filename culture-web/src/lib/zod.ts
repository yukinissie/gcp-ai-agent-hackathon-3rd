import { email, object, string } from 'zod'

export const signInSchema = object({
  email: email({
    message: 'Invalid email',
  }).min(1, 'Email is required'),
  password: string({
    message: 'Password is required',
  })
    .min(1, 'Password is required')
    .min(8, 'Password must be more than 8 characters')
    .max(32, 'Password must be less than 32 characters'),
  passwordConfirmation: string().optional(),
})
