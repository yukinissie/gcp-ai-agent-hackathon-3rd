class Api::V1::PingController < ApplicationController
  # 疎通テスト用Ping API

  # GET /api/v1/ping
  def index
    ping = Ping.order(id: :desc).first

    if ping
      @ping = ping
      render :index, status: :ok
    else
      @error = {
        success: false,
        error: "not_found",
        message: "リソースが見つかりません"
      }
      render :error, status: :not_found
    end
  end

  # POST /api/v1/ping
  def create
    ping = Ping.new(message: params[:message])

    if ping.save
      @ping = ping
      render :create, status: :created
    else
      @error = {
        success: false,
        error: "validation_error",
        message: ping.errors.full_messages.join(", ")
      }
      render :error, status: :unprocessable_entity
    end
  rescue => e
    @error = {
      success: false,
      error: "internal_server_error",
      message: "予期せぬエラーが発生しました"
    }
    render :error, status: :internal_server_error
  end
end
