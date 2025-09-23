require 'rails_helper'

RSpec.describe 'Api::V1::Activities', type: :request do
  let!(:user) { create(:user) }
  let!(:article) { create(:article, published: true) }

  before do
    # セッションベース認証のモック
    session = create(:session, user: user)
    allow(Current).to receive(:session).and_return(session)
    allow_any_instance_of(ApplicationController).to receive(:authenticated?).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    # require_authenticationをスキップ
    allow_any_instance_of(ApplicationController).to receive(:require_authentication).and_return(true)
  end

  describe 'POST /api/v1/articles/:article_id/activities' do
    context 'goodパラメータを受け取った時' do
      let(:activity_type) { 'good' }

      it 'good評価が設定されること' do
        post "/api/v1/articles/#{article.id}/activities",
             params: { activity_type: activity_type },
             as: :json

        expect(response).to have_http_status(:created)
        assert_schema_conform(201)

        response_body = JSON.parse(response.body)
        expect(response_body['current_evaluation']).to eq('good')
        expect(response_body['article']['good_count']).to eq(1)
        expect(response_body['article']['bad_count']).to eq(0)
      end

      context '既にbad評価が存在する場合' do
        let!(:existing_bad_activity) { create(:bad_activity, user: user, article: article) }

        it 'badからgoodに切り替わること' do
          post "/api/v1/articles/#{article.id}/activities",
               params: { activity_type: activity_type },
               as: :json

          expect(response).to have_http_status(:created)

          response_body = JSON.parse(response.body)
          expect(response_body['current_evaluation']).to eq('good')

          # データベースで確認
          activity = Activity.find_by(user: user, article: article)
          expect(activity.activity_type).to eq('good')
        end
      end

      context '既にgood評価が存在する場合' do
        let!(:existing_good_activity) { create(:good_activity, user: user, article: article) }

        it 'good評価が削除されnoneになること' do
          post "/api/v1/articles/#{article.id}/activities",
               params: { activity_type: activity_type },
               as: :json

          expect(response).to have_http_status(:created)

          response_body = JSON.parse(response.body)
          expect(response_body['current_evaluation']).to eq('none')

          # データベースで確認
          activity = Activity.find_by(user: user, article: article)
          expect(activity.activity_type).to be_nil
        end
      end
    end

    context 'badパラメータを受け取った時' do
      let(:activity_type) { 'bad' }

      it 'bad評価が設定されること' do
        post "/api/v1/articles/#{article.id}/activities",
             params: { activity_type: activity_type },
             as: :json

        expect(response).to have_http_status(:created)
        assert_schema_conform(201)

        response_body = JSON.parse(response.body)
        expect(response_body['current_evaluation']).to eq('bad')
        expect(response_body['article']['good_count']).to eq(0)
        expect(response_body['article']['bad_count']).to eq(1)
      end

      context '既にgood評価が存在する場合' do
        let!(:existing_good_activity) { create(:good_activity, user: user, article: article) }

        it 'goodからbadに切り替わること' do
          post "/api/v1/articles/#{article.id}/activities",
               params: { activity_type: activity_type },
               as: :json

          expect(response).to have_http_status(:created)

          response_body = JSON.parse(response.body)
          expect(response_body['current_evaluation']).to eq('bad')

          # データベースで確認
          activity = Activity.find_by(user: user, article: article)
          expect(activity.activity_type).to eq('bad')
        end
      end

      context '既にbad評価が存在する場合' do
        let!(:existing_bad_activity) { create(:bad_activity, user: user, article: article) }

        it 'bad評価が削除されnoneになること' do
          post "/api/v1/articles/#{article.id}/activities",
               params: { activity_type: activity_type },
               as: :json

          expect(response).to have_http_status(:created)

          response_body = JSON.parse(response.body)
          expect(response_body['current_evaluation']).to eq('none')

          # データベースで確認
          activity = Activity.find_by(user: user, article: article)
          expect(activity.activity_type).to be_nil
        end
      end
    end

    context '無効なactivity_typeを受け取った時' do
      let(:activity_type) { 'invalid' }

      it 'エラーが返されること' do
        post "/api/v1/articles/#{article.id}/activities",
             params: { activity_type: activity_type },
             as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be false
        expect(response_body['error']).to eq('invalid_parameter')
      end
    end

    context '存在しない記事IDを指定した時' do
      it 'not_foundエラーが返されること' do
        post "/api/v1/articles/99999/activities",
             params: { activity_type: 'good' },
             as: :json

        expect(response).to have_http_status(:not_found)

        response_body = JSON.parse(response.body)
        expect(response_body['success']).to be false
        expect(response_body['error']).to eq('not_found')
      end
    end
  end
end
