'use client';

import { Container, Box, Heading, Text, Badge, Flex, Button } from '@radix-ui/themes';
import Link from 'next/link';
import { marked } from 'marked';
import { ArticleDetail } from '../../home/_actions/articles';

interface ArticleDetailClientProps {
  article: ArticleDetail;
}

export function ArticleDetailClient({ article }: ArticleDetailClientProps) {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('ja-JP', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
  };

  const renderContent = (content: string) => {
    if (article.content_format === 'markdown') {
      try {
        return marked.parse(content, {
          breaks: true, 
          gfm: true,
        });
      } catch (error) {
        console.error('Markdown parsing error:', error);
        return content;
      }
    }
    return content.replace(/\n/g, '<br>');
  };

  return (
    <Container size="4">
      <Box py="6">
        {/* 戻るボタン */}
        <Box mb="6">
          <Link href="/home">
            <Button variant="ghost" size="2">
              ← 記事一覧に戻る
            </Button>
          </Link>
        </Box>

        {/* 記事ヘッダー */}
        <Box mb="6">
          {article.image_url && (
            <Box mb="4">
              <img
                src={article.image_url}
                alt={article.title}
                style={{
                  width: '100%',
                  height: '300px',
                  objectFit: 'cover',
                  borderRadius: '8px',
                }}
              />
            </Box>
          )}

          <Heading size="8" mb="4">
            {article.title}
          </Heading>

          <Text size="4" color="gray" mb="4" style={{ lineHeight: '1.6' }}>
            {article.summary}
          </Text>

          <Flex align="center" gap="4" mb="4" wrap="wrap">
            <Text size="2" weight="medium">
              {article.author}
            </Text>
            <Text size="2" color="gray">
              {formatDate(article.published_at)}
            </Text>
          </Flex>

          <Flex gap="2" wrap="wrap">
            {article.tags.map((tag) => (
              <Badge key={tag.id} color="blue" variant="soft">
                {tag.name}
              </Badge>
            ))}
          </Flex>
        </Box>

        {/* 記事本文 */}
        <Box>
          <div
            dangerouslySetInnerHTML={{
              __html: renderContent(article.content),
            }}
            style={{
              lineHeight: '1.8',
              fontSize: '16px',
            }}
          />
        </Box>

        {/* ソースリンク */}
        {article.source_url && (
          <Box mt="8" p="4" style={{ backgroundColor: 'var(--gray-2)', borderRadius: '8px' }}>
            <Text size="2" color="gray" mb="2">
              参考記事:
            </Text>
            <Link href={article.source_url} target="_blank" rel="noopener noreferrer">
              <Text size="2" style={{ color: 'var(--accent-9)' }}>
                {article.source_url}
              </Text>
            </Link>
          </Box>
        )}
      </Box>
    </Container>
  );
}
