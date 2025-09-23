import { auth } from "@/auth";
import { redirect } from "next/navigation";

export default async function AnonymousLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	const session = await auth();
	if (session) {
		redirect("/home");
	}
	return <>{children}</>;
}
