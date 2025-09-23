require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  let!(:user) { create(:user) }
  let!(:ingredient) { create(:ingredient, user: user) }

  describe 'associations' do
    it 'belongs to user' do
      expect(ingredient.user).to eq(user)
    end
  end

  describe 'validations' do
    it 'validates diversity_score range' do
      ingredient.diversity_score = -0.1
      expect(ingredient).not_to be_valid

      ingredient.diversity_score = 1.1
      expect(ingredient).not_to be_valid

      ingredient.diversity_score = 0.5
      expect(ingredient).to be_valid
    end

    it 'validates total_interactions is non-negative' do
      ingredient.total_interactions = -1
      expect(ingredient).not_to be_valid

      ingredient.total_interactions = 0
      expect(ingredient).to be_valid
    end
  end

  describe '#update_llm_payload!' do
    context 'アクティビティがないユーザー' do
      it 'デフォルト値でペイロードが生成される' do
        ingredient.update_llm_payload!

        expect(ingredient.total_interactions).to eq(0)
        expect(ingredient.diversity_score).to eq(0.0)
        expect(ingredient.llm_payload).to have_key('user_profile')
        expect(ingredient.llm_payload).to have_key('tag_preferences')
        expect(ingredient.llm_payload).to have_key('activity_patterns')
        expect(ingredient.llm_payload).to have_key('metadata')
      end
    end

    context 'アクティビティがあるユーザー' do
      let!(:tag_ai) { create(:tag, name: 'AI', category: 'tech') }
      let!(:tag_art) { create(:tag, name: 'art', category: 'art') }
      let!(:article1) { create(:article, title: 'AI記事') }
      let!(:article2) { create(:article, title: 'アート記事') }
      let!(:tagging1) { create(:article_tagging, article: article1, tag: tag_ai) }
      let!(:tagging2) { create(:article_tagging, article: article2, tag: tag_art) }

      before do
        # AI記事にgood評価（異なる記事を作成）
        ai_article2 = create(:article, title: 'AI記事2')
        create(:article_tagging, article: ai_article2, tag: tag_ai)
        create(:activity, user: user, article: article1, activity_type: :good)
        create(:activity, user: user, article: ai_article2, activity_type: :good)
        # アート記事にbad評価
        create(:activity, user: user, article: article2, activity_type: :bad)
      end

      it '正しい統計でペイロードが生成される' do
        ingredient.update_llm_payload!

        expect(ingredient.total_interactions).to eq(3)
        expect(ingredient.diversity_score).to be > 0.0

        user_profile = ingredient.llm_payload['user_profile']
        expect(user_profile['total_interactions']).to eq(3)
        expect(user_profile['evaluation_tendency']).to eq('balanced')

        tag_preferences = ingredient.llm_payload['tag_preferences']
        expect(tag_preferences).to be_an(Array)

        activity_patterns = ingredient.llm_payload['activity_patterns']
        expect(activity_patterns['good_bad_ratio']).to eq(2.0)
      end
    end
  end

  describe '#calculate_total_interactions' do
    it 'ユーザーの総アクティビティ数を返す' do
      article1 = create(:article)
      article2 = create(:article)
      create(:activity, user: user, article: article1, activity_type: :good)
      create(:activity, user: user, article: article2, activity_type: :bad)

      expect(ingredient.send(:calculate_total_interactions)).to eq(2)
    end
  end

  describe '#calculate_diversity_score' do
    context 'アクティビティがない場合' do
      it '0.0を返す' do
        expect(ingredient.send(:calculate_diversity_score)).to eq(0.0)
      end
    end

    context '1つのタグにのみアクティビティがある場合' do
      let!(:tag) { create(:tag, name: 'AI') }
      let!(:article) { create(:article) }
      let!(:tagging) { create(:article_tagging, article: article, tag: tag) }

      before do
        create(:activity, user: user, article: article, activity_type: :good)
      end

      it '0.0を返す（多様性なし）' do
        expect(ingredient.send(:calculate_diversity_score)).to eq(0.0)
      end
    end

    context '複数のタグにアクティビティがある場合' do
      let!(:tag1) { create(:tag, name: 'AI') }
      let!(:tag2) { create(:tag, name: 'art') }
      let!(:article1) { create(:article) }
      let!(:article2) { create(:article) }
      let!(:tagging1) { create(:article_tagging, article: article1, tag: tag1) }
      let!(:tagging2) { create(:article_tagging, article: article2, tag: tag2) }

      before do
        create(:activity, user: user, article: article1, activity_type: :good)
        create(:activity, user: user, article: article2, activity_type: :good)
      end

      it '0.0より大きい値を返す' do
        expect(ingredient.send(:calculate_diversity_score)).to be > 0.0
      end
    end
  end

  describe '#determine_personality_type' do
    context 'AI関連の評価が30%以上の場合' do
      let!(:tag_ai) { create(:tag, name: 'AI') }
      let!(:tag_other) { create(:tag, name: 'other') }
      let!(:article_ai) { create(:article) }
      let!(:article_other) { create(:article) }
      let!(:tagging_ai) { create(:article_tagging, article: article_ai, tag: tag_ai) }
      let!(:tagging_other) { create(:article_tagging, article: article_other, tag: tag_other) }

      before do
        # AI記事に3回good評価（異なる記事を作成）
        ai_article2 = create(:article)
        ai_article3 = create(:article)
        create(:article_tagging, article: ai_article2, tag: tag_ai)
        create(:article_tagging, article: ai_article3, tag: tag_ai)
        create(:activity, user: user, article: article_ai, activity_type: :good)
        create(:activity, user: user, article: ai_article2, activity_type: :good)
        create(:activity, user: user, article: ai_article3, activity_type: :good)
        # その他記事に1回good評価
        create(:activity, user: user, article: article_other, activity_type: :good)
      end

      it 'tech_enthusiastを返す' do
        expect(ingredient.send(:determine_personality_type)).to eq('tech_enthusiast')
      end
    end

    context 'good評価が20回以上の場合' do
      before do
        # 25個の異なる記事を作成
        25.times do |i|
          article = create(:article, title: "記事#{i}")
          create(:activity, user: user, article: article, activity_type: :good)
        end
      end

      it 'active_userを返す' do
        expect(ingredient.send(:determine_personality_type)).to eq('active_user')
      end
    end

    context 'その他の場合' do
      before do
        article = create(:article)
        create(:activity, user: user, article: article, activity_type: :good)
      end

      it 'casual_readerを返す' do
        expect(ingredient.send(:determine_personality_type)).to eq('casual_reader')
      end
    end
  end

  describe '#determine_evaluation_tendency' do
    context 'good評価が70%以上の場合' do
      before do
        # 8個のgood記事と2個のbad記事を作成
        8.times do |i|
          article = create(:article, title: "good記事#{i}")
          create(:activity, user: user, article: article, activity_type: :good)
        end
        2.times do |i|
          article = create(:article, title: "bad記事#{i}")
          create(:activity, user: user, article: article, activity_type: :bad)
        end
      end

      it 'positiveを返す' do
        expect(ingredient.send(:determine_evaluation_tendency)).to eq('positive')
      end
    end

    context 'good評価が30%未満の場合' do
      before do
        # 2個のgood記事と8個のbad記事を作成
        2.times do |i|
          article = create(:article, title: "good記事#{i}")
          create(:activity, user: user, article: article, activity_type: :good)
        end
        8.times do |i|
          article = create(:article, title: "bad記事#{i}")
          create(:activity, user: user, article: article, activity_type: :bad)
        end
      end

      it 'negativeを返す' do
        expect(ingredient.send(:determine_evaluation_tendency)).to eq('negative')
      end
    end

    context 'good評価が30%以上70%未満の場合' do
      before do
        # 5個のgood記事と5個のbad記事を作成
        5.times do |i|
          article = create(:article, title: "good記事#{i}")
          create(:activity, user: user, article: article, activity_type: :good)
        end
        5.times do |i|
          article = create(:article, title: "bad記事#{i}")
          create(:activity, user: user, article: article, activity_type: :bad)
        end
      end

      it 'balancedを返す' do
        expect(ingredient.send(:determine_evaluation_tendency)).to eq('balanced')
      end
    end

    context 'アクティビティがない場合' do
      it 'neutralを返す' do
        expect(ingredient.send(:determine_evaluation_tendency)).to eq('neutral')
      end
    end
  end

  describe '#calculate_preference_score' do
    it 'good評価のみの場合1.0を返す' do
      expect(ingredient.send(:calculate_preference_score, 10, 0)).to eq(1.0)
    end

    it 'bad評価のみの場合0.0を返す' do
      expect(ingredient.send(:calculate_preference_score, 0, 10)).to eq(0.0)
    end

    it '同数の場合0.5を返す' do
      expect(ingredient.send(:calculate_preference_score, 5, 5)).to eq(0.5)
    end

    it '評価がない場合0.5を返す' do
      expect(ingredient.send(:calculate_preference_score, 0, 0)).to eq(0.5)
    end
  end
end
