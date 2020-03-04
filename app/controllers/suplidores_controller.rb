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

  # def getUsers
  #   @usuarios = []
  #   User.get_users.each do |user|
  #     @usuarios.push(parsealUser(user))
  #   end
  #   render json: @usuarios
  # end

  # def getVendedores
  #   @usuarios = []
  #   User.get_vendedores.each do |user|
  #     @usuarios.push(parsealUser(user))
  #   end
  #   render json: @usuarios
  # end

  # def getUserById
  #   usuario = User.get_user_by_id(params[:id])
  #   user = parsealUser(usuario[0])
  #   if user["estado"] == false
  #     user = { "nombre": "Este usuario esta desactivado." }
  #   end
  #   render json: user
  # end

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
    puts "=====".red * 20
    puts oldDocuments
    puts "=====".red * 20
    oldDocuments.each do |doc|
      documento = DocumentoDeIdentidad.find_by_id(doc["id"])
      if documento.delete()
        puts "ELIMINADO"
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
