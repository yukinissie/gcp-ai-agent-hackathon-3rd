# タスク完了時のチェックリスト

## 完了時に実行すべきコマンド

### フロントエンド（culture-web）

```bash
cd culture-web
npm run lint         # Biome linting
npm run format       # Biome formatting
npm run build        # ビルド確認
```

### バックエンド（culture_rails）

```bash
dip rubocop          # RuboCop linting
dip brakeman         # セキュリティスキャン
dip rspec            # テスト実行
```

## 品質チェック項目

### コード品質

- [ ] RuboCop Rails Omakase に準拠
- [ ] Biome フォーマットが適用済み
- [ ] セキュリティスキャン（Brakeman）でエラーなし
- [ ] 全テストが通過

### テスト要件

- [ ] RSpec + FactoryBot で unit/integration tests
- [ ] Capybara で system tests
- [ ] Committee Rails で OpenAPI 準拠確認
- [ ] API Validation で OpenAPI compliance

### 設定確認

- [ ] TypeScript strict typing エラーなし
- [ ] Next.js standalone output ビルド成功
- [ ] Rails OpenAPI schema 検証通過
- [ ] Docker Compose で正常起動

## デプロイ前確認

- [ ] GitHub Actions CI/CD パイプライン成功
- [ ] Cloud Run デプロイメント確認
- [ ] Infrastructure Terraform 適用確認

## コミット前チェック

- [ ] 日本語コミットメッセージ
- [ ] 機密情報（secrets/keys）含まれていない
- [ ] 不要なファイル除外済み
- [ ] 適切な git ignore ルール適用
