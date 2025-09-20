class User < ApplicationRecord
  has_one :user_credential, dependent: :destroy
  has_many :sessions, dependent: :destroy

  validates :human_id, presence: true, uniqueness: true
  before_create :generate_human_id

  def authenticated?
    user_credential.present?
  end

  def as_json_for_api
    {
      id: id,
      human_id: human_id,
      email_address: user_credential&.email_address,
      authenticated: authenticated?
    }
  end

  private

  def generate_human_id
    loop do
      self.human_id = SecureRandom.hex(8)
      break unless User.exists?(human_id: human_id)
    end
  end
end
