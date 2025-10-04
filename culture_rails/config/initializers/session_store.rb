# セッションストア設定
# JWTトークンの有効期限（24時間）と統一
Rails.application.config.session_store :cookie_store,
  key: '_culture_rails_session',
  expire_after: 24.hours,
  httponly: true,
  same_site: :lax,
  secure: Rails.env.production? # 本番環境ではHTTPS必須