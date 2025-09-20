# コードスタイルと規約

## Rails（culture_rails）

### コード品質標準

- **RuboCop**: Rails Omakase（opinionated styling）
- **セキュリティ**: Brakeman security scanner
- **テスト**: RSpec + FactoryBot + Capybara

### Rails 開発パターン

- **Solid Stack**: Redis 依存なしの Cache/Queue/Cable
- **API First**: Committee Rails での OpenAPI 検証
- **Hotwire**: 最小 JavaScript で SPA 体験
- **モダンアセット**: Propshaft パイプライン

### 認証システム

- **設計方針**: Profile 中心設計 + 自作認証（bcrypt + JWT）
- **レスポンス**: jb gem（.jb ファイル形式）
- **CSRF**: API 用に無効化済み

### テスト記述ルール（RSpec スタイルガイド準拠）

- `describe`: テスト対象（メソッド名やクラス名）
- `context`: 実行条件や状態
- `it`: 期待する結果
- `let!`: テストで参照するオブジェクト
- `let`: 遅延評価でテストデータ定義
- JSON レスポンス検証は`symbolize_names: true`使用

## フロントエンド（culture-web）

### TypeScript

- **厳密型付け**: Strict typing throughout
- **App Router**: モダン Next.js ルーティングパターン
- **コンポーネント**: CSS Modules でスタイリング
- **パフォーマンス**: Turbopack for development speed

### コード品質

- **Biome**: 統合 TypeScript ツール（linting + formatting）
- **設定**: biome.json で設定管理

## 命名規約

### コミットメッセージ（日本語）

```
feat: 新機能追加
fix: バグ修正
docs: ドキュメント更新
refactor: リファクタリング
test: テスト追加
chore: 雑務・依存関係更新
```

### ファイル命名

- **Rails**: snake_case（users_controller.rb）
- **TypeScript**: camelCase（userProfile.tsx）
- **Component**: PascalCase（UserProfile.tsx）
