import { Box, Flex, Heading } from '@radix-ui/themes'

import { ArticleList } from './_components/ArticleList'
import {
  fetchArticles,
  FetchArticlesResultType,
} from './_drivers/fetchArticles'
import { fetchTagSearchHistoryArticles } from './_drivers/fetchTagSearchHistoryArticles'
import { GeneralError } from '@/components/error/GeneralError'
import { UnauthorizedError } from '@/components/error/UnauthorizedError'

export default async function ArticlesPage() {
  const result = await fetchArticles()

  if (result.type === FetchArticlesResultType.Unauthorized) {
    return <UnauthorizedError error={result.error} />
  }

  if (result.type === FetchArticlesResultType.Error) {
    return <GeneralError error={result.error} />
  }

  const articles = result.articles

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
          />
        </Flex>
      </Flex>
    </Box>
  )
}
