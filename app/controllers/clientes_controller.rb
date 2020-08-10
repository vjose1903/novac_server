class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :update, :destroy]

  # GET /clientes
  def index
    # @clientes = Cliente.all
    @clientes = []

    Cliente.all.each do |cliente|
      if cliente["estado"] == true
        @clientes.push(parsearData(cliente))
      end
    end
    render json: @clientes
  end

  def parsearData(objeto)
    documents = []

    begin
      att = objeto.attributes
    rescue
      att = objeto
    end

    documentos = DocumentoDeIdentidad.where({ cliente_id: att["id"] })
    documentos.each do |doc|
      obj = {}
      obj["descripcion"] = doc["descripcion"]
      obj["documento"] = doc["documento"]
      obj["principal"] = doc["principal"]
      documents.push(obj)
    end
    att["documentos_de_identidad"] = documents

    vendedor = User.get_vendedor_by_id(att["vendedor_id"])

    objV = {}
    objV["nombre"] = vendedor[0]["nombre"]
    objV["vendedor_id"] = vendedor[0]["id"]
    att["vendedor"] = objV

    return att
  end

  def getClientesFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    clientes_ = Cliente.filtrarCliente(arg)

    clientes = Cliente.parsearClientes(clientes_)

    puts "#{clientes.to_json}".blue

    res = []

    if paginado
      res = clientes.to_a.my_paginate(page, per_page)

      res[:data].each do |cliente|
        cliente["documentos_de_identidad"] = DocumentoDeIdentidad.where({ cliente_id: cliente["id"] })
      end
    else
      res = clientes.each do |cliente|
        arti["documentos_de_identidad"] = DocumentoDeIdentidad.where({ cliente_id: cliente["id"] })
      end
    end

    render json: res
  end

  def getClientesByName
    nom_ = params[:nombre]

    clientes_ = Cliente.get_cliente_by_name(nom_)

    @clientes = []
    clientes_.each do |cliente|
      if cliente["estado"] == true
        @clientes.push(parsearData(cliente))
      end
    end
    render json: @clientes
  end

  # GET /clientes/1
  def show
    cliente = parsearData(@cliente)
    if cliente["estado"] == false
      cliente = { "nombre": "Este cliente esta desactivado." }
    end
    render json: cliente
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
    oldDocuments = DocumentoDeIdentidad.get_documentos_by_cliente_id(params[:id])
    puts "=====".red * 20
    puts oldDocuments
    puts "=====".red * 20
    oldDocuments.each do |doc|
      documento = DocumentoDeIdentidad.find_by_id(doc["id"])
      if documento.delete()
        puts "ELIMINADO"
      end
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
    @cliente = Cliente.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cliente_params
    params.require(:cliente).permit(:imagen_id, :nombre, :estado, :apellido, :limite_credito, :telefono, :direccion, :sexo,
                                    :maximo_credito, :vendedor_id, :cuenta, :balance,
                                    documentos_de_identidad_attributes: [:cliente_id, :descripcion, :documento, :principal])
  end
end
