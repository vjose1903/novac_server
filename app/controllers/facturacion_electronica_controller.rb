class FacturacionElectronicaController < ApplicationController
  if ENV["RAILS_ENV"] != "development"
    skip_before_action :validateUserIsLogging!
  end

  
  def recepcion
    # lógica para manejar la recepción de ECF
    render json: { mensaje: "Recepción procesada" }, status: :ok
  end

  def aprobacion_comercial
    # lógica para manejar la aprobación comercial
    render json: { mensaje: "Aprobación comercial procesada" }, status: :ok
  end
end
