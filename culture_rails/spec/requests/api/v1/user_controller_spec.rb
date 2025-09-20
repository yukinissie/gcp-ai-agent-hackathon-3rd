require 'rails_helper'

RSpec.describe 'Api::V1::User', type: :request do
  describe 'POST /api/v1/user' do
    context '正しいパラメータでユーザー登録' do
      let(:valid_params) do
        {
          user: {
            email_address: 'newuser@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'ユーザーが作成され、セッションが開始される' do
        expect {
          post '/api/v1/user', params: valid_params, as: :json
        }.to change(User, :count).by(1)
         .and change(UserCredential, :count).by(1)
         .and change(Session, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['user']['email_address']).to eq('newuser@example.com')
        expect(json['data']['user']['authenticated']).to be true
        expect(json['data']['user']['human_id']).to be_present
      end
    end

    context '無効なパラメータでユーザー登録' do
      let(:invalid_params) do
        {
          user: {
            email_address: '',  # 空文字列でpresenceバリデーションをテスト
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      it 'エラーが返される' do
        expect {
          post '/api/v1/user', params: invalid_params, as: :json
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']).to be_present
      end
    end
  end

  describe 'GET /api/v1/user' do
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

      it 'ユーザー情報が返される' do
        get '/api/v1/user', as: :json

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['email_address']).to eq('test@example.com')
      end
    end

    context '未ログインユーザー' do
      it '認証エラーが返される' do
        get '/api/v1/user', as: :json

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['error']).to eq('authentication_required')
      end
    end
  end
end
