class Api::V1::UserAttributesController < ApplicationController
  before_action :require_authentication

  # GET /api/v1/user_attributes
  def show
    @ingredient = current_user.ingredient

    # 初回アクセス時の自動作成
    if @ingredient.nil?
      current_user.create_ingredient!
      @ingredient = current_user.ingredient
      @ingredient.update_llm_payload! # 初期データ生成
    end

    @user = current_user
  end
end
