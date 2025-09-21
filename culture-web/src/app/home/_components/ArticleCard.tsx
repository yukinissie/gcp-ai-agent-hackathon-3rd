import { Card, Text, Heading, Badge, Flex, Box } from '@radix-ui/themes';
import { ArticleCardProps } from './types';

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
      style={{ 
        cursor: onClick ? 'pointer' : 'default',
        transition: 'transform 0.2s, box-shadow 0.2s',
      }}
      onMouseEnter={(e) => {
        if (onClick) {
          e.currentTarget.style.transform = 'translateY(-2px)';
          e.currentTarget.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.15)';
        }
      }}
      onMouseLeave={(e) => {
        if (onClick) {
          e.currentTarget.style.transform = 'translateY(0)';
          e.currentTarget.style.boxShadow = '';
        }
      }}
      onClick={handleClick}
    >
      <Flex gap="4" align="start">
        {/* 画像部分 */}
        {article.imageUrl && (
          <Box 
            style={{ 
              borderRadius: '8px', 
              overflow: 'hidden',
              flexShrink: 0,
              width: '200px',
              height: '120px'
            }}
          >
            <img
              src={article.imageUrl}
              alt={article.title}
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'cover',
              }}
            />
          </Box>
        )}
        
        {/* コンテンツ部分 */}
        <Flex direction="column" gap="2" style={{ flex: 1, minWidth: 0 }}>
          <Flex align="center" gap="2" wrap="wrap">
            <Badge color="blue" variant="soft">
              {article.category}
            </Badge>
            <Text size="2" color="gray">
              {formatDate(article.publishedAt)}
            </Text>
          </Flex>
          
          <Heading size="4" weight="bold" style={{ lineHeight: '1.4' }}>
            {article.title}
          </Heading>
          
          <Text 
            size="2" 
            color="gray" 
            style={{ 
              lineHeight: '1.6',
              display: '-webkit-box',
              WebkitLineClamp: 2,
              WebkitBoxOrient: 'vertical',
              overflow: 'hidden'
            }}
          >
            {article.excerpt}
          </Text>
          
          <Flex justify="between" align="end" mt="auto">
            <Flex gap="1" wrap="wrap">
              {article.tags.slice(0, 2).map((tag) => (
                <Badge key={tag} color="gray" variant="soft" size="1">
                  {tag}
                </Badge>
              ))}
              {article.tags.length > 2 && (
                <Badge color="gray" variant="soft" size="1">
                  +{article.tags.length - 2}
                </Badge>
              )}
            </Flex>
            
            <Text size="2" weight="medium" color="gray" style={{ flexShrink: 0 }}>
              {article.author}
            </Text>
          </Flex>
        </Flex>
      </Flex>
    </Card>
  );
}
