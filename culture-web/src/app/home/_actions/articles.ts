'use server';

import { Article } from '../_components/types';

export async function fetchArticles(): Promise<Article[]> {
    try {
        const baseUrl = process.env.NEXT_PUBLIC_API_BASE_URL;
        const response = await fetch(`${baseUrl}/api/v1/articles`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
            },
            next: { revalidate: 60 },
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        if (data.articles && Array.isArray(data.articles)) {
            return data.articles;
        }

        return [];
    } catch (error) {
        console.error('記事の取得に失敗しました:', error);
        return [];
    }
}
