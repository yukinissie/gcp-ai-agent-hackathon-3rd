# == Schema Information
#
# Table name: articles
#
#  id                                         :bigint           not null, primary key
#  author                                     :string           not null
#  content                                    :text             not null
#  content_format                             :string           default("markdown"), not null
#  image_url                                  :string
#  published                                  :boolean          default(FALSE), not null
#  published_at                               :datetime
#  source_type(記事の作成元)                  :string           default("manual"), not null
#  source_url                                 :string
#  summary                                    :text             not null
#  title                                      :string           not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  feed_id(RSS由来の記事の場合のフィード参照) :bigint
#
# Indexes
#
#  index_articles_on_content_format               (content_format)
#  index_articles_on_feed_and_source_url_for_rss  (feed_id,source_url) UNIQUE WHERE (((source_type)::text = 'rss'::text) AND (source_url IS NOT NULL))
#  index_articles_on_feed_id                      (feed_id)
#  index_articles_on_feed_id_and_created_at       (feed_id,created_at)
#  index_articles_on_published                    (published)
#  index_articles_on_published_and_published_at   (published,published_at)
#  index_articles_on_published_at                 (published_at)
#  index_articles_on_source_type                  (source_type)
#
# Foreign Keys
#
#  fk_rails_...  (feed_id => feeds.id)
#
class Article < ApplicationRecord
  has_many :article_taggings, dependent: :destroy
  has_many :tags, through: :article_taggings
  has_many :activities, dependent: :destroy
  belongs_to :feed, optional: true

  validates :title, presence: true, length: { maximum: 1000 }  # RSS記事タイトル用に拡張
  validates :summary, presence: true, length: { maximum: 2000 }  # RSS記事サマリー用に拡張
  validates :content, presence: true
  validates :author, presence: true
  validates :content_format, inclusion: { in: %w[markdown html plain] }
  # RSS記事のURL形式チェックを緩和（不正なURLでも登録可能に）
  # validates :source_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true
  # validates :image_url, format: { with: URI::DEFAULT_PARSER.make_regexp }, allow_blank: true

  enum :source_type, {
    manual: "manual",
    rss: "rss"
  }

  validates :source_url, uniqueness: { scope: :feed_id }, if: :rss?

  scope :published, -> { where(published: true) }
  scope :manual, -> { where(source_type: "manual") }
  scope :from_rss, -> { where(source_type: "rss") }
  scope :search_by_text, ->(query) {
    return all if query.blank?
    pattern = "%#{query}%"
    where(arel_table[:title].matches(pattern))
      .or(where(arel_table[:summary].matches(pattern)))
      .or(where(arel_table[:content].matches(pattern)))
  }
  scope :with_tags, ->(tag_names) {
    return all if tag_names.blank?
    joins(:tags).where(tags: { name: tag_names }).distinct
  }
  scope :recent, -> { order(published_at: :desc) }

  def activity_type_for_user(user_id)
    activities.find_by(user_id: user_id)&.activity_type
  end

  def display_tags(limit = 2)
    # includes(:tags)で既に読み込まれたタグをメモリ上で処理
    tags.loaded? ? tags.to_a.take(limit) : tags.limit(limit)
  end

  def additional_tags_count(display_limit = 2)
    # includes(:tags)で既に読み込まれたタグをメモリ上で処理
    total_count = tags.loaded? ? tags.size : tags.count
    [ total_count - display_limit, 0 ].max
  end


  def publish!
    update!(published: true, published_at: Time.current)
  end

  def unpublish!
    update!(published: false, published_at: nil)
  end

  def from_rss?
    source_type == "rss"
  end

  def manual?
    source_type == "manual"
  end

  # 記事をIDで検索し、タグをpreloadする
  def self.find_with_tags(id)
    preload(:tags).find(id)
  end

  # 記事の詳細表示用にタグをpreloadして検索
  def self.find_for_show(id)
    find_with_tags(id)
  end
end
