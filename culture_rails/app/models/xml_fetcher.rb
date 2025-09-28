class XmlFetcher
  class FetchError < StandardError; end
  class ParseError < StandardError; end

  def initialize(url)
    @url = url
  end

  def fetch
    Rails.logger.info "Fetching XML from: #{@url}"

    xml_content = fetch_xml_content
    parsed_doc = parse_xml(xml_content)

    Rails.logger.info "Successfully fetched and parsed XML"
    parsed_doc
  end

  private

  def fetch_xml_content
    require "net/http"

    uri = URI.parse(@url)
    response = Net::HTTP.get_response(uri)

    unless response.code == "200"
      raise FetchError, "HTTP #{response.code}: #{response.message}"
    end

    response.body
  rescue URI::InvalidURIError => e
    raise FetchError, "Invalid URL: #{e.message}"
  rescue Net::HTTPError, SocketError => e
    raise FetchError, "Network error: #{e.message}"
  end

  def parse_xml(xml_content)
    require "nokogiri"

    doc = Nokogiri::XML(xml_content) { |config| config.strict }

    if doc.errors.any?
      raise ParseError, "XML parsing errors: #{doc.errors.map(&:message).join(', ')}"
    end

    doc
  rescue Nokogiri::XML::SyntaxError => e
    raise ParseError, "XML syntax error: #{e.message}"
  end
end
