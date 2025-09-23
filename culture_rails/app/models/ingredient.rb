require "set"

class Ingredient < ApplicationRecord
  belongs_to :user

  validates :diversity_score,
    presence: true,
    numericality: {
      greater_than_or_equal_to: 0.0,
      less_than_or_equal_to: 1.0
    }

  validates :total_interactions,
    presence: true,
    numericality: { greater_than_or_equal_to: 0 }


  # LLMペイロード更新のメインメソッド
  def update_llm_payload!
    payload = generate_llm_payload

    update!(
      llm_payload: payload,
      total_interactions: calculate_total_interactions,
      diversity_score: calculate_diversity_score
    )
  end

  private

  # LLMペイロードの生成
  def generate_llm_payload
    {
      # ユーザーの基本属性情報（性格タイプ、活動量、評価傾向など）
      user_profile: build_user_profile,
      # タグ別の興味度ランキング（好み度スコア、重み付けを含む上位10タグ）
      tag_preferences: build_tag_preferences,
      # ユーザーの行動パターン分析（評価比率、活動期間、強い好み嫌いなど）
      activity_patterns: build_activity_patterns,
      # LLM用のメタ情報（統計値の重複、更新日時など）
      metadata: build_metadata
    }
  end

  # ユーザープロフィール構築
  def build_user_profile
    {
      # ユーザータイプ (tech_enthusiast: 技術系好き, active_user: 活発, casual_reader: 一般)
      personality_type: determine_personality_type,
      # 総評価数 (good + bad の合計アクション数)
      total_interactions: calculate_total_interactions,
      # 興味の多様性 (0.0-1.0, 高いほど幅広い興味, シャノンエントロピーベース)
      diversity_score: calculate_diversity_score,
      # 評価傾向 (positive: 好意的, negative: 批判的, balanced: バランス型, neutral: 評価なし)
      evaluation_tendency: determine_evaluation_tendency
    }
  end

  # タグ別設定構築
  def build_tag_preferences
    tag_stats = calculate_tag_statistics
    total_interactions = calculate_total_interactions.to_f

    return [] if total_interactions == 0

    tag_stats.map do |tag_name, stats|
      {
        # タグ名 (記事に付与されているタグの名前)
        tag: tag_name,
        # このタグでのGood評価数
        good_count: stats[:good_count],
        # このタグでのBad評価数
        bad_count: stats[:bad_count],
        # このタグでの総評価数 (good + bad)
        total_interactions: stats[:total_interactions],
        # 好み度スコア (0.0-1.0, 1.0に近いほど好き, 0.0に近いほど嫌い, 0.5は中立)
        preference_score: calculate_preference_score(stats[:good_count], stats[:bad_count]),
        # 全体に占める重み (このタグが全興味の何%を占めるか, 0.0-1.0)
        weight: (stats[:total_interactions] / total_interactions).round(3)
      }
    end.sort_by { |t| -t[:preference_score] }.first(10)
  end

  # 活動パターン構築
  def build_activity_patterns
    good_total = user.activities.good.count
    bad_total = user.activities.bad.count

    {
      # Good評価とBad評価の比率 (高いほどポジティブ, 1.0で同数, 0に近いほど批判的)
      good_bad_ratio: bad_total > 0 ? (good_total.to_f / bad_total).round(2) : good_total.to_f,
      # 最も活発な期間 (recent: 最近活発, historical: 過去に活発, consistent: 一定)
      most_active_period: determine_active_period,
      # 強い好みタグ (preference_score > 0.8 かつ十分な評価数があるタグ, 最大5個)
      strong_preferences: find_strong_preferences,
      # 強い嫌いタグ (preference_score < 0.2 かつBad評価優勢なタグ, 最大5個)
      strong_dislikes: find_strong_dislikes,
      # 最近新しく興味を持ったタグ (7日以内に初めてGood評価したタグ, 最大3個)
      recent_interests: find_recent_interests
    }
  end

  # メタデータ構築
  def build_metadata
    {
      # 総評価数 (user_profileと同じ値, LLM用の参照用重複データ)
      total_interactions: calculate_total_interactions,
      # 多様性スコア (user_profileと同じ値, LLM用の参照用重複データ)
      diversity_score: calculate_diversity_score,
      # データ更新日時 (このペイロードが生成された日時, ISO8601形式)
      updated_at: Time.current.iso8601
    }
  end

  # 総インタラクション数計算
  def calculate_total_interactions
    user.activities.count
  end

  # 多様性スコア計算（シャノンエントロピー）
  def calculate_diversity_score
    activities_with_tags = user.activities.includes(article: :tags)
    tag_counts = Hash.new(0)

    activities_with_tags.each do |activity|
      activity.article.tags.each do |tag|
        tag_counts[tag.name] += 1
      end
    end

    return 0.0 if tag_counts.empty?

    total = tag_counts.values.sum.to_f
    entropy = tag_counts.values.map do |count|
      probability = count / total
      -probability * Math.log2(probability)
    end.sum

    max_entropy = Math.log2(tag_counts.size)
    max_entropy > 0 ? (entropy / max_entropy).round(3) : 0.0
  end

  # タグ統計計算
  def calculate_tag_statistics
    activities_with_tags = user.activities.includes(article: :tags)
    tag_stats = Hash.new { |h, k| h[k] = { good_count: 0, bad_count: 0, total_interactions: 0 } }

    activities_with_tags.each do |activity|
      activity.article.tags.each do |tag|
        tag_name = tag.name
        if activity.good?
          tag_stats[tag_name][:good_count] += 1
        elsif activity.bad?
          tag_stats[tag_name][:bad_count] += 1
        end
        tag_stats[tag_name][:total_interactions] += 1
      end
    end

    tag_stats
  end

  # 性格タイプ判定
  def determine_personality_type
    good_activities = user.activities.good.includes(article: :tags)
    ai_tags = [ "AI", "machine-learning", "technology" ]

    ai_count = 0
    total_good = 0

    good_activities.each do |activity|
      total_good += 1
      activity.article.tags.each do |tag|
        if ai_tags.include?(tag.name)
          ai_count += 1
          break # 同じ記事内で複数AI関連タグがあっても1回だけカウント
        end
      end
    end

    return "tech_enthusiast" if total_good > 0 && (ai_count.to_f / total_good) > 0.3
    return "active_user" if total_good > 20
    "casual_reader"
  end

  # 評価傾向判定
  def determine_evaluation_tendency
    good_count = user.activities.good.count
    bad_count = user.activities.bad.count

    total = good_count + bad_count
    return "neutral" if total == 0

    good_ratio = good_count.to_f / total
    return "positive" if good_ratio > 0.7
    return "negative" if good_ratio < 0.3
    "balanced"
  end

  # 優先度スコア計算
  def calculate_preference_score(good_count, bad_count)
    total = good_count + bad_count
    return 0.5 if total == 0

    # (good - bad) / (good + bad) を 0-1 の範囲に正規化
    raw_score = (good_count - bad_count).to_f / total
    ((raw_score + 1) / 2).round(3)
  end

  # アクティブ期間判定
  def determine_active_period
    seven_days_ago = 7.days.ago
    recent_count = user.activities.where(created_at: seven_days_ago..).count
    older_count = user.activities.where(created_at: ...seven_days_ago).count

    return "recent" if recent_count > older_count
    return "historical" if older_count > recent_count * 2
    "consistent"
  end

  # 強い好み検出
  def find_strong_preferences
    tag_stats = calculate_tag_statistics

    tag_stats.select do |_, stats|
      preference_score = calculate_preference_score(stats[:good_count], stats[:bad_count])
      preference_score > 0.8 && stats[:total_interactions] >= 3
    end.keys.first(5)
  end

  # 強い嫌い検出
  def find_strong_dislikes
    tag_stats = calculate_tag_statistics

    tag_stats.select do |_, stats|
      preference_score = calculate_preference_score(stats[:good_count], stats[:bad_count])
      preference_score < 0.2 && stats[:bad_count] > stats[:good_count]
    end.keys.first(5)
  end

  # 最近の興味検出
  def find_recent_interests
    seven_days_ago = 7.days.ago

    recent_good_activities = user.activities.good
                               .where(created_at: seven_days_ago..)
                               .includes(article: :tags)

    older_good_activities = user.activities.good
                              .where(created_at: ...seven_days_ago)
                              .includes(article: :tags)

    recent_good_tags = Set.new
    recent_good_activities.each do |activity|
      activity.article.tags.each { |tag| recent_good_tags << tag.name }
    end

    older_good_tags = Set.new
    older_good_activities.each do |activity|
      activity.article.tags.each { |tag| older_good_tags << tag.name }
    end

    (recent_good_tags - older_good_tags).to_a.first(3)
  end
end
