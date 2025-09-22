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
  
  scope :search_by_name, ->(query) {
    where(arel_table[:name].matches("%#{query}%"))
  }
  scope :by_category, ->(category) { where(category: category) }
  scope :popular, -> { 
    joins(article_taggings: :article)
    .merge(Article.published)
    .group(:id)
    .order(Arel.sql('COUNT(article_taggings.id) DESC'))
  }
  
  # 公開記事でのタグ使用回数
  def published_articles_count
    articles.merge(Article.published).count
  end
  
end
