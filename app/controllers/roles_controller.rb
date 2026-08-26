class RolesController < ApplicationController
  before_action :set_role, only: [:show, :destroy]

  # GET /roles
  def index
    resultado = Role.serialized_response(Role.all.order('id DESC'), params, get_parametros_opcionales[:permisos_acciones])
    render body: resultado.except(:status).to_json, status: resultado[:status], content_type: 'application/json'
  end

	# GET /roles/1
	def show
		ActiveRecord::Associations::Preloader.new(records: [@role], associations: Role.models_includes).call
		resultado = {data: RoleSerializer.to_hash(@role, include_permisos_acciones: get_parametros_opcionales[:permisos_acciones]), msg: []}
		render body: resultado.to_json, status: HTTP_STATUS_CODE[:ok], content_type: 'application/json'
	end

  def getRolesFiltrados
    arg = params["arg"]

    resultado = Role.filtrarRole(arg, set_paginate_options(params))
    render body: resultado.except(:status).to_json, status: resultado[:status], content_type: 'application/json'
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
