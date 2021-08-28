class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :destroy]

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


  def crear_actualizar_cliente
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = Cliente.create_update_cliente(parametros, true)
		resultado.send_response self
	end

  # POST /clientes
  def create
    crear_actualizar_cliente
  end

  # PATCH/PUT /clientes/1
  def update
    crear_actualizar_cliente
  end

  # DELETE /clientes/1
  def destroy
    resultado = borrar_entidad(@cliente)
    resultado.send_response self
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
                                    :maximo_credito, :vendedor_id, :balance, :documentos_de_identidad)
  end
end
