class RolesController < ApplicationController
  before_action :set_role, only: [:show, :destroy]

  # GET /roles
  def index
    return Response.new(params, HTTP_STATUS_CODE[:ok], Role.all.order('id DESC'), nil, get_parametros_opcionales, Role.models_includes).send_response self
  end

	# GET /roles/1
	def show
		return Response.new(params, HTTP_STATUS_CODE[:ok], @role, nil, get_parametros_opcionales, Role.models_includes).send_response self
	end

  def getRolesFiltrados
    arg = params["arg"]

    resultado = Role.filtrarRole(arg, set_paginate_options(params))
    resultado.send_response self
  end


  def crear_actualizar_role
		parametros = params
		parametros["id"] = params["id"] if params["id"]

    resultado = Role.create_update_role(parametros)
		resultado.send_response self
	end

  # POST /roles
  def create
    crear_actualizar_role
  end

  # PATCH/PUT /roles/1
  def update
    crear_actualizar_role
  end

  # DELETE /roles/1
  def destroy
    resultado = borrar_entidad(@role)
    resultado.send_response self
  end

	def get_parametros_opcionales
    return {
      all: true,
      permisos_acciones: validate_optional_param(params, 'permisos_acciones') ? params['permisos_acciones'].to_boolean : false,
    }
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_role
    respuesta = set_entidad(Role, params)
    @role = respuesta.get_data

    return respuesta.send_response self if @role.nil?
  end
end
