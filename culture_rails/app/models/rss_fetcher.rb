class RssFetcher
  def initialize(feed)
    @feed = feed
  end

  def fetch_articles
    Rails.logger.info "=== Starting RSS fetch for feed: #{@feed.title} (#{@feed.endpoint}) ==="

    # 1. XMLを取得
    xml_doc = fetch_xml
    return 0 unless xml_doc

    # 2. XMLの形式を判定
    feed_info = analyze_feed(xml_doc)
    Rails.logger.info "Feed analysis: #{feed_info}"

    return 0 if feed_info[:format] == "unknown"

    # 3. フィードタイトルを更新（初回のみ）
    update_feed_title(feed_info[:title]) if @feed.title.blank?

    # 4. それぞれパースする
    parsed_items = parse_feed(xml_doc, feed_info[:format])
    return 0 if parsed_items.empty?

    # 5. 記事Modelに登録する（Mastra APIとの疎通で決定されるタグ・要約を含む）
    created_count = create_articles(parsed_items)

    # 成功マーク
    mark_as_successful

    Rails.logger.info "=== Created #{created_count} articles from feed #{@feed.id} =="
    created_count
  rescue => e
    Rails.logger.error "=== Error in RSS fetch: #{e.message} =="
    Rails.logger.error e.backtrace.join("\n")
    mark_as_failed(e.message)
    0
  end

  private

  def fetch_xml
    xml_fetcher = XmlFetcher.new(@feed.endpoint)
    xml_fetcher.fetch
  rescue XmlFetcher::FetchError, XmlFetcher::ParseError => e
    Rails.logger.error "XML fetch failed: #{e.message}"
    nil
  end

  def analyze_feed(xml_doc)
    analyzer = FeedAnalyzer.new(xml_doc)
    analyzer.analyze
  end

  def parse_feed(xml_doc, format)
    parser = create_parser(xml_doc, format)
    parser.parse
  end

  def create_parser(xml_doc, format)
    case format
    when "rss"
      Parsers::RssParser.new(xml_doc)
    when "rss10"
      Parsers::Rss10Parser.new(xml_doc)
    when "atom"
      Parsers::AtomParser.new(xml_doc)
    else
      raise "Unsupported feed format: #{format}"
    end
  end

  def create_articles(parsed_items)
    creator = ArticleCreator.new(@feed)
    creator.create_articles(parsed_items)
  end

  def update_feed_title(title)
    return if title.blank?
    @feed.update!(title: title)
  end

  def mark_as_successful
    @feed.update!(
      status: "active",
      last_fetched_at: Time.current,
      last_error: nil
    )
  end

  def mark_as_failed(error_message)
    @feed.update!(
      status: "error",
      last_error: error_message
    )
  end
end
