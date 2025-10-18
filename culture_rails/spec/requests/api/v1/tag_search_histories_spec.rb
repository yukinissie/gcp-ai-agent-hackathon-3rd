require 'rails_helper'

RSpec.describe "Api::V1::TagSearchHistories", type: :request do
  let!(:user) { create(:user, :with_credential) }
  let!(:articles) { create_list(:article, 5, published: true) }
  let(:jwt_token) { JsonWebToken.encode_for_user(user) }
  let(:headers) { { 'Authorization' => "Bearer #{jwt_token}" } }

  describe "POST /api/v1/tag_search_histories" do
    let(:article_ids) { articles.first(3).pluck(:id) }
    let(:valid_params) do
      {
        tag_search_history: {
          article_ids: article_ids
        }
      }
    end

    context "認証済みユーザーの場合" do
      context "正しいパラメータを受け取った時" do
        let(:expected_response) do
          {
            success: true
          }
        end

        it "検索履歴が保存され、正しいレスポンスが返ること" do
          expect {
            post '/api/v1/tag_search_histories', params: valid_params, headers: headers, as: :json
          }.to change(TagSearchHistory, :count).by(1)

          expect(response).to have_http_status(:created)
          expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)

          created_history = TagSearchHistory.last
          expect(created_history.user).to eq(user)
          expect(created_history.article_ids_array).to eq(article_ids)
        end

        it "OpenAPIスキーマに準拠すること" do
          post '/api/v1/tag_search_histories', params: valid_params, headers: headers, as: :json
          assert_schema_conform(201)
        end
      end

      context "空のarticle_idsを受け取った時" do
        let(:invalid_params) do
          {
            tag_search_history: {
              article_ids: []
            }
          }
        end

        it "バリデーションエラーが返ること" do
          post '/api/v1/tag_search_histories', params: invalid_params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body, symbolize_names: true)[:success]).to be false
          expect(JSON.parse(response.body, symbolize_names: true)[:errors]).to be_present
        end
      end
    end

    context "未認証ユーザーの場合" do
      it "認証エラーが返ること" do
        post '/api/v1/tag_search_histories', params: valid_params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/v1/tag_search_histories/articles" do
    context "認証済みユーザーの場合" do
      context "検索履歴が存在する時" do
        let!(:tag_search_history) do
          create(:tag_search_history, user: user, article_ids: articles.first(3).pluck(:id))
        end

        let(:expected_response) do
          {
            success: true,
            data: {
              articles: articles.first(3).map do |article|
                {
                  id: article.id,
                  title: article.title,
                  summary: article.summary,
                  author: article.author,
                  content: article.content,
                  published_at: article.published_at&.iso8601,
                  tags: article.tags.pluck(:name)
                }
              end
            }
          }
        end

        it "最新の検索履歴から記事一覧が返ること" do
          get '/api/v1/tag_search_histories/articles', headers: headers, as: :json

          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:success]).to be true
          expect(response_body[:data][:articles].size).to eq(3)

          # 順序も確認
          returned_ids = response_body[:data][:articles].map { |a| a[:id] }
          expect(returned_ids).to eq(articles.first(3).pluck(:id))
        end

        it "OpenAPIスキーマに準拠すること" do
          get '/api/v1/tag_search_histories/articles', headers: headers, as: :json
          assert_schema_conform(200)
        end
      end

      context "複数の検索履歴がある時" do
        let!(:old_history) do
          create(:tag_search_history,
                 user: user,
                 article_ids: articles.last(2).pluck(:id),
                 created_at: 1.day.ago)
        end
        let!(:new_history) do
          create(:tag_search_history,
                 user: user,
                 article_ids: articles.first(3).pluck(:id),
                 created_at: 1.hour.ago)
        end

        it "最新の検索履歴が返ること" do
          get '/api/v1/tag_search_histories/articles', headers: headers, as: :json

          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body, symbolize_names: true)
          returned_ids = response_body[:data][:articles].map { |a| a[:id] }
          expect(returned_ids).to eq(articles.first(3).pluck(:id))
        end
      end

      context "検索履歴が存在しない時" do
        it "空配列が返ること" do
          get '/api/v1/tag_search_histories/articles', headers: headers, as: :json

          expect(response).to have_http_status(:ok)
          response_body = JSON.parse(response.body, symbolize_names: true)
          expect(response_body[:success]).to be true
          expect(response_body[:data][:articles]).to eq([])
        end

        it "OpenAPIスキーマに準拠すること" do
          get '/api/v1/tag_search_histories/articles', headers: headers, as: :json
          assert_schema_conform(200)
        end
      end
    end

    context "未認証ユーザーの場合" do
      it "認証エラーが返ること" do
        get '/api/v1/tag_search_histories/articles', as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
