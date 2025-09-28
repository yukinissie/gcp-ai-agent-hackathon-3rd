import { Box, Container, Heading, Text, Separator } from '@radix-ui/themes'
import Link from 'next/link'

export default function PrivacyPolicyPage() {
  return (
    <Container size="3" style={{ padding: '2rem' }}>
      <Box mb="6">
        <Link href="/" style={{ textDecoration: 'none', color: 'inherit' }}>
          ← トップページに戻る
        </Link>
      </Box>

      <Box mb="8">
        <Heading size="8" mb="4">
          プライバシーポリシー
        </Heading>
        <Text size="3" color="gray">
          本プライバシーポリシーは、本サービスにおける利用者情報の取扱い方針を定めたものです。
        </Text>
      </Box>

      <Box mb="6">
        <Heading size="5" mb="3">
          第1条（収集する情報）
        </Heading>
        <Text as="div" size="3" mb="3">
          本サービスは、以下の情報を取得する場合があります。
        </Text>
        <Box ml="4">
          <Text as="div" size="3" mb="2">
            • ユーザー登録時に入力されるメールアドレス
          </Text>
          <Text as="div" size="3" mb="2">
            • ログイン認証用のパスワード（暗号化して保存）
          </Text>
          <Text as="div" size="3">
            • ログイン履歴やアクセスログ
          </Text>
        </Box>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第2条（利用目的）
        </Heading>
        <Text as="div" size="3" mb="3">
          収集した情報は、以下の目的でのみ利用されます。
        </Text>
        <Box ml="4">
          <Text as="div" size="3" mb="2">
            • 本サービスの提供・運営
          </Text>
          <Text as="div" size="3">
            • サービス利用状況の把握・改善
          </Text>
        </Box>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第3条（保存と削除）
        </Heading>
        <Text as="div" size="3" mb="2">
          収集したデータはサービス提供期間中のみ保存されます。
        </Text>
        <Text as="div" size="3">
          サービス終了後、一定期間内にデータは削除されます。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第4条（第三者提供）
        </Heading>
        <Text as="div" size="3">
          収集したデータを第三者に提供することはありません。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第5条（利用者の権利）
        </Heading>
        <Text as="div" size="3" mb="2">
          利用者は本サービス内でアカウント削除を行うことで、登録情報を削除することができます。
        </Text>
        <Text as="div" size="3">
          提供者に連絡することで、データ削除を依頼することができます。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="6">
        <Heading size="5" mb="3">
          第6条（免責）
        </Heading>
        <Text as="div" size="3">
          提供者は、不正アクセス等により生じたデータ漏洩について可能な限り対応しますが、完全な防止を保証するものではありません。
        </Text>
      </Box>

      <Separator size="4" mb="6" />

      <Box mb="8">
        <Heading size="5" mb="3">
          第7条（改定）
        </Heading>
        <Text as="div" size="3">
          本ポリシーは、必要に応じて変更されることがあります。
        </Text>
      </Box>

      <Box style={{ textAlign: 'center', color: 'gray' }} mb="4">
        <Text size="2">提供者：カルチャーズ（個人）</Text>
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
