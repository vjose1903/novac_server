class DashboardController < ApplicationController
  def index
    result = Dashboard.build(params)

    if result[:status] == :ok
      render json: result[:data], status: :ok
    else
      render json: result[:error], status: result[:status]
    end
  end
end
