import { createTool } from '@mastra/core/tools'
import { z } from 'zod'

export const determineTagsTool = createTool({
  id: 'determine-tags',
  description:
    'Determine optimal news tags based on user attributes and available system tags',
  inputSchema: z.object({
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
    allTags: z.array(z.string()),
  }),
  outputSchema: z.object({
    optimizedTags: z.array(
      z.object({
        tag: z.string(),
        relevanceScore: z.number(),
        category: z.enum(['primary', 'discovery', 'trending']),
        rationale: z.string(),
      }),
    ),
    tagCombinations: z.array(z.string()),
  }),
  execute: async ({ context }) => {
    const { userAttributes, allTags } = context

    // 関連度スコアを計算
    const tagAnalysis = allTags.map((tag) => {
      const userPref = userAttributes.tagPreferences.find(
        (pref) => pref.tag === tag,
      )

      if (userPref) {
        // 既存の嗜好タグ（プライマリ）
        return {
          tag,
          relevanceScore: userPref.score / 1000, // 0-1の範囲に正規化
          category: 'primary' as const,
          rationale: `High engagement history: ${userPref.interactions} interactions with score ${userPref.score}`,
        }
      } else {
        // 発見タグ（関連性を推定）
        const diversityBonus = userAttributes.userProfile.diversityScore * 0.3
        const baseScore = 0.2 + diversityBonus

        return {
          tag,
          relevanceScore: baseScore,
          category: 'discovery' as const,
          rationale: `Discovery tag for content diversity (diversity score: ${userAttributes.userProfile.diversityScore})`,
        }
      }
    })

    // 関連度スコアでソート
    const sortedTags = tagAnalysis.sort(
      (a, b) => b.relevanceScore - a.relevanceScore,
    )

    console.log('タグ分析結果:', sortedTags)

    // 上位タグを選択（プライマリ80%、ディスカバリー20%）
    const primaryTags = sortedTags
      .filter((t) => t.category === 'primary')
      .slice(0, 4)
    const discoveryTags = sortedTags
      .filter((t) => t.category === 'discovery')
      .slice(0, 2)

    const optimizedTags = [...primaryTags, ...discoveryTags]
    const tagCombinations = optimizedTags.map((t) => t.tag)

    return {
      optimizedTags,
      tagCombinations,
    }
  },
})
