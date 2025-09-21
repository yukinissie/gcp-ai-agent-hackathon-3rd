require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let!(:user) { create(:user) }
  let!(:user_credential) do
    create(:user_credential,
      user: user,
      email_address: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    )
  end
  let(:email_address) { 'test@example.com' }
  let(:password) { 'password123' }
  let(:params) { { email_address: email_address, password: password } }

  describe 'POST /api/v1/session' do
    context '認証成功時' do
      it 'Set-Cookieヘッダーが返ること' do
        post '/api/v1/session', params: params, as: :json

        expect(response).to have_http_status(:created)
        
        # Set-Cookieヘッダーの内容を確認
        set_cookie_headers = response.headers['Set-Cookie']
        expect(set_cookie_headers).to include(match(/session_token=/))
        expect(set_cookie_headers).to include(match(/csrf_token=/))
      end

      it 'ユーザー情報が返ること' do
        post '/api/v1/session', params: params, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['data']['user']['email_address']).to eq('test@example.com')
      end
    end

    context '認証失敗時' do
      it 'Set-Cookieヘッダーが返らないこと' do
        post '/api/v1/session', params: { email_address: 'wrong@example.com', password: 'wrongpass' }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.headers['Set-Cookie']).to be_nil
      end
    end
  end
end
