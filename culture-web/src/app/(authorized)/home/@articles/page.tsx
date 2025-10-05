import { Box, Flex, Heading } from '@radix-ui/themes'
import { ArticleList } from './_components/ArticleList'
import { fetchArticles } from './_drivers/fetchArticles'
import { fetchTagSearchHistoryArticles } from './_drivers/fetchTagSearchHistoryArticles'

export default async function ArticlesPage() {
  const articles = await fetchArticles()
  const tagSearchHistoryArticles = await fetchTagSearchHistoryArticles()
  return (
    <Box>
      <Flex direction="column" gap="6">
        <Flex align="center" justify="between">
          <Heading size="6" weight="bold">
            記事一覧
          </Heading>
        </Flex>

        <Flex direction="column" gap="3" width="100%">
          <ArticleList
            articles={
              tagSearchHistoryArticles.length > 0
                ? tagSearchHistoryArticles
                : articles
            }
          />{' '}
        </Flex>
      </Flex>
    </Box>
  )
}
