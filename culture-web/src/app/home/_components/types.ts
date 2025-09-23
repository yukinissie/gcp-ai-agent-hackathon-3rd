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
    additional_tags_count: number;
}

export interface ArticleCardProps {
    article: Article;
    onClick?: (article: Article) => void;
}
