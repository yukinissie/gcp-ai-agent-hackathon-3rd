# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# テストデータ作成

# タグを作成
art_tag = Tag.find_or_create_by!(name: "デジタルアート", category: :art)
tech_tag = Tag.find_or_create_by!(name: "AI", category: :tech)
music_tag = Tag.find_or_create_by!(name: "ジャズ", category: :music)
culture_tag = Tag.find_or_create_by!(name: "現代文化", category: :lifestyle)

puts "タグを作成しました: #{Tag.count}件"

# 記事を作成
article1 = Article.find_or_create_by!(title: "デジタルアートの新しい潮流") do |article|
  article.summary = "デジタル技術の進歩により、アートの表現方法も大きく変化しています。NFTアートから没入型体験まで、最新のトレンドを解説します。"
  article.content = "# デジタルアートの革命\n\n現代のアート界では、技術革新が新たな表現の可能性を切り開いています。特にNFT（Non-Fungible Token）の登場により、デジタルアート作品の所有権や流通方法が根本的に変わりました。\n\n## VRとARの活用\n\n仮想現実（VR）や拡張現実（AR）技術を使った没入型アート体験が増えています。観客は作品の中に入り込み、インタラクティブに楽しむことができます。\n\n## AIによるアート創作\n\n人工知能を使った自動生成アートも注目を集めています。AIアーティストが描く作品は、人間の創造力と機械学習の融合として新しい芸術分野を開拓しています。"
  article.content_format = "markdown"
  article.author = "田中美術"
  article.source_url = "https://example.com/digital-art-trends"
  article.image_url = "https://example.com/images/digital_art.jpg"
  article.published = true
  article.published_at = 2.days.ago
end

article2 = Article.find_or_create_by!(title: "AI技術が変える音楽制作") do |article|
  article.summary = "人工知能を活用した音楽制作技術が急速に発展しています。作曲から演奏まで、AIが音楽業界に与える影響を探ります。"
  article.content = "# AI音楽の時代\n\n音楽業界において、AI技術の活用が広がっています。機械学習アルゴリズムを使った自動作曲システムから、リアルタイムでの演奏支援まで、様々な場面でAIが活用されています。\n\n## 作曲支援AI\n\n楽曲のメロディーやハーモニーを自動生成するAIツールが開発されています。これらのツールは、音楽理論に基づいて自然な楽曲を作り出すことができます。\n\n## ジャズとAI\n\n特にジャズの分野では、即興演奏を学習したAIが人間のミュージシャンと共演する実験が行われています。"
  article.content_format = "markdown"
  article.author = "山田音楽研究所"
  article.source_url = "https://example.com/ai-music"
  article.image_url = "https://example.com/images/ai_music.jpg"
  article.published = true
  article.published_at = 1.day.ago
end

article3 = Article.find_or_create_by!(title: "現代文化におけるテクノロジーの役割") do |article|
  article.summary = "デジタル化が進む現代社会において、テクノロジーが文化に与える影響について考察します。"
  article.content = "# テクノロジーと文化の融合\n\n21世紀の文化は、テクノロジーと切り離して考えることはできません。SNSから動画配信サービスまで、私たちの文化的体験はデジタル技術によって大きく変化しています。\n\n## デジタルネイティブ世代\n\nスマートフォンやインターネットと共に育った世代は、従来とは異なる文化的価値観を持っています。\n\n## グローバル化する文化\n\nテクノロジーにより、世界中の文化が瞬時に共有される時代になりました。"
  article.content_format = "markdown"
  article.author = "佐藤文化研究所"
  article.source_url = "https://example.com/tech-culture"
  article.image_url = "https://example.com/images/tech_culture.jpg"
  article.published = true
  article.published_at = 3.days.ago
end

# 未公開記事も作成
article4 = Article.find_or_create_by!(title: "未公開記事：次世代アート展示") do |article|
  article.summary = "まだ公開されていない次世代アート展示についての記事です。"
  article.content = "この記事はまだ公開されていません。"
  article.content_format = "markdown"
  article.author = "未公開著者"
  article.published = false
  article.published_at = nil
end

puts "記事を作成しました: #{Article.count}件"

# タグと記事の関連付け
ArticleTagging.find_or_create_by!(article: article1, tag: art_tag)
ArticleTagging.find_or_create_by!(article: article1, tag: tech_tag)

ArticleTagging.find_or_create_by!(article: article2, tag: tech_tag)
ArticleTagging.find_or_create_by!(article: article2, tag: music_tag)

ArticleTagging.find_or_create_by!(article: article3, tag: culture_tag)
ArticleTagging.find_or_create_by!(article: article3, tag: tech_tag)

puts "タグと記事の関連付けを作成しました: #{ArticleTagging.count}件"

# ユーザー作成（既存のユーザーID=2を確認）
user = User.find_by(id: 2)
if user
  # article_id=1の記事に「いいね」を押す
  Activity.find_or_create_by!(user: user, article: article1, activity_type: :good)
  puts "ユーザーID=2がarticle_id=1に「いいね」を追加しました"
else
  puts "ユーザーID=2が見つかりませんでした"
end

puts "\n=== シードデータ作成完了 ==="
puts "タグ: #{Tag.count}件"
puts "記事: #{Article.count}件（公開: #{Article.published.count}件、未公開: #{Article.where(published: false).count}件）"
puts "関連付け: #{ArticleTagging.count}件"
puts "評価: #{Activity.count}件"
