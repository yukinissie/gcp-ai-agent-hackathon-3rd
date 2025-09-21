class Api::V1::ArticlesController < ApplicationController
  skip_before_action :authenticate, only: [:index, :show]
  skip_before_action :verify_authenticity_token
  before_action :require_authentication, only: [:create, :update, :destroy]
  before_action :set_article, only: [:show, :update, :destroy]
  
  def index
    @articles = Article.published
                      .preload(:tags)
                      .order(published_at: :desc)
  end
  
  def show
    # set_articleで@articleはセット済み
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
    if @article.update(article_params)
      render :show
    else
      @errors = @article.errors.full_messages
      render :errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    @article.destroy
    head :no_content
  end
  
  private
  
  def set_article
    @article = Article.preload(:tags).find(params[:id])
  end
  
  def article_params
    params.require(:article).permit(
      :title, :summary, :content, :content_format,
      :author, :source_url, :image_url, :published,
      tag_ids: []
    )
  end
end