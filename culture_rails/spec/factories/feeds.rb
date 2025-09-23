FactoryBot.define do
  factory :feed do
    sequence(:title) { |n| "フィード#{n}" }
    sequence(:endpoint) { |n| "https://example.com/rss#{n}.xml" }
    status { "active" }
    last_fetched_at { nil }
    last_error { nil }

    trait :with_error do
      status { "error" }
      last_error { "Failed to fetch RSS feed" }
    end

    trait :inactive do
      status { "inactive" }
    end

    trait :recently_fetched do
      last_fetched_at { 1.hour.ago }
    end

    trait :with_articles do
      after(:create) do |feed|
        create_list(:article, 3, :rss, feed: feed)
      end
    end
  end
end
