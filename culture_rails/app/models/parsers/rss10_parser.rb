module Parsers
  class Rss10Parser < BaseParser
    RSS10_NAMESPACE = "http://purl.org/rss/1.0/".freeze
    DC_NAMESPACE = "http://purl.org/dc/elements/1.1/".freeze
    CONTENT_NAMESPACE = "http://purl.org/rss/1.0/modules/content/".freeze

    def parse
      items = find_items
      Rails.logger.info "Found #{items.size} RSS 1.0 items"

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

    def find_items
      # RSS 1.0の名前空間対応でitem要素を検索
      items = @xml_doc.xpath("//rss:item", "rss" => RSS10_NAMESPACE)
      items = @xml_doc.xpath("//item") if items.empty?
      items
    end

    def extract_title(item)
      title = item.xpath("rss:title", "rss" => RSS10_NAMESPACE).text.strip
      title = item.xpath("title").text.strip if title.blank?
      title
    end

    def extract_link(item)
      link = item.xpath("rss:link", "rss" => RSS10_NAMESPACE).text.strip
      link = item.xpath("link").text.strip if link.blank?
      link
    end

    def extract_description(item)
      description = item.xpath("rss:description", "rss" => RSS10_NAMESPACE).text
      description = item.xpath("description").text if description.blank?

      clean_content = clean_html_content(description)
      truncate_description(clean_content)
    end

    def extract_content(item)
      # content:encoded を優先
      content = item.xpath("content:encoded", "content" => CONTENT_NAMESPACE).text
      content = item.xpath("rss:description", "rss" => RSS10_NAMESPACE).text if content.blank?
      content = item.xpath("description").text if content.blank?

      content.presence || "No content available"
    end

    def extract_author(item)
      # dc:creator を優先
      author = item.xpath("dc:creator", "dc" => DC_NAMESPACE).text
      author = author.presence || "Unknown"
      author
    end

    def extract_pub_date(item)
      # dc:date を使用
      date_string = item.xpath("dc:date", "dc" => DC_NAMESPACE).text
      parse_date(date_string)
    end
  end
end
