import { Card, Text, Heading, Badge, Flex, Box } from '@radix-ui/themes';
import { ArticleCardProps } from './types';
import { articleCardStyles } from '../_styles/articleCard.styles';

export function ArticleCard({ article, onClick }: ArticleCardProps) {
  const handleClick = () => {
    onClick?.(article);
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  return (
    <Card
      variant="surface"
      style={onClick ? articleCardStyles.card : articleCardStyles.cardDefault}
      onMouseEnter={(e) => {
        if (onClick) {
          Object.assign(e.currentTarget.style, articleCardStyles.cardHover);
        }
      }}
      onMouseLeave={(e) => {
        if (onClick) {
          Object.assign(e.currentTarget.style, articleCardStyles.cardLeave);
        }
      }}
      onClick={handleClick}
    >
      <Flex gap="4" align="start">
        {/* 画像部分 */}
        {article.image_url && (
          <Box style={articleCardStyles.imageContainer}>
            <img
              src={article.image_url}
              alt={article.title}
              style={articleCardStyles.image}
            />
          </Box>
        )}
        
        {/* コンテンツ部分 */}
        <Flex direction="column" gap="2" style={articleCardStyles.contentContainer}>
          <Flex align="center" gap="2" wrap="wrap">
            {article.tags.length > 0 && (
              <Badge color="blue" variant="soft">
                {article.tags[0].name}
              </Badge>
            )}
            <Text size="2" color="gray">
              {formatDate(article.published_at)}
            </Text>
          </Flex>
          
          <Heading size="4" weight="bold" style={articleCardStyles.headingText}>
            {article.title}
          </Heading>
          
          <Text 
            size="2" 
            color="gray" 
            style={articleCardStyles.excerptText}
          >
            {article.summary}
          </Text>
          
          <Flex justify="between" align="end" mt="auto">
            <Flex gap="1" wrap="wrap">
              {article.tags.slice(0, 2).map((tag) => (
                <Badge key={tag.id} color="gray" variant="soft" size="1">
                  {tag.name}
                </Badge>
              ))}
              {article.additional_tags_count > 0 && (
                <Badge color="gray" variant="soft" size="1">
                  +{article.additional_tags_count}
                </Badge>
              )}
            </Flex>
            
            <Text size="2" weight="medium" color="gray" style={articleCardStyles.authorText}>
              {article.author}
            </Text>
          </Flex>
        </Flex>
      </Flex>
    </Card>
  );
}
