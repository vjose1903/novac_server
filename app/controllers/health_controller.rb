class HealthController < ActionController::API
  def show
    Health.base.send_response(self)
  end

  def dgii
    Health.dgii.send_response(self)
  end
end
