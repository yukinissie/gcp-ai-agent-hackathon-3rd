class Api::V1::SessionsController < Api::V1::BaseController
  def create
    @user = login(params[:email], params[:password])

    if @user
      render :create, status: :ok
    else
      render :error, status: :unauthorized
    end
  end

  def destroy
    logout
    render :destroy, status: :ok
  end
end
