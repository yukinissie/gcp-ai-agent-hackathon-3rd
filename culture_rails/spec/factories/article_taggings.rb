# == Schema Information
#
# Table name: article_taggings
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  article_id :bigint           not null
#  tag_id     :bigint           not null
#
# Indexes
#
#  index_article_taggings_on_article_id             (article_id)
#  index_article_taggings_on_article_id_and_tag_id  (article_id,tag_id) UNIQUE
#  index_article_taggings_on_tag_id                 (tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (tag_id => tags.id)
#
FactoryBot.define do
  factory :article_tagging do
    association :article
    association :tag
  end
end
