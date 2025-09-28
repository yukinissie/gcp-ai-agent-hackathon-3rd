module Parsers
  class AtomParser < BaseParser
    ATOM_NAMESPACE = "http://www.w3.org/2005/Atom".freeze

    def parse
      entries = find_entries
      Rails.logger.info "Found #{entries.size} Atom entries"

      entries.first(20).map do |entry|
        {
          title: extract_title(entry),
          link: extract_link(entry),
          description: extract_description(entry),
          content: extract_content(entry),
          author: extract_author(entry),
          pub_date: extract_pub_date(entry)
        }
      end
    end

    private

    def find_entries
      # 名前空間対応でentry要素を検索
      entries = @xml_doc.xpath("//atom:entry", "atom" => ATOM_NAMESPACE)
      entries = @xml_doc.xpath("//entry") if entries.empty?
      entries
    end

    def extract_title(entry)
      title = entry.xpath("atom:title", "atom" => ATOM_NAMESPACE).text.strip
      title = entry.xpath("title").text.strip if title.blank?
      title
    end

    def extract_link(entry)
      # rel="alternate"のリンクを優先
      link_node = entry.xpath('atom:link[@rel="alternate"]', "atom" => ATOM_NAMESPACE).first
      link = link_node&.attr("href")

      # なければ最初のリンク
      if link.blank?
        link_node = entry.xpath("atom:link", "atom" => ATOM_NAMESPACE).first
        link = link_node&.attr("href")
      end

      # 名前空間なしでも試す
      if link.blank?
        link_node = entry.xpath('link[@rel="alternate"]').first
        link = link_node&.attr("href")
      end

      if link.blank?
        link_node = entry.xpath("link").first
        link = link_node&.attr("href") || link_node&.text&.strip
      end

      link || ""
    end

    def extract_description(entry)
      # summary を優先
      description = entry.xpath("atom:summary", "atom" => ATOM_NAMESPACE).text
      description = entry.xpath("summary").text if description.blank?

      # なければ content を使用
      if description.blank?
        description = entry.xpath("atom:content", "atom" => ATOM_NAMESPACE).text
        description = entry.xpath("content").text if description.blank?
      end

      clean_content = clean_html_content(description)
      truncate_description(clean_content)
    end

    def extract_content(entry)
      # content を優先
      content = entry.xpath("atom:content", "atom" => ATOM_NAMESPACE).text
      content = entry.xpath("content").text if content.blank?

      # なければ summary を使用
      if content.blank?
        content = entry.xpath("atom:summary", "atom" => ATOM_NAMESPACE).text
        content = entry.xpath("summary").text if content.blank?
      end

      content.presence || "No content available"
    end

    def extract_author(entry)
      # author/name を検索
      author = entry.xpath("atom:author/atom:name", "atom" => ATOM_NAMESPACE).text
      author = entry.xpath("author/name").text if author.blank?

      # authorの直下テキスト
      if author.blank?
        author = entry.xpath("atom:author", "atom" => ATOM_NAMESPACE).text
        author = entry.xpath("author").text if author.blank?
      end

      author.presence || "Unknown"
    end

    def extract_pub_date(entry)
      # published を優先
      date_string = entry.xpath("atom:published", "atom" => ATOM_NAMESPACE).text
      date_string = entry.xpath("published").text if date_string.blank?

      # なければ updated を使用
      if date_string.blank?
        date_string = entry.xpath("atom:updated", "atom" => ATOM_NAMESPACE).text
        date_string = entry.xpath("updated").text if date_string.blank?
      end

      parse_date(date_string)
    end
  end
end
