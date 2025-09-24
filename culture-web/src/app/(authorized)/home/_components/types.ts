export interface Tag {
    id: number;
    name: string;
    category: string;
}

export interface Article {
    id: number;
    title: string;
    summary: string;
    author: string;
    published_at: string;
    image_url?: string;
    tags: Tag[];
}

export interface ArticleCardProps {
    article: Article;
    onClick?: (article: Article) => void;
}
