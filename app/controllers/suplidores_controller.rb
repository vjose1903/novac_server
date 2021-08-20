class String
  def is_number?
    true if Float(self) rescue false
  end
end

class SuplidoresController < ApplicationController
  before_action :set_suplidor, only: [:show, :update, :destroy]

  # GET /suplidores
  def index
    # @suplidores = Suplidor.all
    @suplidores = []

    Suplidor.all.each do |suplidor|
      if suplidor["estado"] == true
        @suplidores.push(parseal(suplidor))
      end
    end
    render json: @suplidores
  end

  def parseal(objeto)
    documents = []
    att = objeto.attributes
    objeto.documentos_de_identidad.each do |doc|
      obj = {}
      obj["descripcion"] = doc["descripcion"]
      obj["documento"] = doc["documento"]
      obj["principal"] = doc["principal"]
      documents.push(obj)
    end
    att["documentos_de_identidad"] = documents

    return att
  end

  def getNombresSuplidores
    @nombresSuplidores = Suplidor.get_nombres_suplidores
    render json: @nombresSuplidores
  end

  def getSuplidoresFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false


    suplidores = Suplidor.select("suplidores.*, initcap(suplidores.nombre) as nombre")
    .joins("left join documentos_de_identidad on suplidores.id = documentos_de_identidad.suplidor_id AND documentos_de_identidad.principal = true")
    .where("lower(suplidores.nombre || ' ' || suplidores.direccion || ' ' || coalesce(suplidores.email, '') || ' ' || documentos_de_identidad.documento) like lower('%#{arg}%') AND estado = true")
    .order("suplidores.id ASC")
    .to_a

    res = []

    if paginado
      res = suplidores.to_a.my_paginate(page, per_page)

      res[:data].each do |suplidor|
        suplidor["documentos_de_identidad"] = DocumentoDeIdentidad.where({ suplidor_id: suplidor["id"] })
      end
    else
      res = suplidores.each do |suplidor|
        arti["documentos_de_identidad"] = DocumentoDeIdentidad.where({ suplidor_id: suplidor["id"] })
      end
    end

    render json: res
  end

  def parsealUser(objeto)
    docs = []
    object = {}

    object["id"] = objeto["id"]
    object["uid"] = objeto["uid"]
    object["sign_in_count"] = objeto["sign_in_count"]
    object["nombre"] = objeto["nombre"]
    object["usuario"] = objeto["usuario"]
    object["apellido"] = objeto["apellido"]
    object["sexo"] = objeto["sexo"]
    object["telefono"] = objeto["telefono"]
    object["email"] = objeto["email"]
    object["fecha_nacimiento"] = objeto["fecha_nacimiento"]
    object["role"] = objeto["role"]
    object["created_at"] = objeto["created_at"]
    object["updated_at"] = objeto["updated_at"]
    object["imagen_id"] = objeto["imagen_id"]
    object["estado"] = objeto["estado"]

    # if objeto == ""
    # end

    documentos = DocumentoDeIdentidad.get_documentos_by_user_id(objeto["id"])

    object["documentos_de_identidad"] = []
    unless documentos.rows == []
      documentos.each do |doc|
        obj = {}
        obj["descripcion"] = doc["descripcion"]
        obj["documento"] = doc["documento"]
        obj["principal"] = doc["principal"]
        docs.push(obj)
      end
      object["documentos_de_identidad"] = docs
    end

    return object
  end

  # GET /suplidores/1
  def show
    supli = @suplidor
    if supli["estado"] == false
      supli = { "nombre": "Este suplidor esta desactivado." }
    end
    render json: supli
  end

  # POST /suplidores
  def create
    @suplidor = Suplidor.new(suplidor_params)

    if @suplidor.save
      render json: @suplidor, status: :created, location: @suplidor
    else
      render json: @suplidor.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /suplidores/1
  def update
    oldDocuments = DocumentoDeIdentidad.get_documentos_by_suplidor_id(params[:id])

    oldDocuments.each do |doc|
      documento = DocumentoDeIdentidad.find_by_id(doc["id"])
      if documento.delete()
      end
    end

    if @suplidor.update(suplidor_params)
      render json: @suplidor
    else
      render json: @suplidor.errors, status: :unprocessable_entity
    end
  end

  # DELETE /suplidores/1
  def destroy
    @suplidor.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_suplidor
    @suplidor = Suplidor.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def suplidor_params
    params.require(:suplidor).permit(:nombre, :telefono, :estado, :direccion, :email, documentos_de_identidad_attributes: [:cliente_id, :descripcion, :documento, :principal])
  end
end
