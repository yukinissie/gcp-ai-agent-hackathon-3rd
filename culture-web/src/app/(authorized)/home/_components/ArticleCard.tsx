'use client'

import { Card, Text, Heading, Badge, Flex, Box } from '@radix-ui/themes'
import { articleCardStyles } from './articleCard.styles'
import { useRouter } from 'next/navigation'
import type { Article } from '../../types'

type ArticleCardProps = {
  article: Article
  onClick?: (article: Article) => void
}

export function ArticleCard(props: ArticleCardProps) {
  const router = useRouter()

  const handleClick = () => {
    if (props.onClick) {
      props.onClick(props.article)
    } else {
      router.push(`/articles/${props.article.id}`)
    }
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    })
  }

  return (
    <Card
      variant="surface"
      style={
        props.onClick ? articleCardStyles.card : articleCardStyles.cardDefault
      }
      onMouseEnter={(e) => {
        if (props.onClick) {
          Object.assign(e.currentTarget.style, articleCardStyles.cardHover)
        }
      }}
      onMouseLeave={(e) => {
        if (props.onClick) {
          Object.assign(e.currentTarget.style, articleCardStyles.cardLeave)
        }
      }}
      onClick={handleClick}
    >
      <Flex gap="4" align="start">
        {/* 画像部分 */}
        {props.article.image_url && (
          <Box style={articleCardStyles.imageContainer}>
            <img
              src={props.article.image_url}
              alt={props.article.title}
              style={articleCardStyles.image}
            />
          </Box>
        )}

        {/* コンテンツ部分 */}
        <Flex
          direction="column"
          gap="2"
          style={articleCardStyles.contentContainer}
        >
          <Flex align="center" gap="2" wrap="wrap">
            {props.article.tags.length > 0 && (
              <Badge color="blue" variant="soft">
                {props.article.tags[0].name}
              </Badge>
            )}
            <Text size="2" color="gray">
              {formatDate(props.article.published_at)}
            </Text>
          </Flex>

          <Heading size="4" weight="bold" style={articleCardStyles.headingText}>
            {props.article.title}
          </Heading>

          <Text size="2" color="gray" style={articleCardStyles.excerptText}>
            {props.article.summary}
          </Text>

          <Flex justify="between" align="end" mt="auto">
            <Flex gap="1" wrap="wrap">
              {props.article.tags.slice(0, 2).map((tag) => (
                <Badge key={tag.id} color="gray" variant="soft" size="1">
                  {tag.name}
                </Badge>
              ))}
              {props.article.tags.length > 2 && (
                <Badge color="gray" variant="soft" size="1">
                  +{props.article.tags.length - 2}
                </Badge>
              )}
            </Flex>

            <Text
              size="2"
              weight="medium"
              color="gray"
              style={articleCardStyles.authorText}
            >
              {props.article.author}
            </Text>
          </Flex>
        </Flex>
      </Flex>
    </Card>
  )
}
