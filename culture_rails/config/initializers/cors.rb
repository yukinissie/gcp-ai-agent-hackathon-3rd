# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Next.jsアプリからのリクエストを許可
    origins [
      # Local development
      'http://localhost:3030', 'http://127.0.0.1:3030', 'https://localhost:3030',
      'http://localhost:3001', 'http://127.0.0.1:3001', 'https://localhost:3001',
      # Production
      'https://culture.yukinissie.com',
      # Staging
      'https://stg-culture.yukinissie.com'
    ]
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true # Cookieベース認証のため必要
  end

  # 開発環境での追加許可は上記の設定で十分
end