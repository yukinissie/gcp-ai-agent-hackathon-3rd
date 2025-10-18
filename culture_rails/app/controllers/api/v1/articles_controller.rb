class Api::V1::ArticlesController < ApplicationController
  # 認証はオプション（認証済みならuser_activity_typeを返す、未認証ならnullを返す）
  skip_before_action :verify_authenticity_token
  before_action :require_authentication, only: [ :create, :update, :destroy ]

  # GET /api/v1/articles
  # GET /api/v1/articles?q=検索キーワード
  # GET /api/v1/articles?tags=タグ1,タグ2
  def index
    @articles = build_articles_scope
                  .includes(:tags)
                  .recent
                  .limit(50)
  end

  def show
    @article = Article.find_for_show(params[:id])
    @current_user = current_user

    # 認証済みユーザーの場合のみ読了記録を保存
    if current_user
      Activity.mark_as_read(current_user, @article)
    end
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      render :show, status: :created
    else
      @errors = @article.errors.full_messages
      render :errors, status: :unprocessable_entity
    end
  end

  def update
    @article = Article.find_for_show(params[:id])

    if @article.update(article_params)
      render :show
    else
      @errors = @article.errors.full_messages
      render :errors, status: :unprocessable_entity
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy
    head :no_content
  end

  private

  def build_articles_scope
    scope = Article.published

    # 検索パラメータがない場合は早期リターン
    return scope unless params[:q].present? || params[:tags].present?

    # テキスト検索
    scope = scope.search_by_text(params[:q]) if params[:q].present?

    # タグ検索
    scope = scope.with_tags(tag_names) if params[:tags].present?

    scope
  end

  def tag_names
    return [] unless params[:tags].present?

    params[:tags].split(",").map(&:strip).reject(&:blank?)
  end

  def article_params
    params.require(:article).permit(
      :title, :summary, :content, :content_format,
      :author, :source_url, :image_url, :published,
      tag_ids: []
    )
  end
end
