import type { Metadata } from "next";
import { Theme, ThemePanel } from "@radix-ui/themes";
import "@radix-ui/themes/styles.css";
import "./global.css";

export const metadata: Metadata = {
  // TODO: change title and description
  title: "Culture Web",
  description: "A web application for culture-related content",
  robots: "noindex, nofollow",
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
        <Theme accentColor="teal" grayColor="sage" appearance="dark">
          {children}
          {useThemePanel && <ThemePanel />}
        </Theme>
      </body>
    </html>
  );
}
