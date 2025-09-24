class TagSearchHistory < ApplicationRecord
  belongs_to :user

  validates :article_ids, presence: true
  validates :searched_at, presence: true

  before_validation :set_searched_at, on: :create

  def article_ids_array
    article_ids || []
  end

  def article_ids_array=(ids)
    self.article_ids = ids
  end

  private

  def set_searched_at
    self.searched_at ||= Time.current
  end
end
