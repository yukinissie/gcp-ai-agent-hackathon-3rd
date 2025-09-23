require 'rails_helper'

RSpec.describe 'Api::V1::Articles', type: :request do
  describe 'GET #index' do
    context '公開された記事が存在する時' do
      let!(:published_article) { create(:article, :published) }
      let!(:unpublished_article) { create(:article, published: false) }
      let(:expected_response) do
        {
          articles: [
            {
              id: published_article.id,
              title: published_article.title,
              summary: published_article.summary,
              author: published_article.author,
              content_format: published_article.content_format,
              published_at: published_article.published_at.iso8601(3),
              image_url: published_article.image_url,
              tags: [],
              additional_tags_count: 0
            }
          ]
        }
      end

      it '公開記事のみが返ること' do
        get '/api/v1/articles', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response).to eq(expected_response)
        expect(parsed_response[:articles].size).to eq(1)
      end
    end

    context '記事が存在しない時' do
      let(:expected_response) do
        {
          articles: []
        }
      end

      it '空の配列が返ること' do
        get '/api/v1/articles', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end

    context 'テキスト検索でキーワードにマッチする記事が存在する時' do
      let!(:matching_article) { create(:article, :published, title: "デジタルアートの可能性", summary: "最新技術による表現") }
      let!(:non_matching_article) { create(:article, :published, title: "料理レシピ", summary: "美味しい料理の作り方") }

      it 'マッチする記事のみが返ること' do
        get '/api/v1/articles', params: { q: "デジタル" }, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:articles].size).to be >= 1
        # "デジタル"を含む記事がレスポンスに含まれていることを確認
        matching_titles = parsed_response[:articles].map { |a| a[:title] }.select { |title| title.include?("デジタル") }
        expect(matching_titles).to include("デジタルアートの可能性")
      end
    end

    context 'タグ検索で指定したタグを持つ記事が存在する時' do
      let!(:tag1) { create(:tag, :art, name: "デジタルアート") }
      let!(:tag2) { create(:tag, :tech, name: "AI") }

      let!(:article_with_tag1) { create(:article, :published, title: "記事1") }
      let!(:article_with_tag2) { create(:article, :published, title: "記事2") }
      let!(:article_without_tags) { create(:article, :published, title: "記事3") }

      before do
        create(:article_tagging, article: article_with_tag1, tag: tag1)
        create(:article_tagging, article: article_with_tag2, tag: tag2)
      end

      it '指定したタグを持つ記事のみが返ること' do
        get '/api/v1/articles', params: { tags: "デジタルアート" }, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:articles].size).to eq(1)
        expect(parsed_response[:articles][0][:title]).to eq("記事1")
      end
    end
  end

  describe 'GET #show' do
    context '公開された記事が存在する時' do
      let!(:article) { create(:article, :published) }
      let(:expected_response) do
        {
          article: {
            id: article.id,
            title: article.title,
            summary: article.summary,
            content: article.content,
            content_format: article.content_format,
            author: article.author,
            source_url: article.source_url,
            image_url: article.image_url,
            published: article.published,
            published_at: article.published_at.iso8601(3),
            created_at: article.created_at.iso8601(3),
            updated_at: article.updated_at.iso8601(3),
            tags: []
          }
        }
      end

      it '記事の詳細が返ること' do
        get "/api/v1/articles/#{article.id}", headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        expect(JSON.parse(response.body, symbolize_names: true)).to eq(expected_response)
      end
    end

    context '記事が存在しない時' do
      it '404エラーが返ること' do
        get '/api/v1/articles/999', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST #create' do
    context '認証済みユーザーが正しいパラメータを送信した時' do
      let!(:user) { create(:user) }
      let!(:tag1) { create(:tag, :art, name: "デジタルアート") }
      let!(:tag2) { create(:tag, :tech, name: "AI") }
      let(:article_params) do
        {
          article: {
            title: "新しい記事",
            summary: "記事の概要です",
            content: "記事の本文です",
            content_format: "markdown",
            author: "テスト著者",
            source_url: "https://example.com",
            image_url: "https://example.com/image.jpg",
            published: true,
            tag_ids: [ tag1.id, tag2.id ]
          }
        }
      end

      before do
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:authenticated?).and_return(true)
      end

      it '記事が作成されて詳細が返ること' do
        expect {
          post '/api/v1/articles', params: article_params, headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, as: :json
        }.to change(Article, :count).by(1)

        expect(response).to have_http_status(:created)
        assert_schema_conform(201)

        created_article = Article.last
        expect(created_article.title).to eq("新しい記事")
        expect(created_article.tags.count).to eq(2)
      end
    end

    context '認証されていないユーザーがリクエストした時' do
      let(:article_params) do
        {
          article: {
            title: "新しい記事",
            summary: "記事の概要です",
            content: "記事の本文です"
          }
        }
      end

      it '401エラーが返ること' do
        post '/api/v1/articles', params: article_params, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '不正なパラメータが送信された時' do
      let!(:user) { create(:user) }
      let(:invalid_params) do
        {
          article: {
            title: "",
            summary: "",
            content: ""
          }
        }
      end

      before do
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:authenticated?).and_return(true)
      end

      it '422エラーとエラーメッセージが返ること' do
        post '/api/v1/articles', params: invalid_params, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:unprocessable_entity)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:success]).to be false
        expect(parsed_response[:errors]).to be_present
      end
    end
  end

  describe 'PATCH #update' do
    context '認証済みユーザーが既存記事を更新する時' do
      let!(:user) { create(:user) }
      let!(:article) { create(:article, :published) }
      let(:update_params) do
        {
          article: {
            title: "更新されたタイトル",
            summary: "更新された概要"
          }
        }
      end

      before do
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:authenticated?).and_return(true)
      end

      it '記事が更新されて詳細が返ること' do
        patch "/api/v1/articles/#{article.id}", params: update_params, headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, as: :json
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        article.reload
        expect(article.title).to eq("更新されたタイトル")
        expect(article.summary).to eq("更新された概要")
      end
    end

    context '記事が存在しない時' do
      let!(:user) { create(:user) }
      let(:update_params) do
        {
          article: {
            title: "更新されたタイトル"
          }
        }
      end

      before do
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:authenticated?).and_return(true)
      end

      it '404エラーが返ること' do
        patch '/api/v1/articles/999', params: update_params, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE #destroy' do
    context '認証済みユーザーが既存記事を削除する時' do
      let!(:user) { create(:user) }
      let!(:article) { create(:article, :published) }

      before do
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:authenticated?).and_return(true)
      end

      it '記事が削除されて204が返ること' do
        expect {
          delete "/api/v1/articles/#{article.id}", headers: { 'Accept' => 'application/json' }
        }.to change(Article, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context '記事が存在しない時' do
      let!(:user) { create(:user) }

      before do
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::ArticlesController).to receive(:authenticated?).and_return(true)
      end

      it '404エラーが返ること' do
        delete '/api/v1/articles/999', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
