class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate, only: [ :create ]

  def create
    user = User.new
    user_credential = user.build_user_credential(user_credential_params)

    # ユーザーとユーザークレデンシャルの両方を検証
    if user.valid? && user_credential.valid? && user.save
      start_new_session_for user
      @user = user
      render :create, status: :created
    else
      @errors = user.errors.full_messages + user_credential.errors.full_messages
      render :error, status: :unprocessable_entity
    end
  end

  def show
    unless authenticated?
      render json: {
        success: false,
        error: "authentication_required",
        message: "ログインが必要です"
      }, status: :unauthorized
      return
    end

    @current_user = current_user
    render :show
  end

  private

  def user_credential_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
