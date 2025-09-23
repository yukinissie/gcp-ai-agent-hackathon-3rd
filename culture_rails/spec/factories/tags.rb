# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  category   :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_category           (category)
#  index_tags_on_name_and_category  (name,category) UNIQUE
#
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
