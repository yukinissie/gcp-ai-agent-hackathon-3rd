class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate, only: [ :create ]

  def create
    user = User.new
    user_credential = user.build_user_credential(user_credential_params)

    if user.save
      start_new_session_for user
      @user = user
      render "create", status: :created
    else
      @errors = user.errors.full_messages + user_credential.errors.full_messages
      render "error", status: :unprocessable_entity
    end
  end

  def show
    @current_user = current_user
    render "show"
  end

  private

  def user_credential_params
    params.expect(user: [ :email_address, :password, :password_confirmation ])
  end
end
