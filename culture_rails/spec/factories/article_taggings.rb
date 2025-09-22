FactoryBot.define do
  factory :article_tagging do
    association :article
    association :tag
  end
end
