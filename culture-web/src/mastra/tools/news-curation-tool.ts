import { createTool } from '@mastra/core/tools'
import { z } from 'zod'
import { determineNewsTagsAgent } from '../agents/determine-tags-agent'
import { apiClient } from '../../lib/apiClient'

export const newsCurationTool = createTool({
  id: 'news-curation',
  description: 'Get information for news curation based on user attributes',
  inputSchema: z.object({
    userId: z.number().describe('User ID'),
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
    return await getInfoForCuration(context.userId)
  },
})

type UserAttributesResponse = {
  userProfile: {
    personalityType: string
    totalInteractions: number
    diversityScore: number
  }
  tagPreferences: {
    tag: string
    score: number
    weight: number
    interactions: number
  }[]
  readingBehavior: {
    totalArticlesRead: number
    avgEngagementRate: number
    readingFrequency: string
  }
}

async function fetchUserAttributes(
  userId: number,
): Promise<UserAttributesResponse> {
  try {
    const data = await apiClient.get('/api/v1/user_attributes')
    return transformUserAttributesResponse(data)
  } catch (error) {
    console.error('❌ fetchUserAttributes: Error occurred: ', error)
    throw new Error('Failed to fetch user attributes')
  }
}

// Rails APIレスポンスをMastra形式に変換する関数
function transformUserAttributesResponse(data: any): UserAttributesResponse {
  const llmPayload = data.llm_payload || {}
  const userProfile = llmPayload.user_profile || {}
  const tagPreferences = llmPayload.tag_preferences || []
  const activityPatterns = llmPayload.activity_patterns || {}
  const convertedTagPreferences = tagPreferences.map(
    (pref: any, index: number) => {
      const totalInteractions = (pref.good_count || 0) + (pref.bad_count || 0)
      const score = Math.round(pref.preference_score * 1000) // 0-1を0-1000スケールに変換
      const weight = Math.max(0.1, 1 / (index + 1)) // 順位に基づく重み（最低0.1）

      return {
        tag: pref.tag,
        score: score,
        weight: weight,
        interactions: totalInteractions,
      }
    },
  )

  // 読書行動の推定
  const totalInteractions = data.total_interactions || 0
  const goodBadRatio = activityPatterns.good_bad_ratio || 1.0
  const avgEngagementRate = Math.min(
    0.95,
    Math.max(0.1, goodBadRatio / (goodBadRatio + 1)),
  ) // 0.1-0.95の範囲

  // 読書頻度の推定（総インタラクション数から推定）
  let readingFrequency = 'casual'
  if (totalInteractions >= 100) readingFrequency = 'daily'
  else if (totalInteractions >= 50) readingFrequency = 'weekly'
  else if (totalInteractions >= 10) readingFrequency = 'monthly'

  return {
    userProfile: {
      personalityType: userProfile.personality_type || 'casual_reader',
      totalInteractions: totalInteractions,
      diversityScore: data.diversity_score || 0.0,
    },
    tagPreferences: convertedTagPreferences,
    readingBehavior: {
      totalArticlesRead: totalInteractions, // 評価数を読了数の代用とする
      avgEngagementRate: avgEngagementRate,
      readingFrequency: readingFrequency,
    },
  }
}

async function fetchAllTags(): Promise<string[]> {
  try {
    const data = await apiClient.get('/api/v1/tags')
    return data.tags.map((tag: { name: string }) => tag.name)
  } catch (error) {
    console.error('Error fetching tags:', error)
    throw new Error('Failed to fetch tags')
  }
}

export const DetermineTagList = z.array(z.string())

async function determineTags(
  userAttributes: UserAttributesResponse,
  allTags: string[],
): Promise<string[]> {
  // Mastraのサブエージェント（DetermineNewsTagsAgent）を呼び出してタグを決定する
  try {
    const result = await determineNewsTagsAgent.generateVNext(
      [
        {
          role: 'user',
          content: `Analyze user attributes and determine optimal news tags.

					User Attributes: ${JSON.stringify(userAttributes, null, 2)}
					Available System Tags: ${JSON.stringify(allTags, null, 2)}

					Please analyze the user's preferences and return the most relevant tags for news curation.

					Please strictly follow the JSON Schema below and return **JSON only**. No explanatory text before or after.
					Schema:
						- ["tag1", "tag2", ...]
            - [] if no relevant tags can be determined.`,
        },
      ],
      {
        format: 'aisdk',
      },
    )

    console.log(`✅ determineTags: Result - ${result.text}`)

    return JSON.parse(result.text) as string[]
  } catch (error) {
    console.error('Error in determineTags:', error)
    return []
  }
}

async function fetchNewsByTags(tags: string[]) {
  try {
    if (tags.length === 0) {
      return []
    }

    const tagsParam = tags.join(',')
    const data = await apiClient.get(
      `/api/v1/articles?tags=${encodeURIComponent(tagsParam)}`,
    )

    return data.articles.map((article: any) => ({
      id: article.id.toString(),
      title: article.title,
      url: article.source_url || `http://localhost:3000/articles/${article.id}`,
      source: article.author || 'Unknown',
      publishedAt: new Date(article.published_at),
      tags: article.tags.map((tag: any) => tag.name),
    }))
  } catch (error) {
    console.error('Error fetching news by tags:', error)
    throw new Error('Failed to fetch news articles')
  }
}

async function saveNewsFetchHistory(
  userId: number,
  tags: string[],
  news: {
    id: string
    title: string
    url: string
    source: string
    publishedAt: Date
    tags: string[]
  }[],
) {
  try {
    // 記事IDの配列を抽出
    const articleIds = news
      .map((article) => parseInt(article.id, 10))
      .filter((id) => !isNaN(id))

    if (articleIds.length === 0) {
      console.log('No valid article IDs found, skipping history save')
      return
    }

    await apiClient.post('/api/v1/tag_search_histories', {
      tag_search_history: {
        article_ids: articleIds,
      },
    })
  } catch (error) {
    console.error('Error saving news fetch history:', error)
    throw new Error('Failed to save news fetch history')
  }
}

const getInfoForCuration = async (userId: number) => {
  const userAttributes = await fetchUserAttributes(userId)
  const allTags = await fetchAllTags()
  const tags = await determineTags(userAttributes, allTags)
  const news = await fetchNewsByTags(tags)
  await saveNewsFetchHistory(userId, tags, news)
  return {
    userAttributes,
    tags,
    news,
  }
}
