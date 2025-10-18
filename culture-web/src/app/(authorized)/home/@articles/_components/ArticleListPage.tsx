import { GeneralError } from '@/app/_components/error/GeneralError'
import { UnauthorizedError } from '@/app/_components/error/UnauthorizedError'
import { Box, Flex, Heading } from '@radix-ui/themes'
import {
  fetchArticles,
  FetchArticlesResultType,
} from '../_drivers/fetchArticles'
import {
  fetchTagSearchHistoryArticles,
  FetchTagSearchHistoryArticlesResultType,
} from '../_drivers/fetchTagSearchHistoryArticles'
import { ArticleList } from './ArticleList'

export async function ArticleListPage() {
  const articlesResult = await fetchArticles()
  switch (articlesResult.type) {
    case FetchArticlesResultType.Unauthorized:
      return <UnauthorizedError error={articlesResult.error} />
    case FetchArticlesResultType.Error:
      return <GeneralError error={articlesResult.error} />
  }

  const tagSearchHistoryResult = await fetchTagSearchHistoryArticles()
  switch (tagSearchHistoryResult.type) {
    case FetchTagSearchHistoryArticlesResultType.Unauthorized:
      return <UnauthorizedError error={tagSearchHistoryResult.error} />
    case FetchTagSearchHistoryArticlesResultType.Error:
      return <GeneralError error={tagSearchHistoryResult.error} />
  }

  const articles =
    tagSearchHistoryResult.articles.length > 0
      ? tagSearchHistoryResult.articles
      : articlesResult.articles

  return (
    <Box>
      <Flex direction="column" gap="6">
        <Flex align="center" justify="between">
          <Heading size="6" weight="bold">
            記事一覧
          </Heading>
        </Flex>

        <Flex direction="column" gap="3" width="100%">
          <ArticleList articles={articles} />
        </Flex>
      </Flex>
    </Box>
  )
}
