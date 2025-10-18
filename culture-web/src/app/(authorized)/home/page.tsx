import { Flex } from '@radix-ui/themes'
import { homeStyles } from './_styles/page.styles'
import { ChatProvider } from './_contexts/ChatContext'
import { GeneralError } from '@/app/_components/error/GeneralError'
import { UnauthorizedError } from '@/app/_components/error/UnauthorizedError'
import {
  fetchArticles,
  FetchArticlesResultType,
} from './_drivers/fetchArticles'
import {
  fetchTagSearchHistoryArticles,
  FetchTagSearchHistoryArticlesResultType,
} from './_drivers/fetchTagSearchHistoryArticles'
import { auth } from '@/auth'
import { ChatSideBarWrapper } from './_components/ChatSideBarWrapper'
import { MainContent } from './_components/MainContent'

export default async function Page() {
  const session = await auth()

  if (!session || !session.user || !session.user.id) {
    return <UnauthorizedError error="ユーザー情報を取得できませんでした。" />
  }

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
    <ChatProvider>
      <Flex style={homeStyles.mainContainer}>
        <MainContent articles={articles} />
        <ChatSideBarWrapper userId={session.user.id} />
      </Flex>
    </ChatProvider>
  )
}
