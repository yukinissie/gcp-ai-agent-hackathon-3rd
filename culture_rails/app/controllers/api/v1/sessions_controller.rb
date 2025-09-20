class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate, only: [ :create ]
  before_action :require_authentication, only: [ :destroy ]

  def create
    email_address = params.expect(:email_address)
    password = params.expect(:password)

    if user_credential = UserCredential.authenticate_by(email_address: email_address, password: password)
      start_new_session_for user_credential.user
      @user = user_credential.user
      render :create, status: :created
    else
      @error = "Invalid email or password"
      render :error, status: :unauthorized
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
