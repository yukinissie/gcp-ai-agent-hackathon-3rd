"use server";

import { revalidatePath } from "next/cache";
import { auth } from "@/auth";

export interface ArticleRatingResponse {
  current_evaluation:
    | "good"
    | "bad"
    | "none";
  article: {
    id: number;
    title: string;
    good_count: number;
    bad_count: number;
  };
}

export async function rateArticle(
  articleId: number,
  activityType:
    | "good"
    | "bad",
): Promise<ArticleRatingResponse | null> {
  try {
    const session =
      await auth();

    if (
      !session
        ?.user
        ?.id
    ) {
      console.error(
        "[Server Action] 認証が必要です",
      );
      return null;
    }

    console.log(
      "[Server Action] rateArticle called:",
      {
        articleId,
        activityType,
        userId:
          session
            .user
            .id,
      },
    );

    const response =
      await fetch(
        `${process.env.RAILS_API_HOST}/api/v1/articles/${articleId}/activities`,
        {
          method:
            "POST",
          headers:
            {
              "Content-Type":
                "application/json",
              Authorization: `Bearer ${session.user.jwtToken}`,
            },
          body: JSON.stringify(
            {
              activity_type:
                activityType,
            },
          ),
        },
      );

    if (
      !response.ok
    ) {
      throw new Error(
        `API Request failed: ${response.status}`,
      );
    }

    const data =
      await response.json();

    console.log(
      "[Server Action] API response received:",
      data,
    );

    // 記事詳細ページのキャッシュを更新
    revalidatePath(
      `/articles/${articleId}`,
    );

    return data;
  } catch (error) {
    console.error(
      "[Server Action] 記事評価エラー:",
      error,
    );
    return null;
  }
}

export async function rateArticleGood(
  articleId: number,
) {
  return rateArticle(
    articleId,
    "good",
  );
}

export async function rateArticleBad(
  articleId: number,
) {
  return rateArticle(
    articleId,
    "bad",
  );
}
