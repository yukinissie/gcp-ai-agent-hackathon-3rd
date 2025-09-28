class TagSearchHistory < ApplicationRecord
  belongs_to :user

  validates :article_ids, presence: true

  def article_ids_array
    article_ids || []
  end

  def article_ids_array=(ids)
    self.article_ids = ids
  end
end
