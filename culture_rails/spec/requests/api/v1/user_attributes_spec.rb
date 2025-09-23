require 'rails_helper'

RSpec.describe 'Api::V1::UserAttributes', type: :request do
  describe 'GET #show' do
    context '認証済みユーザーがIngredientを持つ時' do
      let!(:user) { create(:user) }
      let!(:ingredient) { create(:ingredient, :with_data, user: user) }
      let(:expected_response) do
        {
          id: ingredient.id,
          user_id: user.id,
          llm_payload: ingredient.llm_payload.deep_symbolize_keys,
          total_interactions: ingredient.total_interactions,
          diversity_score: ingredient.diversity_score.to_f,
          updated_at: ingredient.updated_at.iso8601(3)
        }
      end

      before do
        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:authenticated?).and_return(true)
      end

      it 'ユーザー属性が返ること' do
        get '/api/v1/user_attributes', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response).to eq(expected_response)
      end
    end

    context '認証済みユーザーがIngredientを持たない時' do
      let!(:user) { create(:user) }
      let!(:tag1) { create(:tag, :art, name: "AI") }
      let!(:tag2) { create(:tag, :tech, name: "デザイン") }
      let!(:article1) { create(:article, :published) }
      let!(:article2) { create(:article, :published) }

      before do
        # 記事にタグを付与
        create(:article_tagging, article: article1, tag: tag1)
        create(:article_tagging, article: article2, tag: tag2)

        # ユーザーの評価活動を作成
        create(:activity, user: user, article: article1, activity_type: :good)
        create(:activity, user: user, article: article2, activity_type: :bad)

        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:authenticated?).and_return(true)
      end

      it 'Ingredientが自動作成されてユーザー属性が返ること' do
        expect(user.ingredient).to be_nil

        get '/api/v1/user_attributes', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        # Ingredientが自動作成されたことを確認
        user.reload
        expect(user.ingredient).to be_present

        parsed_response = JSON.parse(response.body, symbolize_names: true)
        expect(parsed_response[:user_id]).to eq(user.id)
        expect(parsed_response[:total_interactions]).to eq(2)
        expect(parsed_response[:llm_payload]).to be_present
        expect(parsed_response[:llm_payload][:user_profile]).to be_present
        expect(parsed_response[:llm_payload][:tag_preferences]).to be_present
        expect(parsed_response[:llm_payload][:activity_patterns]).to be_present
        expect(parsed_response[:llm_payload][:metadata]).to be_present
      end
    end

    context '複雑なユーザー活動パターンの時' do
      let!(:user) { create(:user) }
      let!(:ai_tag) { create(:tag, :tech, name: "AI") }
      let!(:art_tag) { create(:tag, :art, name: "アート") }
      let!(:music_tag) { create(:tag, :music, name: "音楽") }

      let!(:ai_articles) { create_list(:article, 3, :published) }
      let!(:art_articles) { create_list(:article, 2, :published) }
      let!(:music_articles) { create_list(:article, 1, :published) }

      before do
        # タグ関連付け
        ai_articles.each { |article| create(:article_tagging, article: article, tag: ai_tag) }
        art_articles.each { |article| create(:article_tagging, article: article, tag: art_tag) }
        music_articles.each { |article| create(:article_tagging, article: article, tag: music_tag) }

        # AI記事への強い好み
        ai_articles.each { |article| create(:activity, user: user, article: article, activity_type: :good) }

        # アート記事への中程度の好み
        create(:activity, user: user, article: art_articles[0], activity_type: :good)
        create(:activity, user: user, article: art_articles[1], activity_type: :bad)

        # 音楽記事への嫌い
        create(:activity, user: user, article: music_articles[0], activity_type: :bad)

        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:authenticated?).and_return(true)
      end

      it '複雑な評価パターンが正しく分析されること' do
        get '/api/v1/user_attributes', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)

        # 基本統計の確認
        expect(parsed_response[:total_interactions]).to eq(6)
        expect(parsed_response[:diversity_score]).to be > 0.0

        # LLMペイロードの構造確認
        llm_payload = parsed_response[:llm_payload]

        # ユーザープロファイル確認
        user_profile = llm_payload[:user_profile]
        expect(user_profile[:total_interactions]).to eq(6)
        expect(user_profile[:personality_type]).to be_in([ 'tech_enthusiast', 'active_user', 'casual_reader' ])
        expect(user_profile[:evaluation_tendency]).to be_in([ 'positive', 'negative', 'balanced', 'neutral' ])

        # タグ好み確認
        tag_preferences = llm_payload[:tag_preferences]
        expect(tag_preferences).to be_an(Array)
        expect(tag_preferences.size).to be <= 10 # 上位10件まで

        # AIタグが最上位に来ることを確認
        ai_preference = tag_preferences.find { |pref| pref[:tag] == "AI" }
        expect(ai_preference).to be_present
        expect(ai_preference[:good_count]).to eq(3)
        expect(ai_preference[:bad_count]).to eq(0)
        expect(ai_preference[:preference_score]).to be > 0.8

        # 活動パターン確認
        activity_patterns = llm_payload[:activity_patterns]
        expect(activity_patterns[:good_bad_ratio]).to be > 1.0 # Goodが多い
        expect(activity_patterns[:strong_preferences]).to include("AI")
        expect(activity_patterns[:strong_dislikes]).to include("音楽")
      end
    end

    context '認証されていないユーザーがリクエストした時' do
      it '401エラーが返ること' do
        get '/api/v1/user_attributes', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'ユーザーに評価活動がない時' do
      let!(:user) { create(:user) }

      before do
        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:current_user).and_return(user)
        allow_any_instance_of(Api::V1::UserAttributesController).to receive(:authenticated?).and_return(true)
      end

      it 'デフォルト値でIngredientが作成されること' do
        get '/api/v1/user_attributes', headers: { 'Accept' => 'application/json' }
        expect(response).to have_http_status(:ok)
        assert_schema_conform(200)

        parsed_response = JSON.parse(response.body, symbolize_names: true)

        expect(parsed_response[:total_interactions]).to eq(0)
        expect(parsed_response[:diversity_score]).to eq(0.0)

        llm_payload = parsed_response[:llm_payload]
        expect(llm_payload[:user_profile][:personality_type]).to eq('casual_reader')
        expect(llm_payload[:tag_preferences]).to eq([])
        expect(llm_payload[:activity_patterns][:strong_preferences]).to eq([])
      end
    end
  end
end
