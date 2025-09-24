import { createTool } from "@mastra/core/tools";
import { z } from "zod";
import { determineNewsTagsAgent } from "../agents/determine-tags-agent";
import { apiClient } from "../../lib/api-client";

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
	try {
		console.log('🚀 fetchUserAttributes: Starting API call for userId:', userId);
		
		const data = await apiClient.get('/api/v1/user_attributes');
		console.log('✅ fetchUserAttributes: API call successful');
		console.log('📊 fetchUserAttributes: Raw API response:', JSON.stringify(data, null, 2));
		
		// Rails APIレスポンスをMastra形式に変換
		console.log('🔄 fetchUserAttributes: Starting transformation...');
		const transformedData = transformUserAttributesResponse(data);
		console.log('✅ fetchUserAttributes: Transformation complete:', JSON.stringify(transformedData, null, 2));
		
		return transformedData;
	} catch (error) {
		console.error('❌ fetchUserAttributes: Error occurred:', error);
		console.error('❌ fetchUserAttributes: Error type:', error?.constructor?.name);
		console.error('❌ fetchUserAttributes: Error message:', error instanceof Error ? error.message : 'Unknown error');
		console.log('⚠️ fetchUserAttributes: Using fallback data');
		// フォールバック: ダミーデータを返す
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
}

// Rails APIレスポンスをMastra形式に変換する関数
function transformUserAttributesResponse(data: any): UserAttributesResponse {
	console.log('🔍 Transform: Analyzing API response structure...');
	console.log('🔍 Transform: Root keys:', Object.keys(data));
	console.log('🔍 Transform: Has llm_payload:', !!data.llm_payload);
	console.log('🔍 Transform: Total interactions:', data.total_interactions);
	console.log('🔍 Transform: Diversity score:', data.diversity_score);
	
	const llmPayload = data.llm_payload || {};
	console.log('🔍 Transform: LLM payload keys:', Object.keys(llmPayload));
	
	const userProfile = llmPayload.user_profile || {};
	console.log('🔍 Transform: User profile keys:', Object.keys(userProfile));
	console.log('🔍 Transform: Personality type:', userProfile.personality_type);
	
	const tagPreferences = llmPayload.tag_preferences || [];
	console.log('🔍 Transform: Tag preferences count:', tagPreferences.length);
	if (tagPreferences.length > 0) {
		console.log('🔍 Transform: First tag preference:', tagPreferences[0]);
	}
	
	const activityPatterns = llmPayload.activity_patterns || {};
	console.log('🔍 Transform: Activity patterns keys:', Object.keys(activityPatterns));
	console.log('🔍 Transform: Good bad ratio:', activityPatterns.good_bad_ratio);

	// タグ嗜好の変換とスコア計算
	const convertedTagPreferences = tagPreferences.map((pref: any, index: number) => {
		const totalInteractions = (pref.good_count || 0) + (pref.bad_count || 0);
		const score = Math.round(pref.preference_score * 1000); // 0-1を0-1000スケールに変換
		const weight = Math.max(0.1, 1 / (index + 1)); // 順位に基づく重み（最低0.1）
		
		return {
			tag: pref.tag,
			score: score,
			weight: weight,
			interactions: totalInteractions,
		};
	});

	// 読書行動の推定
	const totalInteractions = data.total_interactions || 0;
	const goodBadRatio = activityPatterns.good_bad_ratio || 1.0;
	const avgEngagementRate = Math.min(0.95, Math.max(0.1, goodBadRatio / (goodBadRatio + 1))); // 0.1-0.95の範囲
	
	// 読書頻度の推定（総インタラクション数から推定）
	let readingFrequency = "casual";
	if (totalInteractions >= 100) readingFrequency = "daily";
	else if (totalInteractions >= 50) readingFrequency = "weekly";
	else if (totalInteractions >= 10) readingFrequency = "monthly";

	return {
		userProfile: {
			personalityType: userProfile.personality_type || "casual_reader",
			totalInteractions: totalInteractions,
			diversityScore: data.diversity_score || 0.0,
		},
		tagPreferences: convertedTagPreferences,
		readingBehavior: {
			totalArticlesRead: totalInteractions, // 評価数を読了数の代用とする
			avgEngagementRate: avgEngagementRate,
			readingFrequency: readingFrequency,
		},
	};
}

async function fetchAllTags(): Promise<string[]> {
	try {
		const data = await apiClient.get('/api/v1/tags');
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
		const data = await apiClient.get(`/api/v1/articles?tags=${encodeURIComponent(tagsParam)}`);
		
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
	try {
		// 記事IDの配列を抽出
		const articleIds = news.map(article => parseInt(article.id, 10)).filter(id => !isNaN(id));
		
		if (articleIds.length === 0) {
			console.log('No valid article IDs found, skipping history save');
			return;
		}

		// apiClientを使用（認証ヘッダー自動追加）
		const result = await apiClient.post('/api/v1/tag_search_histories', {
			tag_search_history: {
				article_ids: articleIds
			}
		});

		console.log('News fetch history saved successfully:', result);
	} catch (error) {
		console.error('Error saving news fetch history:', error);
		// フォールバック: ログ出力のみ
		console.log(`Fallback: Saving news fetch history for user ${userId}:`, {
			tags,
			news: news.map(n => ({ id: n.id, title: n.title })),
		});
	}
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
