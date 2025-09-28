import {
  Box,
  Card,
  Container,
  Flex,
  Grid,
  Heading,
  Separator,
  Text,
} from '@radix-ui/themes'
import Image from 'next/image'
import Link from 'next/link'

export default function AboutPage() {
  return (
    <Container size="3" style={{ padding: '2rem' }}>
      <Box mb="6">
        <Link href="/" style={{ textDecoration: 'none', color: 'inherit' }}>
          ← トップページに戻る
        </Link>
      </Box>

      <Box mb="8" style={{ textAlign: 'center' }}>
        <Image
          src="/culture.png"
          alt="Culture"
          width={120}
          height={120}
          style={{ marginBottom: '1rem' }}
        />
        <Heading size="8" mb="4">
          Cultureについて
        </Heading>
        <Text size="4" color="gray">
          AI Agent によるパーソナライズドニュースメディア
        </Text>
      </Box>

      <Box mb="8">
        <Heading size="6" mb="4">
          🌟 Cultureとは
        </Heading>
        <Text as="div" size="3" mb="4">
          Cultureは、AI Agent
          があなたのためのニュースフィードを提供するパーソナライズドニュースメディアです。
          GCP AI Agent
          Hackathonで開発され、高度なAIエージェント技術を活用して、一人ひとりの興味や関心に合わせた文化的なニュースやコンテンツをお届けします。
        </Text>
        <Text as="div" size="3">
          私たちのミッションは、AIの力を借りて文化の多様性を伝え、ユーザーが本当に知りたい情報に出会える環境を提供することです。
        </Text>
      </Box>

      <Separator size="4" mb="8" />

      <Box mb="8">
        <Heading size="6" mb="4">
          ✨ 主な機能
        </Heading>
        <Grid columns="1" gap="4">
          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                🤖 パーソナライズAI
              </Heading>
              <Text size="3">
                高度なAI Agentがあなたの興味や好みを学習し、
                あなただけのニュースフィードを自動生成します。
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                📰 カスタムニュースフィード
              </Heading>
              <Text size="3">
                あなたの関心に基づいて、最新の文化ニュースや記事を AI
                Agentが厳選してパーソナライズドフィードとしてお届けします。
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                🔍 インテリジェント検索
              </Heading>
              <Text size="3">
                AI Agentが搭載されたスマート検索で、過去の閲覧履歴や
                興味関心から関連性の高いニュースを素早く発見できます。
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                💬 AI Agent チャット
              </Heading>
              <Text size="3">
                AI Agentとの自然な対話を通じて、
                ニュースの背景情報や関連トピックを深く理解できます。
              </Text>
            </Box>
          </Card>
        </Grid>
      </Box>

      <Separator size="4" mb="8" />

      <Box mb="8">
        <Heading size="6" mb="4">
          🏗️ 技術スタック
        </Heading>
        <Grid columns={{ initial: '1', md: '2' }} gap="4" mb="4">
          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                フロントエンド
              </Heading>
              <Text as="div" size="3" mb="2">
                • Next.js 15.5 (React 19)
              </Text>
              <Text as="div" size="3" mb="2">
                • TypeScript
              </Text>
              <Text as="div" size="3" mb="2">
                • Radix UI
              </Text>
              <Text as="div" size="3">
                • CSS Modules
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                バックエンド
              </Heading>
              <Text as="div" size="3" mb="2">
                • Ruby on Rails 8.0
              </Text>
              <Text as="div" size="3" mb="2">
                • PostgreSQL
              </Text>
              <Text as="div" size="3" mb="2">
                • AI エージェント統合
              </Text>
              <Text as="div" size="3">
                • RESTful API
              </Text>
            </Box>
          </Card>
        </Grid>

        <Grid columns={{ initial: '1', md: '1' }} gap="4">
          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                ☁️ クラウドインフラ
              </Heading>
              <Flex direction="column" gap="2">
                <Text size="3">• Google Cloud Platform (GCP)</Text>
                <Text size="3">• Cloud Run (サーバーレスデプロイ)</Text>
                <Text size="3">• Terraform (Infrastructure as Code)</Text>
                <Text size="3">• GitHub Actions (CI/CD)</Text>
              </Flex>
            </Box>
          </Card>
        </Grid>
      </Box>

      <Separator size="4" mb="8" />

      <Box mb="8">
        <Heading size="6" mb="4">
          🎯 プロジェクトの背景
        </Heading>
        <Text as="div" size="3" mb="4">
          Cultureは、GCP AI Agent
          Hackathonの一環として開発されたパーソナライズドニュースメディアです。
          Google
          Cloudの最新AI技術を活用して、従来の画一的なニュース配信から脱却し、
          一人ひとりに最適化された情報体験を実現することを目的としています。
        </Text>
        <Text as="div" size="3">
          私たちは、AI Agentの力でニュースメディアの未来を変革し、
          読者が本当に価値を感じる情報との出会いを創造することを目指しています。
        </Text>
      </Box>

      <Box
        style={{
          padding: '2rem',
          backgroundColor: 'var(--gray-2)',
          borderRadius: '12px',
          border: '1px solid var(--gray-6)',
          textAlign: 'center',
        }}
        mb="6"
      >
        <Heading size="5" mb="3">
          🚀 始まりの村へようこそ
        </Heading>
        <Text size="3" mb="4">
          Cultureは「ここは始まりの村だよ！」というメッセージとともに、
          あなたのパーソナライズドニュース体験の出発点となります。
        </Text>
        <Link href="/" style={{ textDecoration: 'none' }}>
          <Text size="3" weight="medium" style={{ color: 'var(--accent-9)' }}>
            今すぐ Cultureを体験する →
          </Text>
        </Link>
      </Box>

      <Box style={{ textAlign: 'center', color: 'gray' }}>
        <Text size="2">
          提供者：カルチャーズ（個人） | GCP AI Agent Hackathon 2025
        </Text>
      </Box>
    </Container>
  )
}
