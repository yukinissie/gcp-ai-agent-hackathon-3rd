module Parsers
  class BaseParser
    def initialize(xml_doc)
      @xml_doc = xml_doc
    end

    def parse
      raise NotImplementedError, "Subclasses must implement parse method"
    end

    protected

    def clean_html_content(content)
      return "No content available" if content.blank?

      ActionController::Base.helpers.strip_tags(content.to_s)
    end

    def parse_date(date_string)
      return Time.current if date_string.blank?

      Time.parse(date_string)
    rescue ArgumentError
      Time.current
    end

    def truncate_description(text, limit = 500)
      return "No description available" if text.blank?

      text.truncate(limit)
    end
  end
end
