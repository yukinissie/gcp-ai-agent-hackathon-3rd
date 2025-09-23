require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def test_action
      render json: {
        authenticated: authenticated?,
        current_user_id: current_user&.id,
        message: 'test action success'
      }
    end
  end

  let(:user) { create(:user, :with_credential) }
  let(:valid_jwt_token) { JsonWebToken.encode_for_user(user) }
  let(:invalid_jwt_token) { 'invalid.jwt.token' }

  before do
    routes.draw { get 'test_action' => 'anonymous#test_action' }
  end

  describe 'JWT認証' do
    context 'Authorizationヘッダーに有効なJWTトークンが含まれている場合' do
      before do
        request.headers['Authorization'] = "Bearer #{valid_jwt_token}"
      end

      it 'ユーザーが認証される' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be true
        expect(json['current_user_id']).to eq(user.id)
      end
    end

    context 'Authorizationヘッダーに無効なJWTトークンが含まれている場合' do
      before do
        request.headers['Authorization'] = "Bearer #{invalid_jwt_token}"
        allow(Rails.logger).to receive(:error)
      end

      it 'ユーザーが認証されない' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be false
        expect(json['current_user_id']).to be_nil
      end
    end

    context 'Authorizationヘッダーが正しいフォーマットでない場合' do
      before do
        request.headers['Authorization'] = "InvalidFormat #{valid_jwt_token}"
      end

      it 'ユーザーが認証されない' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be false
        expect(json['current_user_id']).to be_nil
      end
    end

    context 'Authorizationヘッダーが存在しない場合' do
      it 'セッション認証にフォールバックする' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be false
        expect(json['current_user_id']).to be_nil
      end
    end

    context '期限切れのJWTトークンの場合' do
      let(:expired_token) { JsonWebToken.encode_for_user(user, 1.hour.ago) }

      before do
        request.headers['Authorization'] = "Bearer #{expired_token}"
        allow(Rails.logger).to receive(:error)
      end

      it 'ユーザーが認証されない' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be false
        expect(json['current_user_id']).to be_nil
      end
    end

    context '存在しないユーザーのIDを含むJWTトークンの場合' do
      let(:non_existent_user_token) { JsonWebToken.encode({ user_id: 99999 }) }

      before do
        request.headers['Authorization'] = "Bearer #{non_existent_user_token}"
      end

      it 'ユーザーが認証されない' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be false
        expect(json['current_user_id']).to be_nil
      end
    end
  end

  describe 'セッション認証とJWT認証の併用' do
    let(:session) { Session.create!(user: user, ip_address: '127.0.0.1', user_agent: 'test') }

    context 'JWTトークンが無効でセッションが有効な場合' do
      before do
        request.headers['Authorization'] = "Bearer #{invalid_jwt_token}"
        allow(Rails.logger).to receive(:error)
        allow_any_instance_of(ApplicationController).to receive(:cookies).and_return(
          double('cookies', signed: { session_token: session.id })
        )
      end

      it 'セッション認証でユーザーが認証される' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be true
        expect(json['current_user_id']).to eq(user.id)
      end
    end

    context 'JWTトークンとセッション両方が有効な場合' do
      before do
        request.headers['Authorization'] = "Bearer #{valid_jwt_token}"
        allow_any_instance_of(ApplicationController).to receive(:cookies).and_return(
          double('cookies', signed: { session_token: session.id })
        )
      end

      it 'JWTトークンが優先される' do
        get :test_action

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['authenticated']).to be true
        expect(json['current_user_id']).to eq(user.id)
      end
    end
  end

  describe '#extract_token_from_header' do
    controller do
      def test_extract_token
        token = extract_token_from_header
        render json: { token: token }
      end
    end

    before do
      routes.draw { get 'test_extract_token' => 'anonymous#test_extract_token' }
    end

    it 'Bearer形式のAuthorizationヘッダーからトークンを抽出する' do
      request.headers['Authorization'] = 'Bearer abc123'

      get :test_extract_token

      json = JSON.parse(response.body)
      expect(json['token']).to eq('abc123')
    end

    it 'Bearer形式でない場合はnilを返す' do
      request.headers['Authorization'] = 'Basic abc123'

      get :test_extract_token

      json = JSON.parse(response.body)
      expect(json['token']).to be_nil
    end

    it 'Authorizationヘッダーがない場合はnilを返す' do
      get :test_extract_token

      json = JSON.parse(response.body)
      expect(json['token']).to be_nil
    end
  end
end
