import {
  Box,
  Card,
  Container,
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
          Cultureは、第3回 AI Agent Hackathon with Google Cloudで開発された、
          AI駆動型ニュースキュレーションプラットフォームです。
          ユーザーの興味や好みに基づいてニュース記事をキュレーションし、
          AIエージェントとの対話を通じて新しいコンテンツを発見できます。
        </Text>
        <Text as="div" size="3">
          私たちのミッションは、GoogleのAI技術を活用して、
          一人ひとりに最適化された情報体験を提供することです。
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
                🤖 AI駆動のニュースキュレーション
              </Heading>
              <Text size="3">
                Googleの生成AI（Gemini 2.0
                Flash）を活用した記事の要約・分類により、
                効率的な情報収集を実現します。
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                📰 パーソナライズされた体験
              </Heading>
              <Text size="3">
                ユーザーの評価履歴（Good/Bad）に基づくコンテンツ推薦で、
                あなたの興味に合った記事を優先的に表示します。
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                🔍 タグベース検索
              </Heading>
              <Text size="3">
                テクノロジー、アート、音楽、スポーツ、ビジネス、科学、ライフスタイルなど、
                カテゴリ別に整理された記事を簡単に探索できます。
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                💬 インタラクティブなチャット
              </Heading>
              <Text size="3">
                AIエージェント（Mastra Framework）との対話を通じて、
                興味のあるトピックを深く探索し、新しい発見につなげます。
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
                • Next.js 15.5 + React 19
              </Text>
              <Text as="div" size="3" mb="2">
                • TypeScript + Radix UI
              </Text>
              <Text as="div" size="3" mb="2">
                • App Router (Parallel Routes)
              </Text>
              <Text as="div" size="3">
                • NextAuth v5 (Auth.js)
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                AI/LLM
              </Heading>
              <Text as="div" size="3" mb="2">
                • Mastra Framework
              </Text>
              <Text as="div" size="3" mb="2">
                • Google Gemini 2.0 Flash
              </Text>
              <Text as="div" size="3" mb="2">
                • ニュースキュレーションエージェント
              </Text>
              <Text as="div" size="3">
                • タグ判定エージェント
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                バックエンド
              </Heading>
              <Text as="div" size="3" mb="2">
                • Ruby on Rails 8.0 API
              </Text>
              <Text as="div" size="3" mb="2">
                • PostgreSQL 15+
              </Text>
              <Text as="div" size="3" mb="2">
                • JWT認証 + RESTful API
              </Text>
              <Text as="div" size="3">
                • OpenAPI仕様書対応
              </Text>
            </Box>
          </Card>

          <Card>
            <Box p="4">
              <Heading size="4" mb="3">
                インフラ
              </Heading>
              <Text as="div" size="3" mb="2">
                • Google Cloud Run
              </Text>
              <Text as="div" size="3" mb="2">
                • Artifact Registry
              </Text>
              <Text as="div" size="3" mb="2">
                • Terraform (IaC)
              </Text>
              <Text as="div" size="3">
                • GitHub Actions (CI/CD)
              </Text>
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
          Cultureは、第3回 AI Agent Hackathon with Google Cloudで開発された、
          フルスタックWebアプリケーションです。 Google
          Cloudの最新AI技術を活用して、従来の画一的なニュース配信から脱却し、
          一人ひとりに最適化されたパーソナライズドニュース体験を実現します。
        </Text>
        <Text as="div" size="3">
          モダンなフロントエンド、強力なAIエージェント、堅牢なバックエンド、
          そしてスケーラブルなクラウドインフラを組み合わせた、
          エンタープライズグレードのアーキテクチャを採用しています。
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
          🚀 今すぐ始める
        </Heading>
        <Text size="3" mb="4">
          AIエージェントとの対話を通じて、あなただけのニュース体験を始めましょう。
          アカウントを作成して、パーソナライズされたコンテンツ推薦をお楽しみください。
        </Text>
        <Link href="/" style={{ textDecoration: 'none' }}>
          <Text size="3" weight="medium" style={{ color: 'var(--accent-9)' }}>
            Cultureを体験する →
          </Text>
        </Link>
      </Box>

      <Box style={{ textAlign: 'center', color: 'gray' }}>
        <Text size="2">
          開発チーム：カルチャーズ | 第3回 AI Agent Hackathon with Google Cloud
        </Text>
      </Box>
    </Container>
  )
}
