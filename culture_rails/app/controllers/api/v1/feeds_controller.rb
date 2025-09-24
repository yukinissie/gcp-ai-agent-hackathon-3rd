class Api::V1::FeedsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # before_action :require_authentication
  before_action :set_feed, only: [ :show, :update, :destroy, :fetch ]

  # GET /api/v1/feeds
  def index
    @feeds = Feed.includes(:articles).recent
  end

  # GET /api/v1/feeds/:id
  def show
    @articles = @feed.articles
                    .published
                    .recent
                    .limit(20)
                    .includes(:tags)
  end

  # POST /api/v1/feeds
  def create
    @feed = Feed.new(feed_params)

    if @feed.save
      # 作成後に即座に初回フェッチを実行
      @feed.fetch_articles
      render :show, status: :created
    else
      render json: { errors: @feed.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/feeds/:id
  def update
    if @feed.update(feed_params)
      render :show
    else
      render json: { errors: @feed.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/feeds/:id
  def destroy
    @feed.destroy
    head :no_content
  end

  # POST /api/v1/feeds/:id/fetch
  def fetch
    created_count = @feed.fetch_articles

    render json: {
      message: "RSS fetch completed",
      feed_id: @feed.id,
      articles_created: created_count
    }
  end

  # POST /api/v1/feeds/batch_fetch
  def batch_fetch
    total_created = 0
    error_count = 0

    Feed.active.find_each do |feed|
      begin
        created_count = feed.fetch_articles
        total_created += created_count
      rescue => e
        error_count += 1
        Rails.logger.error "Batch fetch failed for feed #{feed.id}: #{e.message}"
      end
    end

    render json: {
      message: "RSS batch fetch completed",
      total_articles_created: total_created,
      errors: error_count,
      active_feeds_count: Feed.active.count
    }
  end

  private

  def set_feed
    @feed = Feed.find(params[:id])
  end

  def feed_params
    params.require(:feed).permit(:title, :endpoint, :status)
  end
end
