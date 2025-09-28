require 'rails_helper'

RSpec.describe TagSearchHistory, type: :model do
  describe '関連' do
    it 'ユーザーに属していること' do
      tag_search_history = build(:tag_search_history)
      expect(tag_search_history).to respond_to(:user)
      expect(tag_search_history.user).to be_a(User)
    end
  end

  describe 'バリデーション' do
    it 'article_idsが必須であること' do
      tag_search_history = build(:tag_search_history, article_ids: nil)
      expect(tag_search_history).not_to be_valid
      expect(tag_search_history.errors[:article_ids]).to include("can't be blank")
    end
  end



  describe '#article_ids_array' do
    context 'article_idsがjsonb配列の場合' do
      let(:tag_search_history) { build(:tag_search_history, article_ids: [ 1, 2, 3 ]) }

      it '配列がそのまま返されること' do
        expect(tag_search_history.article_ids_array).to eq([ 1, 2, 3 ])
      end
    end

    context 'article_idsがnilの場合' do
      let(:tag_search_history) { build(:tag_search_history, article_ids: nil) }

      it '空の配列が返されること' do
        expect(tag_search_history.article_ids_array).to eq([])
      end
    end
  end

  describe '#article_ids_array=' do
    let(:tag_search_history) { build(:tag_search_history) }

    it '配列がそのまま設定されること' do
      tag_search_history.article_ids_array = [ 4, 5, 6 ]
      expect(tag_search_history.article_ids).to eq([ 4, 5, 6 ])
    end

    it '空の配列が設定できること' do
      tag_search_history.article_ids_array = []
      expect(tag_search_history.article_ids).to eq([])
    end
  end

  describe 'ファクトリ' do
    it '有効なファクトリが作成できること' do
      tag_search_history = build(:tag_search_history)
      expect(tag_search_history).to be_valid
    end

    it 'ユーザーとの関連が正しく設定されること' do
      user = create(:user)
      tag_search_history = create(:tag_search_history, user: user)
      expect(tag_search_history.user).to eq(user)
      expect(user.tag_search_histories).to include(tag_search_history)
    end
  end

  describe 'スコープとクエリ' do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let!(:old_history) do
      create(:tag_search_history, user: user1, created_at: 2.days.ago)
    end
    let!(:recent_history) do
      create(:tag_search_history, user: user1, created_at: 1.hour.ago)
    end
    let!(:other_user_history) do
      create(:tag_search_history, user: user2, created_at: 30.minutes.ago)
    end

    it '特定ユーザーの最新の履歴が取得できること' do
      latest = user1.tag_search_histories.order(created_at: :desc).first
      expect(latest).to eq(recent_history)
    end

    it 'ユーザー別に履歴が分離されていること' do
      expect(user1.tag_search_histories).to contain_exactly(old_history, recent_history)
      expect(user2.tag_search_histories).to contain_exactly(other_user_history)
    end
  end
end
