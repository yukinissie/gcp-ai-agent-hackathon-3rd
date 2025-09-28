class Api::V1::TagSearchHistoriesController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!

  def create
    tag_search_history = current_user.tag_search_histories.build(tag_search_history_params)

    if tag_search_history.save
      render json: { success: true }, status: :created
    else
      render json: { success: false, errors: tag_search_history.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def articles
    latest_history = current_user.tag_search_histories.order(created_at: :desc).first

    unless latest_history
      render json: {
        success: false,
        error: "not_found",
        message: "検索履歴が見つかりません"
      }, status: :not_found
      return
    end

    article_ids = latest_history.article_ids_array.map(&:to_i)

    # より効率的な実装: 記事をハッシュで取得してメモリ内でソート
    articles_hash = Article.includes(:tags)
                          .where(id: article_ids, published: true)
                          .index_by(&:id)

    # 元の順序を保持しつつ存在する記事のみを取得
    articles = article_ids.filter_map { |id| articles_hash[id] }

    articles_data = articles.map do |article|
      {
        id: article.id,
        title: article.title,
        summary: article.summary,
        author: article.author,
        content: article.content,
        published_at: article.published_at,
        tags: article.tags.pluck(:name)
      }
    end

    render json: {
      success: true,
      data: {
        articles: articles_data
      }
    }
  end

  private

  def tag_search_history_params
    params.require(:tag_search_history).permit(article_ids: [])
  end
end
