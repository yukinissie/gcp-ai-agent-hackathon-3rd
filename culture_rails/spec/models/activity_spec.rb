require 'rails_helper'

RSpec.describe Activity, type: :model do
  let!(:user) { create(:user) }
  let!(:article) { create(:article) }

  describe '#mark_as_read' do
    context '記事を初回読了した場合' do
      it 'read_atが設定される' do
        expect {
          Activity.mark_as_read(user, article)
        }.to change { Activity.count }.by(1)

        activity = Activity.last
        expect(activity.read_at).to be_present
        expect(activity.user).to eq(user)
        expect(activity.article).to eq(article)
      end
    end

    context '既存のActivityレコードがある場合' do
      let!(:existing_activity) { create(:activity, user: user, article: article, activity_type: :good) }

      it 'read_atが更新される' do
        Activity.mark_as_read(user, article)
        existing_activity.reload
        expect(existing_activity.read_at).to be_present
      end

      it 'レコード数は増えない' do
        expect {
          Activity.mark_as_read(user, article)
        }.not_to change { Activity.count }
      end
    end
  end

  describe '#read?' do
    context 'read_atが設定されている場合' do
      let(:activity) { create(:activity, user: user, article: article, read_at: Time.current) }

      it 'trueを返す' do
        expect(activity.read?).to be true
      end
    end

    context 'read_atが設定されていない場合' do
      let(:activity) { create(:activity, user: user, article: article, read_at: nil) }

      it 'falseを返す' do
        expect(activity.read?).to be false
      end
    end
  end

  describe '.article_stats' do
    let!(:good_activity) { create(:activity, article: article, activity_type: :good, read_at: Time.current) }
    let!(:bad_activity) { create(:activity, article: article, activity_type: :bad, read_at: Time.current) }
    let!(:no_read_activity) { create(:activity, article: article, activity_type: :good, read_at: nil) }

    it '記事の統計情報に読了数を含む' do
      stats = Activity.article_stats(article)
      
      expect(stats[:good_count]).to eq(2)
      expect(stats[:bad_count]).to eq(1)
      expect(stats[:read_count]).to eq(2)
    end
  end
end