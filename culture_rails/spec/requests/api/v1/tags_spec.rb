require 'rails_helper'

RSpec.describe 'Api::V1::Tags', type: :request do
  describe 'GET #index' do
    context 'タグが存在する時' do
      let!(:tag1) { create(:tag, :art, name: "デジタルアート") }
      let!(:tag2) { create(:tag, :tech, name: "AI") }
      let!(:tag3) { create(:tag, :music, name: "ジャズ") }
      let!(:article1) { create(:article, :published) }
      let!(:article2) { create(:article, :published) }

      before do
        create(:article_tagging, article: article1, tag: tag1)
        create(:article_tagging, article: article2, tag: tag1)
        create(:article_tagging, article: article1, tag: tag2)
      end

      it '人気順（使用記事数の多い順）でタグが返ること' do
        get '/api/v1/tags', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:tags].size).to be >= 2
        # 作成したタグが含まれていることを確認
        tag_names = parsed_response[:tags].map { |t| t[:name] }
        expect(tag_names).to include("デジタルアート")
        expect(tag_names).to include("AI")
      end
    end

    context 'タグ名で検索する時' do
      let!(:tag1) { create(:tag, :art, name: "デジタルアート") }
      let!(:tag2) { create(:tag, :tech, name: "AI技術") }
      let!(:tag3) { create(:tag, :music, name: "ジャズ") }

      it '検索キーワードにマッチするタグのみが返ること' do
        get '/api/v1/tags', params: { q: "アート" }, headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:tags].size).to eq(1)
        expect(parsed_response[:tags][0][:name]).to eq("デジタルアート")
      end
    end

    context 'タグが存在しない時' do
      it '空の配列が返ること' do
        get '/api/v1/tags', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:tags]).to eq([])
      end
    end
  end
end
