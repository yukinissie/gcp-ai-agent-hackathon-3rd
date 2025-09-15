class ApplicationController < ActionController::API
  private

  def authenticate
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_user = User.find_by_token(token) if token
  end

  def require_authentication
    authenticate
    render json: { success: false, error: "Unauthorized" }, status: :unauthorized unless @current_user
  end

  attr_reader :current_user
end
