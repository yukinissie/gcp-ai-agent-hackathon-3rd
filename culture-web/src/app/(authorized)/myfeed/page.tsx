import { Flex, Link } from "@radix-ui/themes";
import { LogoutSection } from "../_components/Logout";

export default function PocPage() {
	return (
		<Flex
			justify="center"
			align="center"
			height="100vh"
			direction="column"
			gap="4"
		>
			<LogoutSection />
			<Link href="/test" size="1">
				Test
			</Link>
		</Flex>
	);
}
