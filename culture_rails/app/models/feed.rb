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
  require "rss"
  require "net/http"

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

  # RSSをパースして取得
  def parsed_rss
    begin
      xml = Net::HTTP.get(URI.parse(endpoint))
      RSS::Parser.parse(xml)
    rescue => e
      Rails.logger.error "Failed to parse RSS for Feed #{id}: #{e.message}"
      update!(status: "error", last_error: e.message)
      nil
    end
  end

  # フィードのタイトルを自動更新
  def update_title_from_rss
    rss = parsed_rss
    return unless rss&.channel&.title

    update!(title: rss.channel.title)
  end

  # 最後の取得成功時刻を更新
  def mark_as_fetched
    update!(
      status: "active",
      last_fetched_at: Time.current,
      last_error: nil
    )
  end

  # エラーマーク
  def mark_as_error(error_message)
    update!(
      status: "error",
      last_error: error_message
    )
  end

  # RSSフィードから記事を取得・作成
  def fetch_articles
    Rails.logger.info "Starting RSS fetch for feed: #{title} (#{endpoint})"

    rss = parsed_rss
    return 0 unless rss

    # フィードタイトルを更新（初回のみ）
    update_title_from_rss if title.blank?

    # 記事を作成
    created_count = create_articles_from_rss(rss)

    # 成功マーク
    mark_as_fetched

    Rails.logger.info "Created #{created_count} articles from feed #{id}"
    created_count
  rescue => e
    mark_as_error(e.message)
    Rails.logger.error "Failed to fetch RSS for feed #{id}: #{e.message}"
    0
  end

  private

  def create_articles_from_rss(rss)
    return 0 unless rss.items

    created_count = 0

    rss.items.first(20).each do |item| # 最新20件まで処理
      next if article_exists?(item.link)

      article = create_article_from_item(item)
      if article&.persisted?
        created_count += 1
        auto_tag_article(article)
      end
    end

    created_count
  end

  def article_exists?(url)
    return false if url.blank?
    articles.exists?(source_url: url)
  end

  def create_article_from_item(item)
    articles.create!(
      source_type: "rss",
      title: item.title&.strip || "Untitled",
      summary: extract_summary(item),
      content: extract_content(item),
      content_format: "html",
      author: extract_author(item),
      source_url: item.link,
      published: true,
      published_at: item.pubDate || Time.current
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn "Failed to create article from RSS item: #{e.message}"
    nil
  end

  def extract_summary(item)
    description = item.description || item.content_encoded || ""
    clean_description = ActionController::Base.helpers.strip_tags(description)
    clean_description.truncate(500)
  end

  def extract_content(item)
    item.content_encoded || item.description || item.title || ""
  end

  def extract_author(item)
    item.author || item.dc_creator || title || "Unknown"
  end

  # 自動タグ付け
  def auto_tag_article(article)
    # フィード名をタグとして追加
    tag = Tag.find_or_create_by(name: title, category: "source")
    article.tags << tag unless article.tags.include?(tag)
  end
end
