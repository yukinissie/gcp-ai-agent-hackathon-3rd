class Api::V1::ActivitiesController < ApplicationController
  skip_before_action :verify_authenticity_token  # API用: CSRF保護を無効化
  before_action :require_authentication

  # POST /api/v1/articles/:article_id/activities
  def create
    unless %w[good bad].include?(params[:activity_type])
      return render json: {
        success: false,
        error: "invalid_parameter",
        message: "activity_typeパラメータが無効です"
      }, status: :unprocessable_entity
    end

    article = Article.find(params[:article_id])

    @current_evaluation = Activity.set_evaluation(current_user, article, params[:activity_type])
    @article_stats = Activity.article_stats(article)
    @article = article

    render :show, status: :created
  rescue ActiveRecord::RecordNotFound
    render json: {
      success: false,
      error: "not_found",
      message: "記事が見つかりません"
    }, status: :not_found
  end
end
