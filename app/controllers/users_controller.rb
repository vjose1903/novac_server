class String
  def is_number?
    true if Float(self) rescue false
  end
end

class UsersController < ApplicationController
  def getUsers
    @usuarios = []
    User.get_users.each do |user|
      @usuarios.push(parsealUser(user))
    end
    render json: @usuarios
  end

  def getVendedores
    @usuarios = []
    User.get_vendedores.each do |user|
      @usuarios.push(parsealUser(user))
    end
    render json: @usuarios
  end

  def getUserById
    usuario = User.get_user_by_id(params[:id])
    user = parsealUser(usuario[0])
    if user["estado"] == false
      user = { "nombre": "Este usuario esta desactivado." }
    end
    render json: user
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

    if objeto == ""
    end

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

  private
end
