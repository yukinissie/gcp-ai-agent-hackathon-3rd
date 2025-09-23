# == Schema Information
#
# Table name: activities
#
#  id            :bigint           not null, primary key
#  activity_type :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  article_id    :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  idx_on_article_id_activity_type_created_at_2a8adb508a  (article_id,activity_type,created_at)
#  index_activities_on_activity_type                      (activity_type)
#  index_activities_on_article_id                         (article_id)
#  index_activities_on_user_article_type_time             (user_id,article_id,activity_type,created_at)
#  index_activities_on_user_id                            (user_id)
#  index_activities_on_user_id_and_article_id             (user_id,article_id) UNIQUE
#  index_activities_on_user_id_and_created_at             (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :activity do
    association :user
    association :article
    activity_type { :good }

    trait :good do
      activity_type { :good }
    end

    trait :bad do
      activity_type { :bad }
    end

    trait :none do
      activity_type { nil }
    end

    factory :good_activity, traits: [ :good ]
    factory :bad_activity, traits: [ :bad ]
    factory :none_activity, traits: [ :none ]
  end
end
