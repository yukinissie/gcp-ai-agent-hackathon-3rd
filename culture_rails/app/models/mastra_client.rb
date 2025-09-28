class MastraClient
  class ApiError < StandardError; end

  def initialize
    @base_url = Rails.env.production? ? ENV["MASTRA_API_URL"] : "http://localhost:3000"
    @api_key = ENV["MASTRA_API_KEY"]
  end

  def generate_tags_and_summary(article_data)
    Rails.logger.info "Generating tags and summary for article: #{article_data[:title]}"

    request_body = {
      title: article_data[:title],
      content: article_data[:content],
      description: article_data[:description]
    }

    response = make_api_request("/api/v1/generate", request_body)

    {
      tags: parse_tags(response["tags"]),
      summary: response["summary"] || article_data[:description]
    }
  rescue => e
    Rails.logger.warn "Mastra API failed, using fallback: #{e.message}"
    fallback_response(article_data)
  end

  private

  def make_api_request(endpoint, body)
    require "net/http"
    require "json"

    uri = URI("#{@base_url}#{endpoint}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@api_key}" if @api_key
    request.body = body.to_json

    response = http.request(request)

    unless response.code == "200"
      raise ApiError, "HTTP #{response.code}: #{response.message}"
    end

    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise ApiError, "Invalid JSON response: #{e.message}"
  rescue Net::HTTPError, SocketError => e
    raise ApiError, "Network error: #{e.message}"
  end

  def parse_tags(tags_data)
    return [] unless tags_data

    case tags_data
    when Array
      tags_data.map { |tag| normalize_tag(tag) }.compact
    when String
      tags_data.split(",").map { |tag| normalize_tag(tag.strip) }.compact
    else
      []
    end
  end

  def normalize_tag(tag_text)
    return nil if tag_text.blank?

    # タグの正規化（小文字、スペース除去等）
    normalized = tag_text.to_s.strip.downcase
    return nil if normalized.length < 2 || normalized.length > 50

    normalized
  end

  def fallback_response(article_data)
    Rails.logger.info "Using fallback tags and summary generation"

    {
      tags: generate_fallback_tags(article_data),
      summary: article_data[:description] || "No summary available"
    }
  end

  def generate_fallback_tags(article_data)
    tags = []

    # タイトルから簡単なキーワード抽出
    title = article_data[:title].to_s.downcase

    # 技術関連キーワード
    tech_keywords = %w[ruby rails react javascript python ai ml docker kubernetes api]
    tech_keywords.each do |keyword|
      tags << keyword if title.include?(keyword)
    end

    # デフォルトタグ
    tags << "general" if tags.empty?

    tags.uniq.first(5)
  end
end
