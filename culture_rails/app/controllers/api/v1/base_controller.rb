class Api::V1::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  protect_from_forgery with: :null_session
end
