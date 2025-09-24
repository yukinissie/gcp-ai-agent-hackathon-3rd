FactoryBot.define do
  factory :tag_search_history do
    user
    article_ids { [1, 2, 3] }
    searched_at { Time.current }
  end
end
