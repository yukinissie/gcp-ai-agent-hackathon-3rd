require 'rails_helper'

RSpec.describe 'Api::V1::Ping', type: :request do
  describe 'GET /api/v1/ping' do
    context 'Pingレコードが存在する場合' do
      let!(:ping) { Ping.create!(message: 'pong') }
      let(:expected_response) do
        {
          success: true,
          data: {
            id: ping.id,
            message: 'pong'
          }
        }
      end

      it '最新のPing情報が返ること' do
        get '/api/v1/ping', as: :json
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end

    context 'Pingレコードが存在しない場合' do
      let(:expected_response) do
        {
          success: false,
          error: 'not_found',
          message: 'リソースが見つかりません'
        }
      end

      it '404エラーが返ること' do
        get '/api/v1/ping', as: :json
        expect(response).to have_http_status(:not_found)
        assert_schema_conform(404)
        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end
  end

  describe 'POST /api/v1/ping' do
    context '正しいメッセージを送信した場合' do
      let(:message) { 'hello ping' }

      it 'Pingレコードが作成され、内容が返ること' do
        post '/api/v1/ping', params: { message: message }, as: :json
        expect(response).to have_http_status(:created)
        assert_schema_conform(201)

        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:success]).to eq(true)
        expect(body[:data][:message]).to eq(message)
        expect(body[:data][:id]).to be_a(Integer)

        # DBにレコードが保存されていることを確認
        created_ping = Ping.find(body[:data][:id])
        expect(created_ping.message).to eq(message)
      end
    end

    context 'メッセージが空の場合' do
      it '422エラーが返ること' do
        post '/api/v1/ping', params: { message: '' }, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        # Note: OpenAPIでバリデーションエラーのスキーマが定義されていれば追加
        assert_schema_conform(422)

        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:success]).to eq(false)
        expect(body[:error]).to eq('validation_error')
        expect(body[:message]).to include("can't be blank")
      end
    end

    context 'メッセージパラメータが送信されない場合' do
      it '422エラーが返ること' do
        post '/api/v1/ping', params: {}, as: :json
        expect(response).to have_http_status(:unprocessable_content)

        body = JSON.parse(response.body, symbolize_names: true)
        expect(body[:success]).to eq(false)
        expect(body[:error]).to eq('validation_error')
        expect(body[:message]).to include("can't be blank")
      end
    end
  end
end
