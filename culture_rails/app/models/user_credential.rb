class UserCredential < ApplicationRecord
  belongs_to :user
  has_secure_password

  validates :email_address, presence: true, uniqueness: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
