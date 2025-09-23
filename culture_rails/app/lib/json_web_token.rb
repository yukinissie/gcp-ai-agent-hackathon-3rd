class JsonWebToken
  SECRET_KEY = Rails.application.secret_key_base.to_s

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    payload[:iat] = Time.current.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def self.encode_for_user(user, exp = 24.hours.from_now)
    payload = {
      user_id: user.id,
      exp: exp.to_i,
      iat: Time.current.to_i
    }
    JWT.encode(payload, SECRET_KEY)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    Rails.logger.error "JWT Decode Error: #{e.message}"
    nil
  end

  def self.user_id_from_token(token)
    decoded = decode(token)
    decoded&.dig(:user_id)
  end
end
