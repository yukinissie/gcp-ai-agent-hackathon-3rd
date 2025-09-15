require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  describe 'POST #create' do
    context '正しいパスワードとメールアドレスを受け取った時' do
      let!(:user) { create(:user, password: 'password123') }
      let(:email) { user.email }
      let(:password) { 'password123' }
      let(:expected_response) do
        {
          success: true,
          data: {
            user: {
              id: user.id,
              name: user.name,
              email: user.email
            },
            token: "dummy_token_for_now"
          }
        }
      end

      it '正しいセッション情報が返ること' do
        post '/api/v1/session', params: { email: email, password: password }, as: :json
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end

    context '間違ったパスワードを受け取った時' do
      let!(:user) { create(:user, password: 'password123') }
      let(:email) { user.email }
      let(:password) { 'wrong_password' }
      let(:expected_response) do
        {
          success: false,
          error: "invalid_credentials",
          message: "メールアドレスまたはパスワードが正しくありません"
        }
      end

      it 'エラーメッセージが返ること' do
        post '/api/v1/session', params: { email: email, password: password }, as: :json
        expect(response).to have_http_status(:unauthorized)
        assert_schema_conform(401)

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'ログイン中のユーザーがログアウトした時' do
      let(:expected_response) do
        {
          success: true,
          message: "ログアウトしました"
        }
      end

      it 'セッションが削除されること' do
        delete '/api/v1/session', as: :json
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end
  end
end
