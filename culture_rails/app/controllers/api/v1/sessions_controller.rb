class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate, only: [ :create ]
  before_action :require_authentication, only: [ :destroy ]

  def create
    if user_credential = UserCredential.authenticate_by(params.expect(:email_address, :password))
      start_new_session_for user_credential.user
      @user = user_credential.user
      render json: @user, status: :created
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def destroy
    terminate_session
    render json: { message: "Session terminated" }, status: :ok
  end

  def show
    @authenticated = authenticated?
    @current_user = current_user
    render json: @current_user, status: :ok
  end
end
