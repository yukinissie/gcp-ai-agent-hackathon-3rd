import type { Metadata } from "next";

export const metadata: Metadata = {
  // TODO: change title and description
  title: "Culture Web",
  description: "A web application for culture-related content",
  robots: "noindex, nofollow",
  icons: {
    icon: "/favicon.ico",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ja">
      <body>{children}</body>
    </html>
  );
}
