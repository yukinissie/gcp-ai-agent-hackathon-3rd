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

  # XMLを取得してNokogiriでパースする
  def parsed_xml
    begin
      require "net/http"
      require "nokogiri"

      xml = Net::HTTP.get(URI.parse(endpoint))
      Rails.logger.info "RSS XML content (first 500 chars): #{xml[0..500]}"

      doc = Nokogiri::XML(xml) { |config| config.strict }

      # XMLの構造をチェック
      if doc.errors.any?
        raise "XML parsing errors: #{doc.errors.map(&:message).join(', ')}"
      end

      Rails.logger.info "XML parsed successfully: root=#{doc.root&.name}"
      doc
    rescue => e
      Rails.logger.error "Failed to parse XML for Feed #{id}: #{e.message}"
      update!(status: "error", last_error: e.message)
      nil
    end
  end

  # フィードのタイトルを自動更新
  def update_title_from_xml
    doc = parsed_xml
    return unless doc

    # RSS2.0の場合
    feed_title = doc.xpath("//channel/title").text
    # Atomの場合（名前空間を考慮）
    if feed_title.blank?
      feed_title = doc.xpath("//atom:feed/atom:title", "atom" => "http://www.w3.org/2005/Atom").text
    end
    # 名前空間なしでも試す
    feed_title = doc.xpath("//feed/title").text if feed_title.blank?

    return if feed_title.blank?
    update!(title: feed_title)
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
    Rails.logger.info "=== Starting RSS fetch for feed: #{title} (#{endpoint}) ==="

    doc = parsed_xml
    Rails.logger.info "=== XML parsed result: #{doc&.root&.name} =="
    return 0 unless doc

    # フィードタイトルを更新（初回のみ）
    update_title_from_xml if title.blank?

    # 記事を作成
    created_count = create_articles_from_xml(doc)

    # 成功マーク
    mark_as_fetched

    Rails.logger.info "=== Created #{created_count} articles from feed #{id} =="
    created_count
  rescue => e
    Rails.logger.error "=== Error in fetch_articles: #{e.message} =="
    mark_as_error(e.message)
    0
  end

  private

  def create_articles_from_xml(doc)
    Rails.logger.info "create_articles_from_xml called with doc: #{doc.class}"
    return 0 unless doc

    # RSS2.0の場合は//item、Atomの場合は//entry（名前空間対応）
    items = doc.xpath("//item | //entry | //atom:entry", "atom" => "http://www.w3.org/2005/Atom")
    Rails.logger.info "XML items/entries count: #{items.size}"
    return 0 if items.empty?

    created_count = 0

    items.first(20).each_with_index do |item, index|
      title = extract_title_from_xml(item)
      link = extract_link_from_xml(item)

      Rails.logger.info "Processing item #{index}: title=#{title}, link=#{link}"

      # URL重複チェック（データベースの複合ユニーク制約に依存）
      if article_exists?(link)
        Rails.logger.info "Article already exists (duplicate URL): title=#{title}"
        next
      end

      article = create_article_from_xml(item)
      Rails.logger.info "Article created: #{article&.persisted?}, id=#{article&.id}"
      if article&.persisted?
        created_count += 1
        auto_tag_article(article)
      end
    end

    Rails.logger.info "Created articles count: #{created_count}"
    created_count
  end

  def article_exists?(url)
    return false if url.blank?
    articles.exists?(source_url: url)
  end

  def create_article_from_xml(item_node)
    title = extract_title_from_xml(item_node)
    link = extract_link_from_xml(item_node)
    pub_date = extract_pubdate_from_xml(item_node)

    Rails.logger.info "Creating article: title=#{title}, link=#{link}, pub_date=#{pub_date}"

    articles.create!(
      source_type: "rss",
      title: title || "Untitled",
      summary: extract_summary_from_xml(item_node),
      content: extract_content_from_xml(item_node),
      content_format: "html",
      author: extract_author_from_xml(item_node),
      source_url: link,
      published: true,
      published_at: pub_date
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn "Failed to create article from XML item: #{e.message}"
    Rails.logger.warn "Errors: #{e.record.errors.full_messages}"
    nil
  end

  # XMLからタイトルを抽出
  def extract_title_from_xml(item_node)
    # RSS2.0とAtomの両方に対応
    title = item_node.xpath("title").text.strip
    # Atomの名前空間対応（念のため）
    if title.blank?
      title = item_node.xpath("atom:title", "atom" => "http://www.w3.org/2005/Atom").text.strip
    end
    title
  end

  # XMLからリンクを抽出
  def extract_link_from_xml(item_node)
    # RSS2.0の場合
    link = item_node.xpath("link").text.strip
    # Atomの場合（名前空間対応）
    if link.blank?
      link_node = item_node.xpath('atom:link[@rel="alternate"]', "atom" => "http://www.w3.org/2005/Atom").first
      link = link_node&.attr("href")
    end
    # 名前空間なしでも試す
    if link.blank?
      link_node = item_node.xpath('link[@rel="alternate"]').first
      link = link_node&.attr("href")
    end
    link
  end

  # XMLから公開日を抽出
  def extract_pubdate_from_xml(item_node)
    # RSS2.0の場合
    pub_date = item_node.xpath("pubDate").text
    # Atomの場合（名前空間対応）
    if pub_date.blank?
      pub_date = item_node.xpath("atom:published", "atom" => "http://www.w3.org/2005/Atom").text
    end
    # 名前空間なしでも試す
    pub_date = item_node.xpath("published").text if pub_date.blank?

    begin
      Time.parse(pub_date) if pub_date.present?
    rescue
      Time.current
    end || Time.current
  end

  # XMLからサマリーを抽出
  def extract_summary_from_xml(item_node)
    # RSS2.0の場合
    description = item_node.xpath("description").text
    # Atomの場合（名前空間対応）
    if description.blank?
      description = item_node.xpath("atom:content", "atom" => "http://www.w3.org/2005/Atom").text
    end
    if description.blank?
      description = item_node.xpath("atom:summary", "atom" => "http://www.w3.org/2005/Atom").text
    end
    # 名前空間なしでも試す
    description = item_node.xpath("content").text if description.blank?
    description = item_node.xpath("summary").text if description.blank?

    clean_description = ActionController::Base.helpers.strip_tags(description.to_s)
    clean_description.truncate(500)
  end

  # XMLからコンテンツを抽出
  def extract_content_from_xml(item_node)
    # RSS2.0のcontent:encoded
    content = item_node.xpath("content:encoded", "content" => "http://purl.org/rss/1.0/modules/content/").text
    # 通常のdescription
    content = item_node.xpath("description").text if content.blank?
    # Atomのcontent（名前空間対応）
    if content.blank?
      content = item_node.xpath("atom:content", "atom" => "http://www.w3.org/2005/Atom").text
    end
    # 名前空間なしでも試す
    content = item_node.xpath("content").text if content.blank?

    content.presence || ""
  end

  # XMLから著者を抽出
  def extract_author_from_xml(item_node)
    # RSS2.0の場合
    author = item_node.xpath("author").text
    # Atomの場合（名前空間対応）
    if author.blank?
      author_node = item_node.xpath("atom:author/atom:name", "atom" => "http://www.w3.org/2005/Atom").first
      author = author_node&.text
    end
    # 名前空間なしでも試す
    if author.blank?
      author_node = item_node.xpath("author/name").first
      author = author_node&.text
    end
    # dc:creator
    author = item_node.xpath("dc:creator", "dc" => "http://purl.org/dc/elements/1.1/").text if author.blank?

    author.presence || title || "Unknown"
  end


  # 自動タグ付け
  def auto_tag_article(article)
    # フィード名をタグとして追加（techカテゴリとして）
    tag = Tag.find_or_create_by(name: title, category: "tech")
    article.tags << tag unless article.tags.include?(tag)
  end
end
