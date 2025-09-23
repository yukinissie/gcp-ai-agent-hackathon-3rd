class Current < ActiveSupport::CurrentAttributes
  attribute :session, :request, :user

  def user
    # JWT認証で直接設定されたユーザーを優先
    super || session&.user
  end
end
