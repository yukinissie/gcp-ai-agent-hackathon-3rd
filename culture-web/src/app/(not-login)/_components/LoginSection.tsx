import { Button, Dialog, Flex, Text, TextField } from "@radix-ui/themes";
import { signInUser } from "../_actions/signInUser";

export function LoginSection() {
	return (
		<Dialog.Root>
			<Dialog.Trigger>
				<Button>ログイン</Button>
			</Dialog.Trigger>

			<Dialog.Content maxWidth="450px">
				<Dialog.Title>ログイン</Dialog.Title>
				<Flex direction="column" gap="4">
					<Dialog.Description size="2">
						自分だけのニュース体験を始めましょう！
					</Dialog.Description>
					<form action={signInUser}>
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
						</Flex>
						<Flex gap="3" justify="end">
							<Dialog.Close>
								<Button variant="soft" color="gray">
									キャンセル
								</Button>
							</Dialog.Close>
							<Dialog.Close>
								<Button type="submit">ログイン</Button>
							</Dialog.Close>
						</Flex>
					</form>
				</Flex>
			</Dialog.Content>
		</Dialog.Root>
	);
}
