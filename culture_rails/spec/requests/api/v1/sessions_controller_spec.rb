require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  describe 'POST /api/v1/session' do
    context '既存ユーザーでログイン' do
      let!(:user) do
        u = User.new
        u.build_user_credential(
          email_address: 'existing@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        u.save!
        u
      end

      let(:valid_params) do
        {
          email_address: 'existing@example.com',
          password: 'password123'
        }
      end

      it 'ログインが成功しセッションが作成される' do
        expect {
          post '/api/v1/sessions', params: valid_params, as: :json
        }.to change(Session, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['user']['email_address']).to eq('existing@example.com')
        expect(json['data']['user']['authenticated']).to be true
      end

      it 'ログイン成功時にJWTトークンが返される' do
        post '/api/v1/sessions', params: valid_params, as: :json

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['token']).to be_present

        # トークンからuser_idを抽出して検証
        token = json['data']['token']
        decoded_user_id = JsonWebToken.user_id_from_token(token)
        expect(decoded_user_id).to eq(user.id)
      end

      it 'JWTトークンに有効期限が設定されている' do
        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        post '/api/v1/sessions', params: valid_params, as: :json

        json = JSON.parse(response.body)
        token = json['data']['token']
        decoded = JsonWebToken.decode(token)

        expect(decoded[:iat]).to eq(freeze_time.to_i)
        expect(decoded[:exp]).to eq((freeze_time + 24.hours).to_i)
      end
    end

    context '間違ったパスワードでログイン' do
      let!(:user) do
        u = User.new
        u.build_user_credential(
          email_address: 'existing@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        u.save!
        u
      end

      let(:invalid_params) do
        {
          email_address: 'existing@example.com',
          password: 'wrongpassword'
        }
      end

      it 'ログインが失敗する' do
        expect {
          post '/api/v1/sessions', params: invalid_params, as: :json
        }.not_to change(Session, :count)

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to eq('invalid_credentials')
      end
    end
  end

  describe 'GET /api/v1/session' do
    context 'ログイン済みユーザー' do
      let(:user) do
        u = User.new
        u.build_user_credential(
          email_address: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        u.save!
        u
      end
      let(:session) { Session.create!(user: user, ip_address: '127.0.0.1', user_agent: 'test') }

      before do
        # セッショントークンをCookieに設定
        allow_any_instance_of(ApplicationController).to receive(:cookies).and_return(
          double('cookies', signed: { session_token: session.id })
        )
      end

      it 'セッション情報が返される' do
        get '/api/v1/sessions', as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['authenticated']).to be true
        expect(json['user']['email_address']).to eq('test@example.com')
      end
    end

    context '未ログインユーザー' do
      it 'ログインしていない状態が返される' do
        get '/api/v1/sessions', as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['authenticated']).to be false
        expect(json['user']).to be_nil
      end
    end
  end

  describe 'DELETE /api/v1/session' do
    context 'ログイン済みユーザー' do
      let(:user) do
        u = User.new
        u.build_user_credential(
          email_address: 'test@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        )
        u.save!
        u
      end
      let(:session) { Session.create!(user: user, ip_address: '127.0.0.1', user_agent: 'test') }

      before do
        # セッショントークンをCookieに設定
        allow_any_instance_of(ApplicationController).to receive(:cookies).and_return(
          double('cookies', signed: { session_token: session.id }, delete: true)
        )
      end

      it 'ログアウトが成功する' do
        delete '/api/v1/sessions', as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['message']).to eq('ログアウトしました')
      end
    end

    context '未ログインユーザー' do
      it '認証エラーが返される' do
        delete '/api/v1/sessions', as: :json

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to eq('authentication_required')
      end
    end
  end
end
