class FeedAnalyzer
  FEED_FORMATS = {
    rss: "rss",
    rss10: "rss10",
    atom: "atom",
    unknown: "unknown"
  }.freeze

  def initialize(xml_doc)
    @xml_doc = xml_doc
  end

  def analyze
    format = detect_format
    Rails.logger.info "Detected feed format: #{format}"

    {
      format: format,
      title: extract_feed_title,
      items_count: count_items,
      root_element: @xml_doc.root&.name
    }
  end

  private

  def detect_format
    return FEED_FORMATS[:unknown] unless @xml_doc&.root

    root_name = @xml_doc.root.name.downcase

    case root_name
    when "rss"
      FEED_FORMATS[:rss]
    when "feed"
      # Atom名前空間の確認
      if @xml_doc.root.namespace&.href == "http://www.w3.org/2005/Atom"
        FEED_FORMATS[:atom]
      else
        FEED_FORMATS[:atom] # 名前空間なしでもAtomとして扱う
      end
    when "rdf:rdf", "rdf"
      FEED_FORMATS[:rss10] # RSS 1.0 (RDF)
    else
      FEED_FORMATS[:unknown]
    end
  end

  def extract_feed_title
    case detect_format
    when FEED_FORMATS[:rss]
      # RSS 2.0
      @xml_doc.xpath("//channel/title").text.strip
    when FEED_FORMATS[:rss10]
      # RSS 1.0 (RDF)
      title = @xml_doc.xpath("//rss:channel/rss:title", "rss" => "http://purl.org/rss/1.0/").text.strip
      title = @xml_doc.xpath("//channel/title").text.strip if title.blank?
      title
    when FEED_FORMATS[:atom]
      # 名前空間対応
      title = @xml_doc.xpath("//atom:feed/atom:title", "atom" => "http://www.w3.org/2005/Atom").text.strip
      title = @xml_doc.xpath("//feed/title").text.strip if title.blank?
      title
    else
      ""
    end
  end

  def count_items
    case detect_format
    when FEED_FORMATS[:rss]
      # RSS 2.0
      @xml_doc.xpath("//item").size
    when FEED_FORMATS[:rss10]
      # RSS 1.0 (RDF) - 名前空間対応
      items = @xml_doc.xpath("//rss:item", "rss" => "http://purl.org/rss/1.0/").size
      items = @xml_doc.xpath("//item").size if items == 0
      items
    when FEED_FORMATS[:atom]
      # 名前空間対応
      atom_entries = @xml_doc.xpath("//atom:entry", "atom" => "http://www.w3.org/2005/Atom").size
      atom_entries = @xml_doc.xpath("//entry").size if atom_entries == 0
      atom_entries
    else
      0
    end
  end
end
