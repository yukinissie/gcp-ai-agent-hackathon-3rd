"use server";

import { auth } from "@/auth";
import { apiClient } from "@/lib/api-client";

// Rails APIレスポンスをMastra形式に変換する関数（テスト用にコピー）
function transformUserAttributesResponse(data: any) {
	const llmPayload = data.llm_payload || {};
	const userProfile = llmPayload.user_profile || {};
	const tagPreferences = llmPayload.tag_preferences || [];
	const activityPatterns = llmPayload.activity_patterns || {};

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

async function testFetchUserAttributes() {
	try {
		console.log('🚀 Starting fetchUserAttributes test...');
		
		// セッション確認
		const session = await auth();
		console.log('👤 Session:', session?.user ? 'Authenticated' : 'Not authenticated');
		console.log('🔑 JWT Token:', session?.user?.jwtToken ? 'Present' : 'Missing');
		
		if (!session?.user?.jwtToken) {
			return { success: false, error: 'Authentication required' };
		}

		console.log('📡 Calling Rails API /api/v1/user_attributes...');
		
		// Rails APIからユーザー属性を取得
		const rawData = await apiClient.get('/api/v1/user_attributes');
		console.log('✅ Raw Rails API response:', JSON.stringify(rawData, null, 2));
		
		// Mastra形式に変換
		const transformedData = transformUserAttributesResponse(rawData);
		console.log('🔄 Transformed data for Mastra:', JSON.stringify(transformedData, null, 2));
		
		// 変換結果の検証
		console.log('📊 Transformation summary:');
		console.log(`- Personality Type: ${transformedData.userProfile.personalityType}`);
		console.log(`- Total Interactions: ${transformedData.userProfile.totalInteractions}`);
		console.log(`- Diversity Score: ${transformedData.userProfile.diversityScore}`);
		console.log(`- Tag Preferences: ${transformedData.tagPreferences.length} tags`);
		console.log(`- Reading Frequency: ${transformedData.readingBehavior.readingFrequency}`);
		console.log(`- Engagement Rate: ${transformedData.readingBehavior.avgEngagementRate}`);
		
		return { success: true, rawData, transformedData };
	} catch (error) {
		console.error('❌ Error in fetchUserAttributes test:', error);
		return { 
			success: false, 
			error: error instanceof Error ? error.message : 'Unknown error' 
		};
	}
}

// テスト実行用エクスポート
export async function runUserAttributesTest() {
	console.log('🧪 Testing fetchUserAttributes with Rails API integration...');
	const result = await testFetchUserAttributes();
	console.log('📋 Test result:', result.success ? '✅ SUCCESS' : '❌ FAILED');
	return result;
}