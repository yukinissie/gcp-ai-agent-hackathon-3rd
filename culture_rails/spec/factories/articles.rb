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
