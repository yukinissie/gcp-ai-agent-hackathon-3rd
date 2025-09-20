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
          post '/api/v1/session', params: valid_params, as: :json
        }.to change(Session, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['user']['email_address']).to eq('existing@example.com')
        expect(json['data']['user']['authenticated']).to be true
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
          post '/api/v1/session', params: invalid_params, as: :json
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
        get '/api/v1/session', as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['authenticated']).to be true
        expect(json['user']['email_address']).to eq('test@example.com')
      end
    end

    context '未ログインユーザー' do
      it 'ログインしていない状態が返される' do
        get '/api/v1/session', as: :json

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
        delete '/api/v1/session', as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['message']).to eq('ログアウトしました')
      end
    end

    context '未ログインユーザー' do
      it '認証エラーが返される' do
        delete '/api/v1/session', as: :json

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to eq('authentication_required')
      end
    end
  end
end
