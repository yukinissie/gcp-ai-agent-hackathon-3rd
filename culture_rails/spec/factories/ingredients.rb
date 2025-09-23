FactoryBot.define do
  factory :ingredient do
    association :user

    llm_payload do
      {
        user_profile: {},
        tag_preferences: [],
        activity_patterns: {},
        metadata: {}
      }
    end
    ui_data { {} }
    total_interactions { 0 }
    diversity_score { 0.0 }

    trait :with_data do
      total_interactions { 50 }
      diversity_score { 0.75 }
      llm_payload do
        {
          user_profile: {
            personality_type: "tech_enthusiast",
            total_interactions: 50,
            diversity_score: 0.75,
            evaluation_tendency: "positive"
          },
          tag_preferences: [
            {
              tag: "AI",
              good_count: 15,
              bad_count: 2,
              total_interactions: 17,
              preference_score: 0.88,
              weight: 0.34
            }
          ],
          activity_patterns: {
            good_bad_ratio: 7.5,
            most_active_period: "recent",
            strong_preferences: [ "AI" ],
            strong_dislikes: [],
            recent_interests: [ "machine-learning" ]
          },
          metadata: {
            total_interactions: 50,
            diversity_score: 0.75,
            updated_at: Time.current.iso8601
          }
        }
      end
    end
  end
end
