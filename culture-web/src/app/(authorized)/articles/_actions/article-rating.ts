"use server";

import { rateArticle as rateArticleApi } from "@/lib/api-client";
import { revalidatePath } from "next/cache";

export interface ArticleRatingResponse {
  current_evaluation: "good" | "bad" | "none";
  article: {
    id: number;
    title: string;
    good_count: number;
    bad_count: number;
  };
}

export async function rateArticle(
  articleId: number,
  activityType: "good" | "bad",
): Promise<ArticleRatingResponse | null> {
  try {
    console.log("[Server Action] rateArticle called:", {
      articleId,
      activityType,
    });

    const data = await rateArticleApi(articleId, activityType);

    console.log("[Server Action] API response received:", data);

    // 記事詳細ページのキャッシュを更新
    revalidatePath(`/articles/${articleId}`);

    return data;
  } catch (error) {
    console.error("[Server Action] 記事評価エラー:", error);
    return null;
  }
}

export async function rateArticleGood(articleId: number) {
  return rateArticle(articleId, "good");
}

export async function rateArticleBad(articleId: number) {
  return rateArticle(articleId, "bad");
}
