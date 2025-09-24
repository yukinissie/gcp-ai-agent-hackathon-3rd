class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  # Rails 8.0 API用: JSON リクエスト以外のみCSRF保護
  protect_from_forgery with: :null_session, if: -> { request.format != 'application/json' }

  before_action :set_current_request_details
  before_action :authenticate

  private

  def set_current_request_details
    Current.request = request
  end

  def authenticate
    # First try JWT token authentication
    if jwt_authenticate
      return
    end

    # Fallback to session-based authentication
    if session_record = Session.find_by_id(cookies.signed[:session_token])
      Current.session = session_record
    end

    # NextAuth.js Cookie-based authentication
    nextauth_cookies = [
      cookies['authjs.session-token'],
      cookies['__Secure-authjs.session-token'],
      cookies['next-auth.session-token'],
      cookies['__Secure-next-auth.session-token']
    ].compact

    if nextauth_cookies.any?
      # 暫定的に認証済みユーザー（ID: 2）として扱う
      # TODO: NextAuth.jsのセッションCookieを適切にデコードして実際のユーザーIDを取得
      if user = User.find_by(id: 2)
        Current.user = user
        return true
      end
    end
  end

  def jwt_authenticate
    token = extract_token_from_header
    puts "[JWT DEBUG] Token from header: #{token ? token[0..20] + '...' : 'nil'}"
    return false unless token

    begin
      user_id = JsonWebToken.user_id_from_token(token)
      puts "[JWT DEBUG] User ID from token: #{user_id}"
      return false unless user_id

      user = User.find_by(id: user_id)
      puts "[JWT DEBUG] User found: #{user ? "ID #{user.id}" : 'nil'}"

      if user&.authenticated?
        puts "[JWT DEBUG] User authenticated successfully: #{user.id}"
        Current.user = user
        return true
      else
        puts "[JWT DEBUG] User authentication failed"
      end
    rescue => e
      puts "[JWT DEBUG] JWT parsing error: #{e.message}"
    end

    false
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')

    auth_header.split(' ').last
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
