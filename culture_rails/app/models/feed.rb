# == Schema Information
#
# Table name: feeds
#
#  id                                  :bigint           not null, primary key
#  endpoint(RSS/AtomフィードのURL)     :string           not null
#  last_error(最後のエラーメッセージ)  :text
#  last_fetched_at(最後に取得した日時) :datetime
#  status(フィードの状態)              :string           default("active"), not null
#  title(フィードのタイトル)           :string           not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_feeds_on_created_at       (created_at)
#  index_feeds_on_endpoint         (endpoint) UNIQUE
#  index_feeds_on_last_fetched_at  (last_fetched_at)
#  index_feeds_on_status           (status)
#
class Feed < ApplicationRecord
  has_many :articles, dependent: :destroy

  validates :title, presence: true
  validates :endpoint, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :endpoint, uniqueness: true

  enum :status, {
    active: "active",
    inactive: "inactive",
    error: "error"
  }

  scope :active, -> { where(status: "active") }
  scope :recent, -> { order(created_at: :desc) }

  # RSSフィードから記事を取得・作成（リファクタリング後）
  def fetch_articles
    fetcher = RssFetcher.new(self)
    fetcher.fetch_articles
  end

  # 互換性メソッド（テスト用）
  def parsed_xml
    xml_fetcher = XmlFetcher.new(endpoint)
    xml_fetcher.fetch
  rescue XmlFetcher::FetchError, XmlFetcher::ParseError => e
    update!(status: "error", last_error: e.message)
    nil
  end

  def update_title_from_xml
    doc = parsed_xml
    return unless doc

    analyzer = FeedAnalyzer.new(doc)
    feed_info = analyzer.analyze

    return if feed_info[:title].blank?
    update!(title: feed_info[:title])
  end

  def mark_as_fetched
    update!(
      status: "active",
      last_fetched_at: Time.current,
      last_error: nil
    )
  end

  def mark_as_error(error_message)
    update!(
      status: "error",
      last_error: error_message
    )
  end

  private

  def article_exists?(url)
    return false if url.blank?
    articles.exists?(source_url: url)
  end
end
