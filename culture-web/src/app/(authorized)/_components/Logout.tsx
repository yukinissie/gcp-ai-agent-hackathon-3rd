import { Button, Dialog, Flex } from "@radix-ui/themes";
import { signOutUser } from "../_actions/signOutUser";

export function LogoutSection() {
	return (
		<Dialog.Root>
			<Dialog.Trigger>
				<Button>ログアウト</Button>
			</Dialog.Trigger>
			<Dialog.Content maxWidth="450px">
				<Dialog.Title>ログアウト</Dialog.Title>
				<Dialog.Description size="2" mb="4">
					またのご利用をお待ちしております！
				</Dialog.Description>
				<Flex gap="3" mt="4" justify="end">
					<Dialog.Close>
						<Button variant="soft" color="gray">
							キャンセル
						</Button>
					</Dialog.Close>
					<form action={signOutUser}>
						<Dialog.Close>
							<Button type="submit">ログアウト</Button>
						</Dialog.Close>
					</form>
				</Flex>
			</Dialog.Content>
		</Dialog.Root>
	);
}
