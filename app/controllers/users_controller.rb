class UsersController < ApplicationController

  before_action :set_user, only: [:show, :destroy]

  def index
    if params['filter_key'] && params['filter_value']
      users = User.handleFilter(params)
      resultado = User.serialized_response(users, params, get_parametros_opcionales)
      render_json_response(resultado)
    else
      users = User.where({ estado: true}).where("usuario NOT IN ('novac', 'adm01')").order('id DESC')
      resultado = User.serialized_response(users, params, get_parametros_opcionales)
      render_json_response(resultado)
    end
  end


  def show
    resultado = {status: HTTP_STATUS_CODE[:ok], data: UserSerializer.to_hash(@user, get_parametros_opcionales), msg: []}
    render_json_response(resultado)
  end

  def getUsuariosFiltrados
    arg = params["arg"]
    resultado = User.filtrarUsusarios(arg, set_paginate_options(params))
    render_json_response(resultado)
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
      nombre_completo:         validate_optional_param(params, 'nombre_completo') ?         params['nombre_completo'].to_boolean :         false,
      all:                     validate_optional_param(params, 'all') ?                     params['all'].to_boolean :                     false,
      id:                      validate_optional_param(params, 'id') ?                      params['id'].to_boolean :                      false,
      nombre:                  validate_optional_param(params, 'nombre') ?                  params['nombre'].to_boolean :                  false,
      usuario:                 validate_optional_param(params, 'usuario') ?                 params['usuario'].to_boolean :                 false,
      estado:                  validate_optional_param(params, 'estado') ?                  params['estado'].to_boolean :                  false,
      cedula:                  validate_optional_param(params, 'cedula') ?                  params['cedula'].to_boolean :                  false,
      apellido:                validate_optional_param(params, 'apellido') ?                params['apellido'].to_boolean :                false,
      sexo:                    validate_optional_param(params, 'sexo') ?                    params['sexo'].to_boolean :                    false,
      fotoPerfil:              validate_optional_param(params, 'fotoPerfil') ?              params['fotoPerfil'].to_boolean :              false,
      telefono:                validate_optional_param(params, 'telefono') ?                params['telefono'].to_boolean :                false,
      email:                   validate_optional_param(params, 'email') ?                   params['email'].to_boolean :                   false,
      fecha_nacimiento:        validate_optional_param(params, 'fecha_nacimiento') ?        params['fecha_nacimiento'].to_boolean :        false,
      role:                    validate_optional_param(params, 'role') ?                    params['role'].to_boolean :                    false,
      imagen:                  validate_optional_param(params, 'imagen') ?                  params['imagen'].to_boolean :                  false,
      documentos_de_identidad: validate_optional_param(params, 'documentos_de_identidad') ? params['documentos_de_identidad'].to_boolean : false,
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

  def render_json_response(resultado)
    render body: resultado.except(:status).to_json, status: resultado[:status], content_type: 'application/json'
  end
end
