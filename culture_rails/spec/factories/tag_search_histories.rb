FactoryBot.define do
  factory :tag_search_history do
    user
    article_ids { [ 1, 2, 3 ] }
  end
end
