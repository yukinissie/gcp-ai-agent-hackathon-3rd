require 'rails_helper'

RSpec.describe 'API V1 Tags', type: :request do
  describe 'GET /api/v1/tags' do
    let!(:anime_tag) { create(:tag, name: 'Attack on Titan', category: 'anime') }
    let!(:book_tag) { create(:tag, name: 'One Piece', category: 'book') }

    it 'returns all tags' do
      get '/api/v1/tags'

      expect(response).to have_http_status(:ok)
      expect(response).to match_response_schema(200)

      json = JSON.parse(response.body)
      expect(json['tags']).to be_an(Array)
      expect(json['tags'].length).to eq(2)
    end

    it 'filters tags by category' do
      get '/api/v1/tags', params: { category: 'anime' }

      expect(response).to have_http_status(:ok)
      expect(response).to match_response_schema(200)

      json = JSON.parse(response.body)
      expect(json['tags'].length).to eq(1)
      expect(json['tags'][0]['category']).to eq('anime')
    end

    it 'validates request parameters against schema' do
      expect {
        assert_request_schema_confirm
      }.not_to raise_error
    end
  end

  describe 'POST /api/v1/tags' do
    let(:valid_params) do
      {
        name: 'Demon Slayer',
        category: 'anime',
        description: 'Popular anime series'
      }
    end

    it 'creates a new tag with valid parameters' do
      expect {
        post '/api/v1/tags', params: valid_params, as: :json
      }.to change(Tag, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(response).to match_response_schema(201)

      json = JSON.parse(response.body)
      expect(json['name']).to eq('Demon Slayer')
      expect(json['category']).to eq('anime')
    end

    it 'validates request body against schema' do
      expect {
        assert_request_schema_confirm
      }.not_to raise_error
    end
  end
end
