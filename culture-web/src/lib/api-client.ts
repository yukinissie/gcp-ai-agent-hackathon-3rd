import { auth } from "@/auth";

const API_BASE_URL = process.env.RAILS_API_URL || 'http://localhost:3000';

export const apiClient = {
  async get(endpoint: string, options: RequestInit = {}) {
    const headers = await this.getHeaders(options.headers);
    
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      method: 'GET',
      headers,
      ...options,
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`);
    }

    return response.json();
  },

  async post(endpoint: string, data: unknown, options: RequestInit = {}) {
    const headers = await this.getHeaders(options.headers);
    
    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      method: 'POST',
      headers,
      body: JSON.stringify(data),
      ...options,
    });

    if (!response.ok) {
      throw new Error(`API Error: ${response.status} ${response.statusText}`);
    }

    return response.json();
  },

  // 認証ヘッダーを自動で追加するヘルパーメソッド
  async getHeaders(additionalHeaders?: HeadersInit): Promise<Record<string, string>> {
    const baseHeaders: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    // 認証トークンを取得して追加
    try {
      const session = await auth();
      if (session?.user?.jwtToken) {
        baseHeaders['Authorization'] = `Bearer ${session.user.jwtToken}`;
      }
    } catch (error) {
      console.warn('Failed to get auth session:', error);
    }

    // 追加ヘッダーをマージ
    if (additionalHeaders) {
      const additionalHeadersObj = additionalHeaders instanceof Headers 
        ? Object.fromEntries(additionalHeaders.entries())
        : Array.isArray(additionalHeaders)
        ? Object.fromEntries(additionalHeaders)
        : additionalHeaders;

      Object.assign(baseHeaders, additionalHeadersObj);
    }

    return baseHeaders;
  },
};