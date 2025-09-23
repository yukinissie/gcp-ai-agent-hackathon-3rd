class RssFetchSingleJob < ApplicationJob
  queue_as :default

  def perform(feed_id)
    feed = Feed.find(feed_id)

    Rails.logger.info "Starting RSS fetch for feed: #{feed.title} (#{feed.id})"

    created_count = feed.fetch_articles

    Rails.logger.info "Completed RSS fetch for feed #{feed.id}: #{created_count} articles created"

    created_count
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Feed not found: #{feed_id}"
    raise
  rescue => e
    Rails.logger.error "RSS fetch failed for feed #{feed_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
