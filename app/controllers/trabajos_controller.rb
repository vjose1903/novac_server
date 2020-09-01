class TrabajosController < ApplicationController
  before_action :set_trabajo, only: [:show, :update, :destroy]

  # GET /trabajos
  def index
    @trabajos = Trabajo.all

    render json: @trabajos
  end

  # GET /trabajos/1
  def show
    render json: @trabajo
  end

  def getTrabajosFiltrados
    arg = params["arg"]

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false
    trabajos = []

    works = Trabajo.filtrarTrabajo(arg)

    trabajos_ = Trabajo.parsearTrabajosFiltro(works)

    res = []

    if paginado
      res = trabajos_.to_a.my_paginate(page, per_page)
    else
      res = trabajos_
    end

    render json: res
  end

  # POST /trabajos
  def create
    @trabajo = Trabajo.new(trabajo_params)

    trabajo = Trabajo.agregarActualmente(@trabajo)

    if @trabajo.save
      puts "trabajo creado==> ".red +trabajo.to_json
      render json: trabajo, status: :created, location: @trabajo
    else
      render json: @trabajo.errors, status: :unprocessable_entity
    end
  end

  # cancelarTrabajo
  def cancelarTrabajo
    respuesta = Trabajo.cancelar_trabajo(params)

    if respuesta[:error] == false
      obj_respuesta = Trabajo.agregarActualmente(respuesta[:obj])
      render json: { data: obj_respuesta }, status: 200
    else
      render json: { error: respuesta[:msg], msg: "Error cancelando trabajo." }, status: :unprocessable_entity
    end
  end

  # reactivarTrabajo
  def reactivarTrabajo
    respuesta = Trabajo.reactivar_trabajo(params)

    if respuesta[:error] == false
      obj_respuesta = Trabajo.agregarActualmente(respuesta[:obj])
      render json: { data: obj_respuesta }, status: 200
    else
      render json: { error: respuesta[:msg], msg: "Error reactivando trabajo." }, status: :unprocessable_entity
    end
  end

  # cambiarEstadoTrabajo
  def cambiarEstadoTrabajo
    respuesta = Trabajo.cambiar_estado_trabajo(params)

    if respuesta[:error] == false
      obj_respuesta = Trabajo.agregarActualmente(respuesta[:obj])

      render json: { data: obj_respuesta, msg: respuesta[:msg] }, status: 200
    else
      render json: { error: respuesta[:msg], msg: "Error cambiando estado trabajo." }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /trabajos/1
  def update
    if @trabajo.update(trabajo_params)
      render json: @trabajo
    else
      render json: @trabajo.errors, status: :unprocessable_entity
    end
  end

  # DELETE /trabajos/1
  def destroy
    @trabajo.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_trabajo
    @trabajo = Trabajo.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def trabajo_params
    params.require(:trabajo).permit(:cliente_id, :tipo_trabajo, :marca_id, :modelo_id, :identificador, :tiene_bateria, :descripcion, :notas,
                                    :estado_actual, :estado, :fecha_cancelado, :fecha_reactivado)
  end
end
