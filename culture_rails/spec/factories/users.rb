# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  human_id   :string           not null
#
# Indexes
#
#  index_users_on_human_id  (human_id) UNIQUE
#
FactoryBot.define do
  factory :user do
    # human_idは自動生成されるので指定不要

    trait :with_credential do
      after(:build) do |user|
        user.build_user_credential(
          email_address: "user@example.com",
          password: "password123",
          password_confirmation: "password123"
        )
      end
    end
  end

  factory :user_credential do
    email_address { "user@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    association :user
  end

  factory :session do
    association :user
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0 (test)" }
  end
end
