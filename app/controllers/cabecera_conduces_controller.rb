class CabeceraConducesController < ApplicationController
  before_action :set_cabecera_conduce, only: [:show, :update, :destroy]

  # GET /cabecera_conduces
  def index
    @cabecera_conduces = CabeceraConduce.all
    cabeceras = []
    @cabecera_conduces.each do |conduce|
      cabeceras.push(CabeceraConduce.parsearData(conduce))
    end
    render json: cabeceras
  end

  # GET /cabecera_conduces/1
  def show
    cabecera = CabeceraConduce.parsearData(@cabecera_conduce)
    render json: cabecera
  end

  # POST /cabecera_conduces
  def create
    CabeceraConduce.transaction do
      att = cabecera_conduce_params
      @cabecera_conduce = CabeceraConduce.new(att)
      @cabecera_conduce.numero_conduce = SecuenciaFactura.find_secuencia(15)
      @cabecera_conduce.fecha_equivalente = att["fecha_equivalente"] ? att["fecha_equivalente"] : DateTime.now
      # puts @cabecera_conduce.detalle_conduces_attributes
      if @cabecera_conduce.save
        updateSecuencias
        # return render json: { msg: "pruebas", body: @cabecera_conduce }, status: :unprocessable_entity
        # raise ActiveRecord::Rollback

      else
        render json: @cabecera_conduce.errors, status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /cabecera_conduces/1
  def updateSecuencias
    secuencia_comprobante = SecuenciaFactura.find_by_id(15)
    puts secuencia_comprobante.to_json.red

    actual = secuencia_comprobante.secuencia
    secuencia_comprobante.secuencia = actual + 1

    if secuencia_comprobante.save!
      cabecera_conduce = CabeceraConduce.parsearData(@cabecera_conduce)
      render json: cabecera_conduce, status: :created, location: @cabecera_conduce
    else
    end
  end

  def update
    if @cabecera_conduce.update(cabecera_conduce_params)
      render json: @cabecera_conduce
    else
      render json: @cabecera_conduce.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cabecera_conduces/1
  def destroy
    @cabecera_conduce.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_conduce
    @cabecera_conduce = CabeceraConduce.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cabecera_conduce_params
    params.require(:cabecera_conduce).permit(:user_id, :cliente_id, :numero_conduce, :fecha_equivalente,
                                             detalle_conduces_attributes: [:cabecera_conduce_id, :detalle_factura_id, :articulo_id, :cantidad, :cantidad_en_unidades, :unidad])
  end
end
