import type { Metadata } from "next";
import { Theme, ThemePanel } from "@radix-ui/themes";
import { ThemeProvider } from 'next-themes';
import { SessionProvider } from "next-auth/react";
import "./global.css";

export const metadata: Metadata = {
	// TODO: change title and description
	title: "Culture Web",
	description: "A web application for culture-related content",
	robots: "noindex, nofollow",
	viewport: {
		width: "device-width",
		initialScale: 1,
		maximumScale: 1,
		userScalable: false,
	},
};

export default function RootLayout({
	children,
}: Readonly<{
	children: React.ReactNode;
}>) {
	const useThemePanel = process.env.NODE_ENV !== "production" && false;
	return (
		<html lang="ja" suppressHydrationWarning>
			<body>
				<SessionProvider>
					<ThemeProvider attribute="class">
						<Theme accentColor="teal" grayColor="sage">
							{children}
							{useThemePanel && <ThemePanel />}
						</Theme>
					</ThemeProvider>
				</SessionProvider>
			</body>
		</html>
	);
}
