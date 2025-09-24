Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # API routes
  namespace :api do
    namespace :v1 do
      # 認証関連
      resource :sessions, only: [ :create, :show, :destroy ]
      resource :users, only: [ :create, :show ]

      # ユーザー属性関連
      resource :user_attributes, only: [ :show ]

      resources :ping, only: [ :index, :create ]

      # RSS フィード関連
      resources :feeds do
        member do
          post :fetch  # 手動フェッチ
        end

        collection do
          post :batch_fetch  # 全フィード一括フェッチ
        end
      end

      # 記事関連
      resources :articles do
        resources :activities, only: [ :create ]
      end
      resources :tags, only: [ :index ]

      # 検索履歴関連
      resources :tag_search_histories, only: [ :create ] do
        collection do
          get :articles
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
