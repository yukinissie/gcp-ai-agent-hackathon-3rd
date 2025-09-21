import { Button, Dialog, Flex, Link, Text, TextField } from "@radix-ui/themes";
import { signInUser } from "../_actions/signInUser";

export function RegisterSection() {
	return (
		<Dialog.Root>
			<Dialog.Trigger>
				<Button>新規登録</Button>
			</Dialog.Trigger>

			<Dialog.Content maxWidth="450px">
				<Dialog.Title>新規登録</Dialog.Title>
				<form action={signInUser}>
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
						<Flex gap="3" justify="end">
							<Dialog.Close>
								<Button variant="soft" color="gray">
									キャンセル
								</Button>
							</Dialog.Close>
							<Dialog.Close>
								<Button type="submit">新規登録</Button>
							</Dialog.Close>
						</Flex>
					</Flex>
				</form>
			</Dialog.Content>
		</Dialog.Root>
	);
}
