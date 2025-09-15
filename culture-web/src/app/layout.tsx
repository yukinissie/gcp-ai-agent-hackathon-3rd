import type { Metadata } from "next";

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
  return (
    <html lang="ja" suppressHydrationWarning>
      <body>{children}</body>
    </html>
  );
}
