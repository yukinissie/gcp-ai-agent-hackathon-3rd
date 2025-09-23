class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :article

  enum :activity_type, { good: 0, bad: 1 }

  # ユーザー・記事の組み合わせで一意
  validates :user_id, uniqueness: { scope: :article_id }

  # 記事に対する評価を設定・切り替え
  def self.set_evaluation(user, article, activity_type)
    record = find_or_initialize_by(user: user, article: article)
    
    # 同じ評価を再度送信した場合は削除（none状態）
    if record.persisted? && record.activity_type == activity_type.to_s
      record.update!(activity_type: nil)
      return 'none'
    end
    
    # 評価を設定
    record.update!(activity_type: activity_type)
    activity_type.to_s
  end

  # ユーザーの現在の評価状態を取得
  def self.current_evaluation_for_user(user, article)
    record = find_by(user: user, article: article)
    return 'none' unless record&.activity_type
    
    record.activity_type
  end

  # 記事の評価統計を取得
  def self.article_stats(article)
    {
      good_count: where(article: article, activity_type: :good).count,
      bad_count: where(article: article, activity_type: :bad).count
    }
  end
end
