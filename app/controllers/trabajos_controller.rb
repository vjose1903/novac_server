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
    # obj = @trabajo.to_json
    # puts obj.red
    trabajo = Trabajo.agregarActualmente(@trabajo)

    puts "---".red * 20
    puts trabajo.to_json
    puts "---".red * 20
    
    if @trabajo.save
      render json: trabajo, status: :created, location: @trabajo
    else
      render json: @trabajo.errors, status: :unprocessable_entity
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
    params.require(:trabajo).permit(:cliente_id, :tipo_trabajo, :marca_id, :modelo_id, :identificador, :tiene_bateria, :descripcion, :notas, :empezado, :entregado, :terminado, :estado, :fecha_cancelado, :actualmente)
  end
end
