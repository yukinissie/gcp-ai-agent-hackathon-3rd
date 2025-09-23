feed = Feed.create!(
  title: 'Qiita人気記事',
  endpoint: 'https://qiita.com/popular-items/feed',
  status: 'active'
)

puts "Created feed: #{feed.title} (ID: #{feed.id})"

# RSS記事を取得
result = feed.fetch_articles
puts "Fetched #{result} articles"

# 記事数確認
puts "Total articles: #{Article.count}"