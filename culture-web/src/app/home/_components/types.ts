export interface Article {
    id: string;
    title: string;
    excerpt: string;
    content: string;
    author: string;
    publishedAt: string;
    updatedAt: string;
    category: string;
    tags: string[];
    imageUrl?: string;
}

export interface ArticleListProps {
    articles: Article[];
    loading?: boolean;
}

export interface ArticleCardProps {
    article: Article;
    onClick?: (article: Article) => void;
}
