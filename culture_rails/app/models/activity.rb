# == Schema Information
#
# Table name: activities
#
#  id            :bigint           not null, primary key
#  activity_type :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  article_id    :bigint           not null
#  user_id       :bigint           not null
#
# Indexes
#
#  idx_on_article_id_activity_type_created_at_2a8adb508a  (article_id,activity_type,created_at)
#  index_activities_on_activity_type                      (activity_type)
#  index_activities_on_article_id                         (article_id)
#  index_activities_on_user_article_type_time             (user_id,article_id,activity_type,created_at)
#  index_activities_on_user_id                            (user_id)
#  index_activities_on_user_id_and_article_id             (user_id,article_id) UNIQUE
#  index_activities_on_user_id_and_created_at             (user_id,created_at)
#
# Foreign Keys
#
#  fk_rails_...  (article_id => articles.id)
#  fk_rails_...  (user_id => users.id)
#
class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :article

  enum :activity_type, { good: 0, bad: 1 }

  # ユーザー・記事の組み合わせで一意
  validates :user_id, uniqueness: { scope: :article_id }

  # 記事読了を記録
  def self.mark_as_read(user, article)
    record = find_or_initialize_by(user: user, article: article)
    record.update!(read_at: Time.current)
    record
  end

  # 記事に対する評価を設定・切り替え
  def self.set_evaluation(user, article, activity_type)
    record = find_or_initialize_by(user: user, article: article)

    # 同じ評価を再度送信した場合は削除（none状態）
    if record.persisted? && record.activity_type == activity_type.to_s
      record.update!(activity_type: nil)
      return "none"
    end

    # 評価を設定
    record.update!(activity_type: activity_type)
    activity_type.to_s
  end

  # ユーザーの現在の評価状態を取得
  def self.current_evaluation_for_user(user, article)
    record = find_by(user: user, article: article)
    return "none" unless record&.activity_type

    record.activity_type
  end

  # 記事の評価統計を取得
  def self.article_stats(article)
    {
      good_count: where(article: article, activity_type: :good).count,
      bad_count: where(article: article, activity_type: :bad).count,
      read_count: where(article: article).where.not(read_at: nil).count
    }
  end

  # ユーザーが記事を読んだかどうか
  def read?
    read_at.present?
  end
end
