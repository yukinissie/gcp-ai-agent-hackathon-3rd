# == Schema Information
#
# Table name: articles
#
#  id                                         :bigint           not null, primary key
#  author                                     :string           not null
#  content                                    :text             not null
#  content_format                             :string           default("markdown"), not null
#  image_url                                  :string
#  published                                  :boolean          default(FALSE), not null
#  published_at                               :datetime
#  source_type(記事の作成元)                  :string           default("manual"), not null
#  source_url                                 :string
#  summary                                    :text             not null
#  title                                      :string           not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  feed_id(RSS由来の記事の場合のフィード参照) :bigint
#
# Indexes
#
#  index_articles_on_content_format               (content_format)
#  index_articles_on_feed_and_source_url_for_rss  (feed_id,source_url) UNIQUE WHERE (((source_type)::text = 'rss'::text) AND (source_url IS NOT NULL))
#  index_articles_on_feed_id                      (feed_id)
#  index_articles_on_feed_id_and_created_at       (feed_id,created_at)
#  index_articles_on_published                    (published)
#  index_articles_on_published_and_published_at   (published,published_at)
#  index_articles_on_published_at                 (published_at)
#  index_articles_on_source_type                  (source_type)
#
# Foreign Keys
#
#  fk_rails_...  (feed_id => feeds.id)
#
FactoryBot.define do
  factory :article do
    title { "現代アートの新しい潮流：デジタルアートの可能性" }
    summary { "デジタル技術の進歩により、アートの表現方法も大きく変化しています。NFTアートから没入型体験まで、最新のトレンドを解説します。" }
    content { "# デジタルアートの革命\n\n現代のアート界では、技術革新が新たな表現の可能性を切り開いています..." }
    content_format { "markdown" }
    author { "田中美術" }
    source_url { "https://example.com/digital-art-trends" }
    image_url { "https://example.com/images/digital_art.jpg" }
    published { false }
    published_at { nil }

    trait :published do
      published { true }
      published_at { 1.day.ago }
    end

    trait :with_tags do
      after(:create) do |article|
        create(:tag, :art, name: "デジタルアート")
        create(:tag, :art, name: "NFT")
        create(:article_tagging, article: article, tag: Tag.find_by(name: "デジタルアート"))
        create(:article_tagging, article: article, tag: Tag.find_by(name: "NFT"))
      end
    end
  end
end
