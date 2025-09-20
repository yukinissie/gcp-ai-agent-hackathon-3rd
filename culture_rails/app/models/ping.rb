class Ping < ApplicationRecord
  # 疎通テスト用モデル
  # 属性: id: integer, message: string

  validates :message, presence: true
end
