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

  def getUsuariosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"].to_i

    usuarios = User.filtrarUsusarios(arg)

    usuarios_ = User.parsearUsuariosFiltro(usuarios)

    usuarios_paginado = usuarios_.to_a.my_paginate(page, per_page)

    render json: usuarios_paginado
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

    documento_ = DocumentoDeIdentidad.where({ user_id: objeto["id"] })[0]

    unless documento_.nil?
      object["documento_de_identidad"] = {
        :descripcion => documento_["descripcion"],
        :documento => documento_["documento"],
      }
    end

    return object
  end

  private
end
