"use server";

import { auth } from "@/auth";
import { apiClient } from "@/lib/api-client";

// saveNewsFetchHistory()の実装をテスト用にコピー
async function testSaveNewsFetchHistory(
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
		console.log('🚀 Starting saveNewsFetchHistory test...');
		
		// セッション確認
		const session = await auth();
		console.log('👤 Session:', session?.user ? 'Authenticated' : 'Not authenticated');
		console.log('🔑 JWT Token:', session?.user?.jwtToken ? 'Present' : 'Missing');
		
		// 記事IDの配列を抽出
		const articleIds = news.map(article => parseInt(article.id, 10)).filter(id => !isNaN(id));
		
		if (articleIds.length === 0) {
			console.log('❌ No valid article IDs found, skipping history save');
			return { success: false, error: 'No valid article IDs' };
		}

		console.log('📝 Article IDs to save:', articleIds);

		// apiClientを使用（認証ヘッダー自動追加）
		const result = await apiClient.post('/api/v1/tag_search_histories', {
			tag_search_history: {
				article_ids: articleIds
			}
		});

		console.log('✅ News fetch history saved successfully:', result);
		return { success: true, data: result };
	} catch (error) {
		console.error('❌ Error saving news fetch history:', error);
		return { 
			success: false, 
			error: error instanceof Error ? error.message : 'Unknown error',
			fallback: `Fallback log for user ${userId}: ${news.length} articles`
		};
	}
}

// テストデータ
export async function runSaveHistoryTest() {
	const userId = 1;
	const tags = ['AI', 'tech'];
	const sampleNews = [
		{
			id: '85',
			title: 'AI技術が変える音楽制作',
			url: 'http://localhost:3000/articles/85',
			source: '山田音楽研究所',
			publishedAt: new Date(),
			tags: ['AI']
		},
		{
			id: '84', 
			title: 'デジタルアートの新しい潮流',
			url: 'http://localhost:3000/articles/84',
			source: '田中美術',
			publishedAt: new Date(),
			tags: ['AI']
		}
	];
	
	console.log('🧪 Testing saveNewsFetchHistory with authentication...');
	console.log('📊 Test data:', {
		userId,
		tags,
		articleCount: sampleNews.length,
		articleIds: sampleNews.map(n => n.id)
	});
	
	const result = await testSaveNewsFetchHistory(userId, tags, sampleNews);
	console.log('📋 Test result:', result);
	
	return result;
}