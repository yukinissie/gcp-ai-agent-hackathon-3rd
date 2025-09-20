class Current < ActiveSupport::CurrentAttributes
  attribute :session, :request

  def user
    session&.user
  end
end
