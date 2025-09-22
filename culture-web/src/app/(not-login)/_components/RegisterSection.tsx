"use client";

import { Button, Dialog, Flex, Link, Text, TextField } from "@radix-ui/themes";
import { useActionState } from "react";
import { useFormStatus } from "react-dom";
import { signInUser } from "../_actions/signInUser";

function SubmitButton() {
	const { pending } = useFormStatus();

	return (
		<Button type="submit" disabled={pending}>
			{pending ? "送信中..." : "新規登録"}
		</Button>
	);
}

export function RegisterSection() {
	const [state, formAction] = useActionState(signInUser, {
		errorMessage: null as string | null,
	});

	return (
		<Dialog.Root>
			<Dialog.Trigger>
				<Button>新規登録</Button>
			</Dialog.Trigger>

			<Dialog.Content maxWidth="450px">
				<Dialog.Title>新規登録</Dialog.Title>
				<form action={formAction}>
					<Flex direction="column" gap="4">
						<Dialog.Description size="2">
							自分だけのニュース体験を始めましょう！
						</Dialog.Description>
						<Flex direction="column" gap="4">
							<label>
								<Text as="div" size="2" mb="1" weight="bold">
									メールアドレス
								</Text>
								<TextField.Root name="email" placeholder="email@example.com" />
							</label>
							<label>
								<Text as="div" size="2" mb="1" weight="bold">
									パスワード
								</Text>
								<TextField.Root
									name="password"
									placeholder="password"
									type="password"
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
								/>
							</label>
						</Flex>
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
						{state.errorMessage && (
							<Text color="red" size="2">
								{state.errorMessage}
							</Text>
						)}
						<Flex gap="3" justify="end">
							<Dialog.Close>
								<Button variant="soft" color="gray">
									キャンセル
								</Button>
							</Dialog.Close>
							<SubmitButton />
						</Flex>
					</Flex>
				</form>
			</Dialog.Content>
		</Dialog.Root>
	);
}
