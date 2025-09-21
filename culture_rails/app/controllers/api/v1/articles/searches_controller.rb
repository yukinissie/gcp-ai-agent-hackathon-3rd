class Api::V1::Articles::SearchesController < ApplicationController
  skip_before_action :authenticate
  skip_before_action :verify_authenticity_token
  
  def index
    @articles = build_search_scope
                  .preload(:tags)
                  .order(published_at: :desc)
  end
  
  private
  
  def build_search_scope
    scope = Article.published
    
    # テキスト検索
    scope = scope.search_by_text(params[:q]) if params[:q].present?
    
    # タグ検索
    if params[:tags].present?
      tag_names = params[:tags].split(',').map(&:strip)
      scope = scope.with_tags(tag_names)
    end
    
    scope
  end
end