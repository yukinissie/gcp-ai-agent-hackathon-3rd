'use client'

import { Button, Dialog, Flex, Text, TextField } from '@radix-ui/themes'
import { signInUser } from '../_actions/signInUser'
import { useActionState } from 'react'
import { useFormStatus } from 'react-dom'
import Form from 'next/form'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <Button type="submit" disabled={pending}>
      {pending ? '送信中...' : 'ログイン'}
    </Button>
  )
}

export function LoginSection() {
  const [state, formAction] = useActionState(signInUser, {
    errorMessage: null as string | null,
  })

  return (
    <Dialog.Root>
      <Dialog.Trigger>
        <Button variant="surface" style={{ width: '100%' }}>
          ログイン
        </Button>
      </Dialog.Trigger>

      <Dialog.Content maxWidth="450px">
        <Dialog.Title>ログイン</Dialog.Title>
        <Flex direction="column" gap="4">
          <Dialog.Description size="2">
            自分だけのニュース体験を始めましょう！
          </Dialog.Description>
          <Form action={formAction}>
            <Flex direction="column" gap="4" as="div">
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
              {state.errorMessage && (
                <Text color="red" size="2">
                  {state.errorMessage}
                </Text>
              )}

              <Flex gap="3" justify="end" as="div">
                <Dialog.Close>
                  <Button variant="soft" color="gray">
                    キャンセル
                  </Button>
                </Dialog.Close>
                <SubmitButton />
              </Flex>
            </Flex>
          </Form>
        </Flex>
      </Dialog.Content>
    </Dialog.Root>
  )
}
