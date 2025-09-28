import { Box, Container, Heading, Text, Separator } from '@radix-ui/themes'
import Link from 'next/link'

export default function TermsPage() {
  return (
    <Container size="3" style={{ padding: '2rem' }}>
      <Box mb="6">
        <Link href="/" style={{ textDecoration: 'none', color: 'inherit' }}>
          ← トップページに戻る
        </Link>
      </Box>

      <Box mb="8">
        <Heading size="8" mb="4">
          利用規約
        </Heading>
        <Text size="3" color="gray">
          本規約は、本サービスの利用条件を定めるものです。利用者は、本規約に同意のうえ本サービスをご利用ください。
        </Text>
      </Box>

      <Box mb="6">
        <Heading size="5" mb="3">
          第1条（サービス概要）
        </Heading>
        <Text as="div" size="3" mb="2">
          本サービスは、期間限定で公開される実験的なWebサービスです。
        </Text>
        <Text as="div" size="3">
          本サービスは、個人（提供者：カルチャーズ）が検証目的で提供するものであり、本番利用や業務利用を想定したものではありません。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第2条（提供期間）
        </Heading>
        <Text as="div" size="3" mb="2">
          提供開始日：2025年9月24日
        </Text>
        <Text as="div" size="3" mb="2">
          提供終了日：2025年10月31日
        </Text>
        <Text as="div" size="3">
          提供終了日以降、本サービスは利用できません。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第3条（認証・認可）
        </Heading>
        <Text as="div" size="3" mb="2">
          本サービスは、独自の認証システムを利用します。
        </Text>
        <Text as="div" size="3" mb="2">
          取得する情報は、認証に必要な最低限の範囲（メールアドレス、パスワード）に限ります。
        </Text>
        <Text as="div" size="3">
          利用者は、本サービス内でアカウント削除を行うことで、いつでも利用を停止することができます。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第4条（禁止事項）
        </Heading>
        <Text as="div" size="3" mb="3">
          利用者は、以下の行為をしてはなりません。
        </Text>
        <Box ml="4">
          <Text as="div" size="3" mb="2">
            • 法令または公序良俗に違反する行為
          </Text>
          <Text as="div" size="3" mb="2">
            • 不正アクセスや過度な負荷を与える行為
          </Text>
          <Text as="div" size="3">
            • 本サービスの運営を妨害する行為
          </Text>
        </Box>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第5条（サービス停止・終了）
        </Heading>
        <Text as="div" size="3" mb="2">
          提供者は、予告なくサービスを停止・終了することがあります。
        </Text>
        <Text as="div" size="3">
          利用者が規約に違反した場合、提供者は利用を制限することができます。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第6条（免責事項）
        </Heading>
        <Text as="div" size="3" mb="2">
          提供者は、本サービスの利用によって生じた損害について責任を負いません。
        </Text>
        <Text as="div" size="3">
          提供者は、サービス停止・終了・不具合に伴うデータ損失について責任を負いません。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="8">
        <Heading size="5" mb="3">
          第7条（規約の変更）
        </Heading>
        <Text as="div" size="3">
          提供者は、必要に応じて本規約を変更することがあります。
        </Text>
      </Box>

      <Box style={{ textAlign: 'center', color: 'gray' }} mb="4">
        <Text size="2">提供者：にっしー（個人）</Text>
      </Box>

      <Box
        style={{
          padding: '1rem',
          backgroundColor: 'var(--gray-2)',
          borderRadius: '8px',
          border: '1px solid var(--gray-6)',
          textAlign: 'center',
        }}
      >
        <Text size="2" weight="medium">
          制定日：2025年9月23日
        </Text>
      </Box>
    </Container>
  )
}
