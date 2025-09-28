module Parsers
  class RssParser < BaseParser
    def parse
      items = @xml_doc.xpath("//item")
      Rails.logger.info "Found #{items.size} RSS items"

      items.first(20).map do |item|
        {
          title: extract_title(item),
          link: extract_link(item),
          description: extract_description(item),
          content: extract_content(item),
          author: extract_author(item),
          pub_date: extract_pub_date(item)
        }
      end
    end

    private

    def extract_title(item)
      item.xpath("title").text.strip
    end

    def extract_link(item)
      item.xpath("link").text.strip
    end

    def extract_description(item)
      description = item.xpath("description").text
      clean_content = clean_html_content(description)
      truncate_description(clean_content)
    end

    def extract_content(item)
      # content:encoded を優先
      content = item.xpath("content:encoded", "content" => "http://purl.org/rss/1.0/modules/content/").text
      content = item.xpath("description").text if content.blank?
      content.presence || "No content available"
    end

    def extract_author(item)
      # 複数の作者フィールドを試す
      author = item.xpath("author").text
      author = item.xpath("dc:creator", "dc" => "http://purl.org/dc/elements/1.1/").text if author.blank?
      author.presence || "Unknown"
    end

    def extract_pub_date(item)
      date_string = item.xpath("pubDate").text
      parse_date(date_string)
    end
  end
end
