import { Text, Flex } from '@radix-ui/themes'
import { ArticleCard } from './ArticleCard'
import type { Article } from '../../types'

interface ArticleListProps {
  articles: Article[]
}

export function ArticleList(props: ArticleListProps) {
  if (props.articles.length === 0) {
    return (
      <Flex
        direction="column"
        align="center"
        justify="center"
        style={{
          minHeight: '400px',
        }}
        gap="3"
      >
        <Text size="4" weight="medium">
          記事が見つかりません
        </Text>
        <Text size="3" color="gray">
          まだ記事が投稿されていないか、条件に合う記事がありません。
        </Text>
      </Flex>
    )
  }

  return props.articles.map((article) => (
    <ArticleCard key={article.id} article={article} />
  ))
}
