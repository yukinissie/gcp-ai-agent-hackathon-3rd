class Api::V1::TagsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  # GET /api/v1/tags
  # GET /api/v1/tags?q=検索キーワード
  def index
    @tags = build_tags_scope
  end
  
  private
  
  def build_tags_scope
    # 検索パラメータがない場合は人気順で早期リターン
    return Tag.popular.limit(50) unless params[:q].present?
    
    # タグ名検索
    Tag.search_by_name(params[:q]).order(:name)
  end
end