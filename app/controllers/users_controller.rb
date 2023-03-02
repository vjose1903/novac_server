class UsersController < ApplicationController

  before_action :set_user, only: [:show, :destroy]

  def index
    if params['filter_key'] && params['filter_value']
      users = User.handleFilter(params)
      return Response.new(params, nil, users, nil, get_parametros_opcionales).send_response self
    else
      return Response.new(params, nil, User.all.where({ estado: true}).where("usuario NOT IN ('novac', 'adm01')").order('id DESC'), nil, get_parametros_opcionales).send_response self
    end
  end


  def show
    return Response.new(params, nil, @cliente, nil, get_parametros_opcionales).send_response self
  end

  def getUsuariosFiltrados
    arg = params["arg"]
    resultado = User.filtrarUsusarios(arg, set_paginate_options(params))
    resultado.send_response self
  end

  def crear_actualizar_user
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = User.crear_actualizar_user(parametros, true)
		resultado.send_response self
	end

  def create
    crear_actualizar_user
  end

  def update
    crear_actualizar_user
  end


  def get_parametros_opcionales
    return {
      nombre_completo: params['nombre_completo'] || false,
      all: params['all'] || false,
      id: params['id'] || false,
      nombre: params['nombre'] || false,
      usuario: params['usuario'] || false,
      estado: params['estado'] || false,
      cedula: params['cedula'] || false,
      apellido: params['apellido'] || false,
      sexo: params['sexo'] || false,
      fotoPerfil: params['fotoPerfil'] || false,
      telefono: params['telefono'] || false,
      email: params['email'] || false,
      fecha_nacimiento: params['fecha_nacimiento'] || false,
      role: params['role'] || false,
      imagen: params['imagen'] || false,
      documentos_de_identidad: params['documentos_de_identidad'] || false,
    }
  end

  # DELETE /users/1
  def destroy
    resultado = borrar_entidad(@user)
    resultado.send_response self
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user

    params[:id] = params[:user_id] if params[:user_id]
    respuesta = set_entidad(User, params)
    @user = respuesta.get_data

    return respuesta.send_response self if @user.nil?
  end
end
