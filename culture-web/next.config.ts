import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
	output: "standalone",
	turbopack: {
		root: path.join(__dirname, "."),
	},
	serverExternalPackages: ["@mastra/*"],
	async headers() {
		return [
			// HTML & SSR: キャッシュしない
			{
				source: "/((?!_next/).*)", // _next配下以外（必要に応じて除外を追加）
				headers: [
					{ key: "Cache-Control", value: "no-store" }, // もしくは "s-maxage=0, must-revalidate"
				],
			},
			// Nextのビルド静的アセット: 長期キャッシュ
			{
				source: "/_next/static/:path*",
				headers: [
					{
						key: "Cache-Control",
						value: "public, max-age=31536000, immutable",
					},
				],
			},
			// public配下でバージョン付きにできないものは短命に
			{
				source: "/:file*(svg|png|jpg|jpeg|gif|webp|ico)",
				headers: [{ key: "Cache-Control", value: "public, max-age=3600" }],
			},
			// Next/Image
			{
				source: "/_next/image",
				headers: [
					{
						key: "Cache-Control",
						value: "public, s-maxage=86400, stale-while-revalidate=604800",
					},
				],
			},
		];
	},
};

export default nextConfig;
