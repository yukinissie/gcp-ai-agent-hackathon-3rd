# == Schema Information
#
# Table name: feeds
#
#  id                                  :bigint           not null, primary key
#  endpoint(RSS/AtomフィードのURL)     :string           not null
#  last_error(最後のエラーメッセージ)  :text
#  last_fetched_at(最後に取得した日時) :datetime
#  status(フィードの状態)              :string           default("active"), not null
#  title(フィードのタイトル)           :string           not null
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_feeds_on_created_at       (created_at)
#  index_feeds_on_endpoint         (endpoint) UNIQUE
#  index_feeds_on_last_fetched_at  (last_fetched_at)
#  index_feeds_on_status           (status)
#
class Feed < ApplicationRecord
  require "rss"
  require "net/http"

  has_many :articles, dependent: :destroy

  validates :title, presence: true
  validates :endpoint, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :endpoint, uniqueness: true

  enum status: {
    active: "active",
    inactive: "inactive",
    error: "error"
  }

  scope :active, -> { where(status: "active") }
  scope :recent, -> { order(created_at: :desc) }

  # RSSをパースして取得
  def parsed_rss
    begin
      xml = Net::HTTP.get(URI.parse(endpoint))
      RSS::Parser.parse(xml)
    rescue => e
      Rails.logger.error "Failed to parse RSS for Feed #{id}: #{e.message}"
      update!(status: "error", last_error: e.message)
      nil
    end
  end

  # フィードのタイトルを自動更新
  def update_title_from_rss
    rss = parsed_rss
    return unless rss&.channel&.title

    update!(title: rss.channel.title)
  end

  # 最後の取得成功時刻を更新
  def mark_as_fetched
    update!(
      status: "active",
      last_fetched_at: Time.current,
      last_error: nil
    )
  end

  # エラーマーク
  def mark_as_error(error_message)
    update!(
      status: "error",
      last_error: error_message
    )
  end
end
