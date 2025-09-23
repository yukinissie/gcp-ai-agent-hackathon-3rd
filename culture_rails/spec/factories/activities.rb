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
