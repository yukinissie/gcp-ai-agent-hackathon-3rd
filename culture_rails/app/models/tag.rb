class Tag < ApplicationRecord
  has_many :article_taggings, dependent: :destroy
  has_many :articles, through: :article_taggings
  
  validates :name, presence: true, uniqueness: { scope: :category }
  validates :category, presence: true
  
  enum :category, {
    tech: 'tech',
    art: 'art', 
    music: 'music',
    architecture: 'architecture',
    lifestyle: 'lifestyle',
    business: 'business'
  }
  
  scope :by_category, ->(category) { where(category: category) }
  scope :popular, -> { joins(:article_taggings).group(:id).order('COUNT(article_taggings.id) DESC') }
end
