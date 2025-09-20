class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate, only: [ :create ]
  before_action :require_authentication, only: [ :destroy ]

  def create
    email_address = params.expect(:email_address)
    password = params.expect(:password)

    if user_credential = UserCredential.authenticate_by(email_address: email_address, password: password)
      start_new_session_for user_credential.user

      # Set-Cookieヘッダーを直接設定（APIモード対応）
      response.set_header(
        "Set-Cookie",
        "session_token=#{Current.session.id}; Path=/; HttpOnly; SameSite=Lax"
      )

      render json: {
        success: true,
        data: {
          user: {
            id: user_credential.user.id,
            email_address: user_credential.email_address,
            created_at: user_credential.user.created_at
          }
        }
      }, status: :created
    else
      render json: {
        success: false,
        error: "invalid_credentials",
        message: "Email address or password is incorrect"
      }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    render :destroy, status: :ok
  end

  def show
    @authenticated = authenticated?
    @current_user = current_user
    render :show, status: :ok
  end
end
