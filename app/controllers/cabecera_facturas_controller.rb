class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]
  before_action :find_secuencia, only: [:create]
  # GET /cabecera_facturas
  def index
    @cabecera_facturas = CabeceraFactura.all

    render json: @cabecera_facturas
  end

  # GET /cabecera_facturas/1
  def show
    render json: @cabecera_factura
  end

  def find_secuencia
    puts "-------------------- inicio find_secuencia --------------------"
    @factura_de = TipoFactura.find_by_id(params[:FACTURA_DE]).descripcion
    @tipoFactura = TipoFactura.find_by_id(params[:tipo_factura_id])

    if @factura_de == "Venta" || params["is_nota"]
      @factura_aplicada_id = params[:factura_id]
      @actual_paquete_comprobante = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:tipo_factura_id], true)
      if @actual_paquete_comprobante[:error]
        return render :json => @actual_paquete_comprobante, status: @actual_paquete_comprobante[:status]
      end

      @next_secuencia_comprobante = @actual_paquete_comprobante[:body]["secuencia"] + 1

      @actual_paquete_comprobante = @actual_paquete_comprobante[:body]

      puts "@actual_paquete_comprobante --->".red, @actual_paquete_comprobante.to_json
      puts "@next_secuencia_comprobante --->".blue, @next_secuencia_comprobante.to_json
    end

    @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:tipo_factura_id])
    # if @tipoFactura[:descripcion] == "Venta"
    #   @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:tipo_factura_id])
    # elsif @tipoFactura[:descripcion] == "Compra"
    #   @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:FACTURA_DE])
    # else
    #   @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:tipo_factura_id])
    # end

    @next_secuencia_factura = @actual_secuencia_factura["secuencia"] + 1

    @numero_factura = @next_secuencia_factura

    if @factura_de == "Venta"
      # --------- VENTA / NOTAS ---------
      @numero_comprobante = "B" + @tipoFactura["referencia"] + ("%08d" % @next_secuencia_comprobante)
    else
      # --------- COMPRA ---------
      @numero_comprobante = cabecera_factura_params["numero_comprobante"].upcase
    end
  end

  # POST /cabecera_facturas
  def create
    CabeceraFactura.transaction do
      att = cabecera_factura_params

      puts "=====" * 15
      puts " " * 25 + "cabecera factura"
      puts "=====" * 15
      puts :json => att
      puts "=====" * 15

      resultCliente = { :error => false }
      resultBalanceFact = { :error => false }
      resultAgregarNota = { :error => false }
      if att["condicion"] == "Crédito" && att["tipo"] == "venta"
        resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"], "+")
      end

      # # NOTA DE CREDITO
      # if att["is_nota"] && att["tipo_factura_id"] == 5
      #   resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"].to_f.abs, "-")
      #   # resultBalanceFact = CabeceraFactura.ReCalculateBalanceFactura(@factura_aplicada_id, att["total_factura"].to_f.abs, "+")
      #   resultAgregarNota = CabeceraFactura.agregarNotaACabeceraFactura(@factura_aplicada_id)
      # end

      # # NOTA DE DEBITO
      # if att["is_nota"] && att["tipo_factura_id"] == 4
      #   resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"].to_f.abs, "+")
      #   # resultBalanceFact = CabeceraFactura.ReCalculateBalanceFactura(@factura_aplicada_id, att["total_factura"].to_f.abs, "+")
      #   resultAgregarNota = CabeceraFactura.agregarNotaACabeceraFactura(@factura_aplicada_id)
      # end

      if resultCliente[:error]
        render json: resultCliente, status: :unprocessable_entity
        break
      elsif resultBalanceFact[:error]
        render json: resultBalanceFact, status: :unprocessable_entity
        break
      elsif resultAgregarNota[:error]
        render json: resultAgregarNota, status: :unprocessable_entity
        break
      else
        att["fecha_facturacion"] = att["fecha_facturacion"] ? att["fecha_facturacion"] : DateTime.now
        att["numero_comprobante"] = @numero_comprobante.upcase
        att["numero_factura"] = @numero_factura

        @cabecera_factura = CabeceraFactura.new(att)
        puts "AQUIIIIII-----> ".yellow, "#{@cabecera_factura.to_json}"
        # return render json: { msg: "pruebas", body: @cabecera_factura }

        unless @cabecera_factura.save
          # render json: @cabecera_factura, status: :created, location: @cabecera_factura
          render json: @cabecera_factura.errors, status: :unprocessable_entity
        else
          update_secuencia
        end
      end
    end
  end

  def update_secuencia
    CabeceraFactura.transaction do
      if params[:FACTURA_DE] == 14
        # --------- COMPRA ---------

        unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
          render json: { msg: "Error actualizando la tabla de secuencia de Factura Compra" }, status: :unprocessable_entity
        else
          cabecera = parsearData(@cabecera_factura, @factura_de)
          render json: cabecera, status: :created, location: @cabecera_factura
        end
      else
        # --------- VENTA / NOTA ---------
        puts "@actual_paquete_comprobante -->".red, @actual_paquete_comprobante.to_json
        actualizando = { error: false, msg: "" }
        if @actual_paquete_comprobante["is_paquete"]
          puts "ES UN PAQUETE !!!!!!".red
          actualizando = SecuenciaComprobante.aumentar_secuencia_comprobante(@actual_paquete_comprobante["id"])
        end

        if actualizando[:error]
          render json: { msg: actualizando[:msg] }, status: :unprocessable_entity
        else
          unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
            render json: { msg: actual_secuencia_factura.errors }, status: :unprocessable_entity
          else
            puts "AQUIIIIII-----> ".red, "#{@cabecera_factura.to_json}"
            cabecera = CabeceraFactura.parsearData(@cabecera_factura, @factura_de)

            puts "cabecera ----->".blue, cabecera
            # cabecera = parsearData(@cabecera_factura, @factura_de)
            f - e
            render json: cabecera, status: :created, location: @cabecera_factura
          end
        end
      end
    end
  end

  # PATCH/PUT /cabecera_facturas/1
  def update
    if @cabecera_factura.update(cabecera_factura_params)
      render json: @cabecera_factura
    else
      render json: @cabecera_factura.errors, status: :unprocessable_entity
    end
  end

  # DELETE /cabecera_facturas/1
  def destroy
    @cabecera_factura.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_factura
    @cabecera_factura = CabeceraFactura.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cabecera_factura_params
    params.require(:cabecera_factura).permit(:user_id, :cliente_id, :forma_pago, :numero_factura, :total_factura, :pagada, :balance, :tiene_nota,
                                             :devuelta, :noCliente_nombre, :noCliente_direccion, :noCliente_telefono, :bruto, :condicion, :descuento,
                                             :estado, :is_nota, :itbis, :numero_comprobante, :tipo_factura_id,
                                             detalle_facturas_attributes: [:cabecera_factura_id, :articulo_id, :cantidad, :total, :precio, :costo,
                                                                           :retirado, :retirado_en_venta, :unidad, :itbis, :descuento_valor,
                                                                           :descuento_porciento, :medida_es])
  end
end
