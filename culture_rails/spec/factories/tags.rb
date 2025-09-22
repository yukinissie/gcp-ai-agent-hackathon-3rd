FactoryBot.define do
  factory :tag do
    name { "テクノロジー" }
    category { "tech" }
    
    trait :tech do
      category { "tech" }
    end
    
    trait :art do
      category { "art" }
    end
    
    trait :music do
      category { "music" }
    end
    
    trait :architecture do
      category { "architecture" }
    end
    
    trait :lifestyle do
      category { "lifestyle" }
    end
    
    trait :business do
      category { "business" }
    end
  end
end
