class Article < ApplicationRecord
  has_many :article_taggings, dependent: :destroy
  has_many :tags, through: :article_taggings
  
  validates :title, presence: true, length: { maximum: 255 }
  validates :summary, presence: true, length: { maximum: 500 }
  validates :content, presence: true
  validates :author, presence: true
  validates :content_format, inclusion: { in: %w[markdown html plain] }
  validates :source_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  
  scope :published, -> { where(published: true) }
  scope :search_by_text, ->(query) {
    where("title ILIKE ? OR summary ILIKE ? OR content ILIKE ?", 
          "%#{query}%", "%#{query}%", "%#{query}%")
  }
  scope :with_tags, ->(tag_names) {
    joins(:tags).where(tags: { name: tag_names }).distinct
  }
  
  def display_tags(limit = 2)
    tags.limit(limit)
  end
  
  def additional_tags_count(display_limit = 2)
    [tags.count - display_limit, 0].max
  end
  
  def publish!
    update!(published: true, published_at: Time.current)
  end
  
  def unpublish!
    update!(published: false, published_at: nil)
  end
end
