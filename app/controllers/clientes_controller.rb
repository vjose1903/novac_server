class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :destroy, :getBalances]

  # GET /clientes
  def index
    return Response.new(params, nil, Cliente.all.where({ estado: true}).order('id DESC'), nil, {all: true}).send_response self
  end

	# GET /clientes/1
	def show
		return Response.new(params, nil, @cliente, nil, {all: true}).send_response self
	end

  def getClientesFiltrados
    arg = params["arg"]
    resultado = Cliente.filtrarCliente(arg, set_paginate_options(params))
    resultado.send_response self
  end


  def crear_actualizar_cliente
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = Cliente.create_update_cliente(parametros, true)
		resultado.send_response self
	end

  def getBalances
		resultado = @cliente.get_balances(set_paginate_options(params))
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
end
