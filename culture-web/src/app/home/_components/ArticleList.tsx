import { Heading, Text, Flex, Spinner, Box } from '@radix-ui/themes';
import { ArticleCard } from './ArticleCard';
import { ArticleListProps, Article } from './types';

export function ArticleList({ articles, loading = false }: ArticleListProps) {
  const handleArticleClick = (article: Article) => {
    console.log('記事がクリックされました:');
  };

  if (loading) {
    return (
      <Flex 
        direction="column" 
        align="center" 
        justify="center" 
        style={{ minHeight: '400px' }}
        gap="4"
      >
        <Spinner size="3" />
        <Text size="3" color="gray">
          記事を読み込んでいます...
        </Text>
      </Flex>
    );
  }

  if (articles.length === 0) {
    return (
      <Flex 
        direction="column" 
        align="center" 
        justify="center" 
        style={{ minHeight: '400px' }}
        gap="3"
      >
        <Text size="4" weight="medium">
          記事が見つかりません
        </Text>
        <Text size="3" color="gray">
          まだ記事が投稿されていないか、条件に合う記事がありません。
        </Text>
      </Flex>
    );
  }

  return (
    <Box>
      <Flex direction="column" gap="6">
        <Flex align="center" justify="between">
          <Heading size="6" weight="bold">
            記事一覧
          </Heading>
        </Flex>
        
        <Flex 
          direction="column"
          gap="3"
          width="100%"
        >
          {articles.map((article) => (
            <ArticleCard
              key={article.id}
              article={article}
              onClick={handleArticleClick}
            />
          ))}
        </Flex>
      </Flex>
    </Box>
  );
}
