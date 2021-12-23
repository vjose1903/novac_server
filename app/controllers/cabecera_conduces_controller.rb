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

      if @cabecera_conduce.save
        
        continuar = procesosDetalle

        if continuar[:error]
          return render json: {msg: continuar[:msg]}, status: continuar[:status] 
          raise ActiveRecord::Rollback
        else
          listo = updateSecuencias
          
          if listo[:error]
            return render json: {msg: listo[:msg]}, status: listo[:status] 
            raise ActiveRecord::Rollback
          else
            return render json: listo[:body], status: listo[:status] 
          end
        end

      else
        render json: @cabecera_conduce.errors, status: :unprocessable_entity
      end
    end
  end

  def procesosDetalle
    res = { :error => false , :msg => '' , :status => 200}

    params["detalle_conduces_attributes"].each do |detalle_conduce|
      if detalle_conduce["detalle_factura_id"]
        detalleFactAdelantada = DetalleFactura.find_by_id(detalle_conduce["detalle_factura_id"])
        
        factAdelantada = CabeceraFactura.find_by_id(detalleFactAdelantada["cabecera_factura_id"])
        
        if factAdelantada["is_adelantada"]
          
          detalleFactAdelantada.retirado = detalleFactAdelantada.retirado + detalle_conduce["cantidad_en_unidades"]
          
          unless detalleFactAdelantada.save!
            
            return { :error => true , :msg => detalleFactAdelantada.errors , :status => :unprocessable_entity}
          end
        end
      end

      articulo = Articulo.find_by_id(detalle_conduce["articulo_id"])

      mov = (articulo["existencia"] - detalle_conduce["cantidad_en_unidades"])

      if mov < 0
        mensaje = "Cantidad introducida para el articulo #{articulo.nombre.titleize}  ahora excede la cantidad disponible en inventario. "
        return { :error => true , :msg => mensaje , :status => :unprocessable_entity}
      end

      unless articulo.update({ existencia: mov })
        return { :error => true , :msg => articulo.errors , :status => 400}
      end

      return res
    end
  end

  # PATCH/PUT /cabecera_conduces/1
  def updateSecuencias
    
    secuencia_comprobante = SecuenciaFactura.find_by_id(15)

    actual = secuencia_comprobante.secuencia
    secuencia_comprobante.secuencia = actual + 1

    if secuencia_comprobante.save!
      cabecera_conduce = CabeceraConduce.parsearData(@cabecera_conduce)

      return {:error => false, :body=> cabecera_conduce.to_json, :status=> :created}
    else
      return {:error => true, :msg=> 'Error actualizando la secuencia de los conduces.', :status=> 400}
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
