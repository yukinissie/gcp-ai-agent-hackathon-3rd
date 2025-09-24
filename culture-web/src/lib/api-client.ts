import { auth } from "@/auth";

const API_BASE_URL =
  process.env.NEXT_PUBLIC_RAILS_API_HOST || "http://localhost:3000"; // Rails は 3000 ポートで動作中

interface ApiRequestOptions extends RequestInit {
  requireAuth?: boolean;
}

/**
 * 認証情報を自動で追加するAPI クライアント
 */
export async function apiRequest(
  endpoint: string,
  options: ApiRequestOptions = {},
): Promise<Response> {
  const { requireAuth = true, headers = {}, ...restOptions } = options;

  // 基本ヘッダーを設定
  const requestHeaders: HeadersInit = {
    "Content-Type": "application/json",
    Accept: "application/json",
    ...headers,
  };

  // 認証が必要な場合の確認とJWTトークン追加
  if (requireAuth) {
    const session = await auth();

    if (!session?.user?.id) {
      throw new Error("認証が必要です");
    }

    console.log("API Client - Authenticated user:", session.user.id);
    console.log(
      "API Client - Session accessToken:",
      session.accessToken ? "available" : "not available",
    );

    // Server ActionでJWTトークンが利用可能な場合は使用
    if (session.accessToken) {
      requestHeaders.Authorization = `Bearer ${session.accessToken}`;
      console.log("API Client - Using JWT Authorization header");
    } else {
      console.log("API Client - No JWT token available, relying on cookie authentication");
    }
  }

  const fullUrl = `${API_BASE_URL}${endpoint}`;
  console.log("[API Client] Making request to:", fullUrl);
  console.log("[API Client] API_BASE_URL:", API_BASE_URL);
  console.log("[API Client] endpoint:", endpoint);
  console.log("[API Client] requestHeaders:", requestHeaders);

  const response = await fetch(fullUrl, {
    ...restOptions,
    headers: requestHeaders,
    credentials: "include", // Cookie を送る - メンバーのアドバイス！
  });

  return response;
}

/**
 * JSONレスポンスを期待するAPI リクエスト
 */
export async function apiRequestJson<T = any>(
  endpoint: string,
  options: ApiRequestOptions = {},
): Promise<T> {
  const response = await apiRequest(endpoint, options);

  if (!response.ok) {
    const errorMessage = await response.text();
    throw new Error(`API Request failed: ${response.status} - ${errorMessage}`);
  }

  return response.json();
}

/**
 * 記事評価API
 */
export async function rateArticle(
  articleId: number,
  activityType: "good" | "bad",
): Promise<any> {
  return apiRequestJson(`/api/v1/articles/${articleId}/activities`, {
    method: "POST",
    body: JSON.stringify({ activity_type: activityType }),
  });
}

/**
 * 記事詳細取得API（認証不要）
 */
export async function getArticle(articleId: number): Promise<any> {
  return apiRequestJson(`/api/v1/articles/${articleId}`, {
    requireAuth: false,
  });
}

/**
 * 記事一覧取得API（認証不要）
 */
export async function getArticles(params?: {
  q?: string;
  tags?: string;
}): Promise<any> {
  const searchParams = new URLSearchParams();
  if (params?.q) searchParams.set("q", params.q);
  if (params?.tags) searchParams.set("tags", params.tags);

  const endpoint = `/api/v1/articles${searchParams.toString() ? `?${searchParams.toString()}` : ""}`;

  return apiRequestJson(endpoint, {
    requireAuth: false,
  });
}
