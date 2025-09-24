import { createTool } from "@mastra/core/tools";
import { z } from "zod";
import { determineNewsTagsAgent } from "../agents/determine-tags-agent";

export const newsCurationTool = createTool({
	id: "news-curation",
	description: "Get information for news curation based on user attributes",
	inputSchema: z.object({
		userId: z.number().describe("User ID"),
	}),
	outputSchema: z.object({
		userAttributes: z.object({
			userProfile: z.object({
				personalityType: z.string(),
				totalInteractions: z.number(),
				diversityScore: z.number(),
			}),
			tagPreferences: z.array(
				z.object({
					tag: z.string(),
					score: z.number(),
					weight: z.number(),
					interactions: z.number(),
				}),
			),
			readingBehavior: z.object({
				totalArticlesRead: z.number(),
				avgEngagementRate: z.number(),
				readingFrequency: z.string(),
			}),
		}),
		tags: z.array(z.string()),
		news: z.array(
			z.object({
				id: z.string(),
				title: z.string(),
				url: z.url(),
				source: z.string(),
				publishedAt: z.date(),
				tags: z.array(z.string()),
			}),
		),
	}),
	execute: async ({ context }) => {
		return await getInfoForCuration(context.userId);
	},
});

type UserAttributesResponse = {
	userProfile: {
		personalityType: string;
		totalInteractions: number;
		diversityScore: number;
	};
	tagPreferences: {
		tag: string;
		score: number;
		weight: number;
		interactions: number;
	}[];
	readingBehavior: {
		totalArticlesRead: number;
		avgEngagementRate: number;
		readingFrequency: string;
	};
};

async function fetchUserAttributes(
	userId: number,
): Promise<UserAttributesResponse> {
	// ダミー実装: 実際にはAPIやDBから取得する
	return {
		userProfile: {
			personalityType: "tech_enthusiast",
			totalInteractions: 342,
			diversityScore: 0.73,
		},
		tagPreferences: [
			{
				tag: "AI",
				score: 850,
				weight: 0.25,
				interactions: 45,
			},
			{
				tag: "startup",
				score: 620,
				weight: 0.18,
				interactions: 32,
			},
		],
		readingBehavior: {
			totalArticlesRead: 342,
			avgEngagementRate: 0.68,
			readingFrequency: "daily",
		},
	};
}

async function fetchAllTags(): Promise<string[]> {
	try {
		const response = await fetch('http://localhost:3000/api/v1/tags', {
			method: 'GET',
			headers: {
				'Content-Type': 'application/json',
			},
		});

		if (!response.ok) {
			throw new Error(`API Error: ${response.status} ${response.statusText}`);
		}

		const data = await response.json();
		return data.tags.map((tag: { name: string }) => tag.name);
	} catch (error) {
		console.error('Error fetching tags:', error);
		// フォールバック
		return ["AI", "startup", "health", "sports", "entertainment"];
	}
}

export const DetermineTagList = z.array(z.string());

async function determineTags(
	userAttributes: UserAttributesResponse,
	allTags: string[],
): Promise<string[]> {
	// Mastraのサブエージェント（DetermineNewsTagsAgent）を呼び出してタグを決定する
	try {
		const result = await determineNewsTagsAgent.generateVNext(
			[
				{
					role: "user",
					content: `Analyze user attributes and determine optimal news tags.

					User Attributes: ${JSON.stringify(userAttributes, null, 2)}
					Available System Tags: ${JSON.stringify(allTags, null, 2)}

					Please analyze the user's preferences and return the most relevant tags for news curation.

					Please strictly follow the JSON Schema below and return **JSON only**. No explanatory text before or after.
					Schema:
						["tag1", "tag2", ...]`,
				},
			],
			{
				format: "aisdk",
			},
		);

		console.log("DetermineTagsAgent result:", result);

		return JSON.parse(result.text) as string[];
	} catch (error) {
		console.error("Error in determineTags:", error);
		// フォールバック: ユーザーの上位嗜好タグを返す
		return userAttributes.tagPreferences
			.sort((a, b) => b.score - a.score)
			.slice(0, 3)
			.map((pref) => pref.tag)
			.filter((tag) => allTags.includes(tag));
	}
}

async function fetchNewsByTags(tags: string[]) {
	try {
		if (tags.length === 0) {
			return [];
		}

		const tagsParam = tags.join(',');
		const response = await fetch(`http://localhost:3000/api/v1/articles?tags=${encodeURIComponent(tagsParam)}`, {
			method: 'GET',
			headers: {
				'Content-Type': 'application/json',
			},
		});

		if (!response.ok) {
			throw new Error(`API Error: ${response.status} ${response.statusText}`);
		}

		const data = await response.json();
		return data.articles.map((article: any) => ({
			id: article.id.toString(),
			title: article.title,
			url: article.source_url || `http://localhost:3000/articles/${article.id}`,
			source: article.author || "Unknown",
			publishedAt: new Date(article.published_at),
			tags: article.tags.map((tag: any) => tag.name),
		}));
	} catch (error) {
		console.error('Error fetching news by tags:', error);
		return tags.map((tag, idx) => ({
			id: `news-${tag}-${idx}`,
			title: `Latest updates in ${tag}`,
			url: `https://news.example.com/${tag}/${idx}`,
			source: "Example News",
			publishedAt: new Date(),
			tags: [tag],
		}));
	}
}

async function saveNewsFetchHistory(
	userId: number,
	tags: string[],
	news: {
		id: string;
		title: string;
		url: string;
		source: string;
		publishedAt: Date;
		tags: string[];
	}[],
) {
	// ダミー実装: 実際にはAPIやDBに保存する
	console.log(`Saving news fetch history for user ${userId}:`, {
		tags,
		news,
	});
	// 例: Rails APIにPOSTリクエストを送る場合
	// await fetch(`${process.env.RAILS_API_URL}/api/news/fetch-history`, {
	// 	method: "POST",
	// 	headers: { "Content-Type": "application/json" },
	// 	body: JSON.stringify({ userId, tags, news }),
	// });
}

const getInfoForCuration = async (userId: number) => {
	// userId を使ってユーザーの属性を取得する。
	const userAttributes = await fetchUserAttributes(userId);
	// 全てのタグを取得する。
	const allTags = await fetchAllTags();
	// 属性情報を元にニュース取得用のタグを決定する。全てのタグを使って存在チェックを行う（Agentが行う）
	const tags = await determineTags(userAttributes, allTags);
	// タグに基づいてニュースを検索する。（Rails）
	const news = await fetchNewsByTags(tags);
	// 取得したニュースを履歴テーブルに保存する。（Rails）
	await saveNewsFetchHistory(userId, tags, news);
	// その上で返却する。
	return {
		userAttributes,
		tags,
		news,
	};
};
