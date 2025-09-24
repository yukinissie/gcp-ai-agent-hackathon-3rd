"use server";

import { auth } from "@/auth";
import { apiClient } from "@/lib/api-client";

// Simplified debug version without authentication dependencies
async function debugFetchUserAttributes() {
  try {
    console.log('🔍 DEBUG: Starting fetchUserAttributes debug...');
    
    // セッション確認
    const session = await auth();
    console.log('👤 Session:', session?.user ? 'Authenticated' : 'Not authenticated');
    console.log('🔑 JWT Token:', session?.user?.jwtToken ? 'Present' : 'Missing');
    
    if (!session?.user?.jwtToken) {
      console.log('❌ No authentication token found');
      return { success: false, error: 'Authentication required' };
    }

    console.log('📡 Calling Rails API /api/v1/user_attributes...');
    
    // Rails APIからユーザー属性を取得
    const rawData = await apiClient.get('/api/v1/user_attributes');
    console.log('✅ Raw Rails API response received');
    console.log('📊 Raw data structure:', JSON.stringify(rawData, null, 2));
    
    // データ構造の詳細分析
    console.log('🔍 Data structure analysis:');
    console.log('- Root keys:', Object.keys(rawData));
    console.log('- Has llm_payload:', rawData.llm_payload ? 'Yes' : 'No');
    console.log('- Total interactions:', rawData.total_interactions);
    console.log('- Diversity score:', rawData.diversity_score);
    
    if (rawData.llm_payload) {
      console.log('- LLM payload keys:', Object.keys(rawData.llm_payload));
      
      if (rawData.llm_payload.user_profile) {
        console.log('- User profile keys:', Object.keys(rawData.llm_payload.user_profile));
        console.log('- Personality type:', rawData.llm_payload.user_profile.personality_type);
      }
      
      if (rawData.llm_payload.tag_preferences) {
        console.log('- Tag preferences count:', rawData.llm_payload.tag_preferences.length);
        console.log('- First tag preference:', rawData.llm_payload.tag_preferences[0]);
      }
      
      if (rawData.llm_payload.activity_patterns) {
        console.log('- Activity patterns keys:', Object.keys(rawData.llm_payload.activity_patterns));
        console.log('- Good bad ratio:', rawData.llm_payload.activity_patterns.good_bad_ratio);
      }
    }
    
    return { success: true, rawData };
  } catch (error) {
    console.error('❌ Error in fetchUserAttributes debug:', error);
    console.error('Error type:', error?.constructor?.name);
    console.error('Error message:', error instanceof Error ? error.message : 'Unknown error');
    console.error('Error stack:', error instanceof Error ? error.stack : 'No stack trace');
    
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error',
      errorType: error?.constructor?.name
    };
  }
}

// Export for testing
export async function runUserAttributesDebug() {
  console.log('🧪 Starting fetchUserAttributes debug session...');
  const result = await debugFetchUserAttributes();
  console.log('📋 Debug result:', result.success ? '✅ SUCCESS' : '❌ FAILED');
  return result;
}