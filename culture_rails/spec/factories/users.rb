FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    sequence(:name) { |n| "テストユーザー#{n}" }
    password { 'Passw0rd' }
    password_confirmation { 'Passw0rd' }
  end
end
