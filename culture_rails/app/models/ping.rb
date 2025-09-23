# == Schema Information
#
# Table name: pings
#
#  id         :bigint           not null, primary key
#  message    :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Ping < ApplicationRecord
  # 疎通テスト用モデル
  # 属性: id: integer, message: string

  validates :message, presence: true
end
