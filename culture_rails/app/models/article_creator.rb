class ArticleCreator
  def initialize(feed)
    @feed = feed
    @mastra_client = MastraClient.new
  end

  def create_articles(parsed_items)
    Rails.logger.info "Creating #{parsed_items.size} articles for feed #{@feed.id}"

    created_count = 0

    parsed_items.each_with_index do |item, index|
      Rails.logger.info "Processing item #{index + 1}: #{item[:title]}"

      if article_exists?(item[:link])
        Rails.logger.info "Article already exists (duplicate URL): #{item[:title]}"
        next
      end

      article = create_article(item)

      if article&.persisted?
        created_count += 1
        create_tags(article, item)
        Rails.logger.info "Article created successfully: #{article.id}"
      else
        Rails.logger.warn "Failed to create article: #{item[:title]}"
      end
    end

    Rails.logger.info "Created #{created_count} articles for feed #{@feed.id}"
    created_count
  end

  private

  def article_exists?(url)
    return false if url.blank?
    @feed.articles.exists?(source_url: url)
  end

  def create_article(item)
    # Mastra APIで拡張情報を生成
    enhanced_data = @mastra_client.generate_tags_and_summary(item)

    @feed.articles.create!(
      source_type: "rss",
      title: item[:title] || "Untitled",
      summary: enhanced_data[:summary] || item[:description],
      content: item[:content],
      content_format: "html",
      author: item[:author],
      source_url: item[:link],
      published: true,
      published_at: item[:pub_date]
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn "Failed to create article: #{e.message}"
    Rails.logger.warn "Errors: #{e.record.errors.full_messages}"
    nil
  end

  def create_tags(article, item)
    # フィード名をソースタグとして追加
    create_source_tag(article)

    # Mastra APIで生成されたタグを追加
    enhanced_data = @mastra_client.generate_tags_and_summary(item)
    create_generated_tags(article, enhanced_data[:tags])
  end

  def create_source_tag(article)
    tag = Tag.find_or_create_by(name: @feed.title, category: "source")
    article.tags << tag unless article.tags.include?(tag)
  rescue => e
    Rails.logger.warn "Failed to create source tag: #{e.message}"
  end

  def create_generated_tags(article, tag_names)
    return if tag_names.blank?

    tag_names.each do |tag_name|
      tag = Tag.find_or_create_by(name: tag_name, category: "auto")
      article.tags << tag unless article.tags.include?(tag)
    end
  rescue => e
    Rails.logger.warn "Failed to create generated tags: #{e.message}"
  end
end
