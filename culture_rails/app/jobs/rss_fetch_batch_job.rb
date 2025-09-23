class RssFetchBatchJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting batch RSS fetch for all active feeds"

    results = {
      total_feeds: 0,
      successful_feeds: 0,
      failed_feeds: 0,
      total_articles_created: 0,
      errors: []
    }

    Feed.active.find_each do |feed|
      results[:total_feeds] += 1

      begin
        created_count = feed.fetch_articles
        results[:successful_feeds] += 1
        results[:total_articles_created] += created_count

        Rails.logger.info "Feed #{feed.id} (#{feed.title}): #{created_count} articles created"
      rescue => e
        results[:failed_feeds] += 1
        results[:errors] << { feed_id: feed.id, title: feed.title, error: e.message }

        Rails.logger.error "Feed #{feed.id} failed: #{e.message}"
      end
    end

    Rails.logger.info "Batch RSS fetch completed: #{results[:successful_feeds]}/#{results[:total_feeds]} feeds successful, #{results[:total_articles_created]} articles created"

    results
  end
end
