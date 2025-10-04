'use client'

import * as Toast from '@radix-ui/react-toast'
import { useState, type FormEvent } from 'react'
import styles from './page.module.css'
import { Flex, TextField, Text, Button } from '@radix-ui/themes'
import Link from 'next/link'
import { signInUser } from '@/app/(anonymous)/_actions/signInUser'

export default function SignUp() {
  const [isLoading, setIsLoading] = useState(false)
  const [toastOpen, setToastOpen] = useState(false)
  const [toastMessage, setToastMessage] = useState('')

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsLoading(true)

    const formData = new FormData(e.currentTarget)

    try {
      const result = await signInUser(formData)

      if (result.errorMessage) {
        setToastMessage(result.errorMessage)
        setToastOpen(true)
        setIsLoading(false)
      }
    } catch (error) {
      console.error('Sign up error:', error)
      setIsLoading(false)
    }
  }

  return (
    <Toast.Provider swipeDirection="right">
      <Flex direction="column" align="center" mt="8" gap="6">
        <Text weight="bold" size="4">
          アカウント作成
        </Text>

        <Text size="2">自分だけのニュース体験を始めましょう！</Text>

        <form onSubmit={handleSubmit} style={{ width: '300px' }}>
          <Flex direction="column" gap="4">
            <label>
              <Text as="div" size="2" mb="1" weight="bold">
                メールアドレス
              </Text>
              <TextField.Root
                name="email"
                placeholder="email@example.com"
                type="email"
                required
              />
            </label>
            <label>
              <Text as="div" size="2" mb="1" weight="bold">
                パスワード
              </Text>
              <TextField.Root
                name="password"
                placeholder="password"
                type="password"
                required
              />
            </label>
            <label>
              <Text as="div" size="2" mb="1" weight="bold">
                パスワード（確認用）
              </Text>
              <TextField.Root
                name="passwordConfirmation"
                placeholder="password"
                type="password"
                required
              />
            </label>

            <Text size="1" color="gray" mt="3">
              登録すると、
              <Link target="_blank" href="/terms">
                利用規約
              </Link>
              と
              <Link target="_blank" href="/privacy">
                プライバシーポリシー
              </Link>
              に同意したことになります。
            </Text>

            <Flex justify="end">
              <Button
                type="submit"
                disabled={isLoading}
                loading={isLoading}
                style={{ width: '100%' }}
              >
                アカウント作成
              </Button>
            </Flex>

            <Text size="2" align="center" color="gray">
              すでにアカウントをお持ちの方は
              <Link href="/signin" className={styles.link}>
                ログイン
              </Link>
            </Text>
          </Flex>
        </form>
      </Flex>

      <Toast.Root
        className={styles.toastRoot}
        open={toastOpen}
        onOpenChange={setToastOpen}
        duration={5000}
      >
        <Toast.Title className={styles.toastTitle}>エラー</Toast.Title>
        <Toast.Description className={styles.toastDescription}>
          {toastMessage}
        </Toast.Description>
        <Toast.Close className={styles.toastClose}>×</Toast.Close>
      </Toast.Root>

      <Toast.Viewport className={styles.toastViewport} />
    </Toast.Provider>
  )
}
