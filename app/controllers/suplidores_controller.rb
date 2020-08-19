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
        @suplidores.push(suplidor)
      end
    end
    render json: @suplidores
  end

  def getNombresSuplidores
    @nombresSuplidores = Suplidor.get_nombres_suplidores
    render json: @nombresSuplidores
  end

<<<<<<< HEAD
=======
  def getSuplidoresFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    suplidores_ = Suplidor.filtrarSuplidores(arg)

    suplidores = Suplidor.parsearSuplidores(suplidores_)

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
      puts " ------ LLENO ------"
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

>>>>>>> prueba
  # GET /suplidores/1
  def show
    supli = @suplidor
    if supli["estado"] == false
      supli = { "nombre": "Este suplidor esta desactivado." }
    end
    render json: supli
  end

  def getSuplidoresFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    suplidores = Suplidor.filtrarSuplidores(arg)

    suplidores_ = Suplidor.parsearSuplidoresFiltro(suplidores)

    res = []

    if paginado
      res = suplidores_.to_a.my_paginate(page, per_page)
    else
      res = suplidores_
    end

    render json: res
  end

  # POST /suplidores
  def create
    Suplidor.transaction do
      # documento_identidad_ = params["documentos_de_identidad_attributes"]

      # @documento_identidad = DocumentoDeIdentidad.new(documento_identidad_)

      # if @documento_identidad.save
      @suplidor = Suplidor.new(suplidor_params)

      if @suplidor.save
        render json: @suplidor, status: :created, location: @suplidor
      else
        render json: @suplidor.errors, status: :unprocessable_entity
      end
      # else
      #   render json: @documento_identidad.errors, status: :unprocessable_entity
      # end
    end
  end

  # PATCH/PUT /suplidores/1
  def update
    Suplidor.transaction do
      oldDocuments = DocumentoDeIdentidad.where({ suplidor_id: params[:id] })[0]

      unless oldDocuments.nil?
        if oldDocuments.delete()
          puts "ELIMINADO"
        end
      end

      if @suplidor.update(suplidor_params)
        render json: @suplidor
      else
        render json: @suplidor.errors, status: :unprocessable_entity
      end
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
    params.require(:suplidor).permit(:nombre, :telefono, :direccion, :email, :estado,
                                     documento_de_identidad_attributes: [:suplidor_id, :descripcion, :documento])
  end
end
