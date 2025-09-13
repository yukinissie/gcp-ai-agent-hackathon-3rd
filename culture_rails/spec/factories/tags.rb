FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag #{n}" }
    category { 'anime' }
    description { 'Sample tag description' }
    image_url { 'https://example.com/image.jpg' }
    external_id { nil }
    metadata { {} }

    trait :anime do
      category { 'anime' }
      name { 'Attack on Titan' }
    end

    trait :book do
      category { 'book' }
      name { 'One Piece' }
    end

    trait :movie do
      category { 'movie' }
      name { 'Spirited Away' }
    end

    trait :with_metadata do
      metadata do
        {
          genre: ['Action', 'Drama'],
          year: 2023,
          rating: 8.5
        }
      end
    end
  end
end
