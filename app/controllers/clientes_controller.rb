class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :update, :destroy]

  # GET /clientes
  def index    
    return Response.new(nil, Cliente.all.where({ estado: true}).order('id DESC'), nil, {}).send_response self
  end

  def getClientesFiltrados
    arg = params["arg"]
    resultado = Cliente.filtrarCliente(arg, set_paginate_options(params))
    resultado.send_response self
  end

  # GET /clientes/1
  def show
    return Response.new(nil, @cliente, nil, {}).send_response self
  end

  # POST /clientes
  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      render json: @cliente, status: :created, location: @cliente
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clientes/1
  def update
    oldDocuments = @cliente.documentos_de_identidad

    oldDocuments.each do |doc|
      doc.delete()
    end

    if @cliente.update(cliente_params)
      render json: @cliente
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  # DELETE /clientes/1
  def destroy
    @cliente.destroy
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cliente
    respuesta = set_entidad(Cliente, params)
    @cliente = respuesta.get_data
      
    return respuesta.send_response self if @cliente.nil?
  end

  # Only allow a trusted parameter "white list" through.
  def cliente_params
    params.require(:cliente).permit(:imagen_id, :nombre, :estado, :apellido, :limite_credito, :telefono, :direccion, :sexo,
                                    :maximo_credito, :vendedor_id, :balance,
                                    documentos_de_identidad_attributes: [:cliente_id, :descripcion, :documento, :principal])
  end
end
