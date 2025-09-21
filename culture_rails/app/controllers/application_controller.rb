class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :null_session

  before_action :set_current_request_details
  before_action :authenticate

  private

  def set_current_request_details
    Current.request = request
  end

  def authenticate
    if session_record = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session_record
    end
  end

  def current_user
    Current.user
  end

  def authenticated?
    current_user&.authenticated? || false
  end

  def require_authentication
    unless authenticated?
      render json: {
        success: false,
        error: "authentication_required",
        message: "\u30ED\u30B0\u30A4\u30F3\u304C\u5FC5\u8981\u3067\u3059"
      }, status: :unauthorized
      return false
    end
    true
  end

  def start_new_session_for(user)
    user.sessions.create!(ip_address: request.remote_ip, user_agent: request.user_agent).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_token] = { value: session.id, httponly: true, same_site: :lax }
      # CSRF Token をCookieで設定
      cookies[:csrf_token] = { value: form_authenticity_token, same_site: :lax }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_token)
    cookies.delete(:csrf_token)
  end
end
