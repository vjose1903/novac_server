include ActionView::Helpers::NumberHelper

class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]
  before_action :find_secuencia, only: [:create]

  # GET /cabecera_facturas
  def index
    # @cabecera_facturas = CabeceraFactura.all
    @cabecera_facturas = []
    CabeceraFactura.all.each do |factura|
      @cabecera_facturas.push(parsearData(factura))
    end

    render json: @cabecera_facturas
  end

  # GET /cabecera_facturas/1
  def show
    cabecera = parsearData(@cabecera_factura)
    render json: cabecera
  end

  def getFacturasByParams
    campoNum = params[:campo]
    valor_des = desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\'))
    tipo_factura_id = params[:tipo_factura_id]
    adelantada = params[:adelantada]

    campo = ""
    if campoNum == "1"
      campo = "cliente_id"
      valor_des = valor_des.to_i
    elsif campoNum == "2"
      campo = "numero_comprobante"
      valor_des = valor_des.upcase
    elsif campoNum == "3"
      campo = "numero_factura"
      valor_des = valor_des.to_i
    elsif campoNum == "4"
    end

    cabe = CabeceraFactura.get_facturas_venta_by_params(campo, valor_des, tipo_factura_id, adelantada)

    puts "=-=".yellow * 20
    puts cabe.to_json
    puts "=-=".yellow * 20

    cabecera = []

    cabe.each do |factura|
      cabecera.push(parsearData(factura))
    end
    puts "/////".red * 20
    puts cabecera.to_json
    render json: cabecera
  end

  def getFacturasByClienteIdAndEstado
    cabe = CabeceraFactura.get_facturas_by_cliente_id_and_estado(params[:id], params[:pagada])
    puts "cabe ".yellow + "#{cabe.to_json}".white

    cabecera = []
    cabe.each do |factura|
      puts "@tipoFactura ".red + "#{@tipoFactura.to_json}".white
      cabecera.push(parsearData(factura))
    end
    # cabecera = parsearData(cabe)
    render json: cabecera
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

      # NOTA DE CREDITO
      if att["is_nota"] && att["tipo_factura_id"] == 5
        resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"].to_f.abs, "-")
        # resultBalanceFact = CabeceraFactura.ReCalculateBalanceFactura(@factura_aplicada_id, att["total_factura"].to_f.abs, "+")
        resultAgregarNota = CabeceraFactura.agregarNotaACabeceraFactura(@factura_aplicada_id)
      end

      # NOTA DE DEBITO
      if att["is_nota"] && att["tipo_factura_id"] == 4
        resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"].to_f.abs, "+")
        # resultBalanceFact = CabeceraFactura.ReCalculateBalanceFactura(@factura_aplicada_id, att["total_factura"].to_f.abs, "+")
        resultAgregarNota = CabeceraFactura.agregarNotaACabeceraFactura(@factura_aplicada_id)
      end

      puts ">>>>>" * 15
      puts "result Balance".red
      puts ">>>>>" * 15
      puts :json => resultBalanceFact
      puts ">>>>>" * 15

      puts ">>>>>" * 15
      puts "result cliente".yellow
      puts ">>>>>" * 15
      puts :json => resultCliente
      puts ">>>>>" * 15

      if resultCliente[:error]
        render json: resultCliente
        break
      elsif resultBalanceFact[:error]
        render json: resultBalanceFact
        break
      elsif resultAgregarNota[:error]
        render json: resultAgregarNota
        break
      else
        att["fecha_facturacion"] = att["fecha_facturacion"] ? att["fecha_facturacion"] : DateTime.now
        att["numero_comprobante"] = @numero_comprobante.upcase
        att["numero_factura"] = @numero_factura

        @cabecera_factura = CabeceraFactura.new(att)

        puts @cabecera_factura.to_json
        # return render json: { msg: "pruebas", body: cabecera }

        unless @cabecera_factura.save
          # render json: @cabecera_factura, status: :created, location: @cabecera_factura
          render json: @cabecera_factura.errors, status: :unprocessable_entity
        else
          update_secuencia
        end
      end
    end
  end

  def compareDateFactura(articulo)
    if parsearDate(articulo["updated_at"]) != parsearDate(articulo["created_at"])
      return false
    else
      return true
    end
  end

  def parsearDate(date)
    return DateTime.parse(date.to_s)
  end

  def parsearData(objeto, movimiento_inventario = false)
    puts "--------------- inicio parsearData ---------------"

    begin
      obj = objeto.attributes
      obj["detalle_facturas"] = objeto.detalle_facturas.to_a
    rescue
      obj = objeto
    end

    @tipoFactura = TipoFactura.find_by_id(obj["tipo_factura_id"])

    puts "#{obj}".red

    arrayDetalle = DetalleFactura.where({ cabecera_factura_id: obj["id"] })
    detalleFacturas = []

    arrayDetalle.each do |detalleF|
      objD = {}

      contenidoArticulo = ContenidoArticulo.where({ articulo_id: detalleF["articulo_id"] })

      articuloSelect = Articulo.find_by_id(detalleF["articulo_id"])
      tipoArticulo = TipoArticulo.find_by_id(articuloSelect["tipo_articulo_id"])

      continuar = compareDateFactura(articuloSelect)

      unless continuar
        articuloSelect = MantenimientoArticulo.get_one_articulo_by_date(objeto["fecha_facturacion"], articuloSelect["id"])
        articuloSelect = articuloSelect[0]
      end

      precioPrincipal = articuloSelect["precio_principal"]
      costoPrincipal = articuloSelect["costo_principal"]

      tipoArticuloD = tipoArticulo["descripcion"]

      precio = 0
      costo_calculado = 0

      unidad = detalleF["unidad"].split(" ")

      if unidad.length > 1
        objD["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)"
        objD["unidad"] = "#{unidad[0]}"
        objD["peso_saco"] = unidad[2]
      else
        objD["descripcion"] = "#{articuloSelect["nombre"]}"
        objD["unidad"] = detalleF["unidad"]
      end

      if unidad[0] == "Quintal" || unidad[0] == "Caja"
        costo_calculado = costoPrincipal
      elsif unidad[0] == "Saco"
        contenidoArticulo.each do |condi|
          if condi["medida"] == "Libra"
            costoC = (unidad[2].to_f * condi["costo"])
            costo_calculado = costoC.to_d.truncate(2).to_f
          end
        end
      else unidad[0] == "Paquete" || unidad[0] == "Libra"
        contenidoArticulo.each do |condi|
        if condi["medida"] == unidad[0]
          precio = condi["precio"]
          costo_calculado = condi["costo"]
        end
      end       end

      objD["articulo"] = articuloSelect["nombre"]
      objD["articulo_id"] = articuloSelect["id"]
      objD["codigo"] = articuloSelect["codigo"]
      objD["costo"] = costo_calculado
      objD["precio"] = detalleF["precio"]
      objD["total"] = detalleF["total"]
      objD["descuento_valor"] = detalleF["descuento_valor"]
      objD["descuento_porciento"] = detalleF["descuento_porciento"]
      objD["itbis"] = detalleF["itbis"]
      objD["cantidad"] = detalleF["cantidad"]
      objD["cantidad_en_unidades"] = detalleF["cantidad_en_unidades"]
      objD["tipo"] = tipoArticuloD
      objD["id"] = detalleF["id"]
      objD["retirado"] = detalleF["retirado"]

      unless objeto["adelantada"]
        if movimiento_inventario
          unless @actual_secuencia_factura == nil
            puts "@actual_secuencia_factura " + @actual_secuencia_factura.to_json
            factura_tipo = @actual_secuencia_factura["tipo_factura_id"]

            if articuloSelect["contenido_articulos"] == nil
              array_contenido = ContenidoArticulo.get_contenido_articulo_by_id(articuloSelect["id"])
              articuloSelect["contenido_articulos"] = array_contenido
            end
            if factura_tipo != 4 || factura_tipo != "4"
              movimientos_de_inventario(articuloSelect, objD["cantidad_en_unidades"])
            end
          end
        end
      end

      detalleFacturas.push(objD)
    end

    puts detalleFacturas.to_json.blue

    puts "*" * 20
    puts obj["detalle_facturas"].to_json

    puts obj

    obj["detalle_facturas"] = []
    obj["detalle_facturas"] = detalleFacturas

    cliente = {}
    suplidor = {}

    if !objeto["cliente_id"].nil? || objeto["is_nota"]
      cli = Cliente.find_by_id(obj["cliente_id"])
      cliente["nombre"] = "#{cli["nombre"]} #{cli["apellido"]}".titleize
      cliente["direccion"] = cli["direccion"]
      cliente["rnc"] = DocumentoDeIdentidad.where({ principal: true, cliente_id: cli["id"] })[0]["documento"]
    else
      if !objeto["NoCliente_nombre"].nil?
        cliente["nombre"] = objeto["NoCliente_nombre"]
        cliente["direccion"] = objeto["NoCliente_direccion"]
        cliente["rnc"] = nil
      end
    end

    if !obj["vendedor_id"].nil?
      vendedor_ = User.get_vendedor_by_id(objeto["vendedor_id"])[0]
      vendedor = "#{vendedor_["nombre"]} ".titleize + "#{vendedor_["apellido"]}".titleize
      obj["vendedor"] = vendedor
    end

    if !obj["user_id"].nil?
      usuario_ = User.find_by_id(objeto["user_id"])
      usuario = "#{usuario_["nombre"]} ".titleize + "#{usuario_["apellido"]}".titleize
      obj["usuario"] = usuario
    end

    if !obj["suplidor_id"].nil?
      supli = Suplidor.find_by_id(obj["suplidor_id"])
      suplidor["nombre"] = "#{supli["nombre"]}".titleize
      suplidor["direccion"] = supli["direccion"]
      suplidor["rnc"] = DocumentoDeIdentidad.where({ principal: true, suplidor_id: supli["id"] })[0]["documento"]
    end

    obj["notas"] = CabeceraFactura.where({ aplicada_a: objeto["numero_comprobante"] })

    obj["suplidor"] = suplidor
    obj["cliente"] = cliente
    obj["tipo_factura"] = @tipoFactura.descripcion.titleize
    obj["tiene_nota"] = objeto["tiene_nota"]

    pago_ = DetalleRecibo.where({ cabecera_factura_id: objeto["id"] }).as_json
    pago_parseo = []

    if pago_.length > 0
      pago_parseo = pago_.map do |detalle_recibo|
        detalle_recibo = detalle_recibo.as_json
        recibo = RecibosIngreso.find_by_id(detalle_recibo["recibos_ingreso_id"])

        detalle_recibo["numero_recibo"] = recibo["numero_recibo"]
        detalle_recibo["recibo_creado_por"] = "#{recibo.user["nombre"]} #{recibo.user["apellido"]}".titleize
        detalle_recibo["recibo_created_at"] = recibo["created_at"]
        detalle_recibo
      end
    end

    obj["pagos"] = pago_parseo

    puts "--------------- fin parsearData ---------------"
    puts ""
    puts ""
    return obj
  end

  # def calcularPrecioCantSacos(unidad, precio, tipo, cantidad)
  #   cant = ("0.#{unidad[2]}").to_f
  #   if unidad[2] === "100"
  #     return precio
  #   else
  #     return (precio * cant).to_d.truncate(2).to_f
  #   end
  # end

  def cancelarFactura
    puts "CANCELANDO FACTURA".red
    res = CabeceraFactura.anular_factura(params[:id])

    if res
      render json: { msg: "Factura anulada correctamente", status: 200 }, status: 200
    else
      render json: { msg: "Error anulando factura" }, status: :unprocessable_entity
    end
  end

  def update_secuencia
    # @cabecera_factura.transaction do
    if params[:FACTURA_DE] == 14
      # --------- COMPRA ---------

      unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
        render json: { msg: "Error actualizando la tabla de secuencia de Factura Compra" }, status: :unprocessable_entity
      else
        cabecera = parsearData(@cabecera_factura, true)
        render json: cabecera, status: :created, location: @cabecera_factura
      end
    else
      # --------- VENTA / NOTA ---------
      actualizando = { :error => false, :msg => "", :status => 200 }
      puts "@actual_paquete_comprobante".yellow, @actual_paquete_comprobante.to_json
      if @actual_paquete_comprobante["is_paquete"]
        puts "ES UN PAQUETE !!!!!!".red
        actualizando = SecuenciaComprobante.aumentar_secuencia_comprobante(@actual_paquete_comprobante["id"])
      end

      unless actualizando["error"]
        unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
          render json: { msg: "Error actualizando la tabla de secuencia de Factura Venta", error: @actual_secuencia_factura.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        else
          cabecera = parsearData(@cabecera_factura, true)
          render json: cabecera, status: :created, location: @cabecera_factura
        end
      else
        render json: { msg: actualizando["msg"] }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
    # end

  end

  def movimientos_de_inventario(articulo, cantidad_en_unidades)
    if params[:FACTURA_DE] == 13
      # --------- VENTA ---------
      movimiento = Articulo.find_by_id(articulo["id"])
      puts "movimiento['existencia']".blue, movimiento["existencia"]
      puts "cantidad_en_unidades".green, cantidad_en_unidades

      mov = (movimiento["existencia"] - cantidad_en_unidades)

      puts " estas vendiendo #{cantidad_en_unidades} "
      puts " inventario queda en  #{mov} "
      if mov < 0
        mensaje = "Cantidad introducida para el articulo #{articulo.nombre.titleize}  ahora excede la cantidad disponible en inventario. "
        render json: { msg: mensaje }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      if movimiento.update({ existencia: mov })
        puts "::::::::::::::::::::::::::::::::::::::::::"
        puts "::::                                  ::::"
        puts "::::        VENTA EXITOSA             ::::"
        puts "::::                                  ::::"
        puts "::::::::::::::::::::::::::::::::::::::::::"
      end
    else
      # --------- COMPRA ---------
      movimiento = Articulo.find_by_id(articulo["id"])
      puts "movimiento ".red + "#{movimiento.to_json}".white
      puts "cantidad_en_unidades ".yellow + "#{cantidad_en_unidades.to_json}".white
      mov = (movimiento["existencia"] + cantidad_en_unidades)
      puts "mov ".red + "#{mov}".white

      puts " estas comprando #{cantidad_en_unidades} "
      puts " inventario queda en  #{mov} "
      if movimiento.update({ existencia: mov })
        puts "::::::::::::::::::::::::::::::::::::::::::"
        puts "::::                                  ::::"
        puts "::::         COMPRA EXITOSA           ::::"
        puts "::::                                  ::::"
        puts "::::::::::::::::::::::::::::::::::::::::::"
      end
    end
  end

  def find_secuencia
    if params["tipo"] == "venta" || params["is_nota"]
      @factura_aplicada_id = params[:factura_id]
      @actual_paquete_comprobante = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:tipo_factura_id], true)
      if @actual_paquete_comprobante[:error]
        return render :json => @actual_paquete_comprobante, status: @actual_paquete_comprobante[:status]
      end
      @actual_paquete_comprobante = @actual_paquete_comprobante[:body]
      @next_secuencia_comprobante = @actual_paquete_comprobante["secuencia"]
    end

    @tipoFactura = TipoFactura.find_by_id(params[:tipo_factura_id])

    if params["tipo"] == "venta" || params["is_nota"]
      @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:tipo_factura_id])
    elsif params["tipo"] == "compra"
      @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:FACTURA_DE])
    end

    @next_secuencia_factura = @actual_secuencia_factura["secuencia"] + 1

    @numero_factura = @next_secuencia_factura

    if params[:FACTURA_DE] == 14
      # --------- COMPRA ---------
      @numero_comprobante = cabecera_factura_params["numero_comprobante"].upcase
    else
      # --------- VENTA / NOTAS ---------
      @numero_comprobante = "B" + @tipoFactura["referencia"] + ("%08d" % @next_secuencia_comprobante)
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

  # def guardarHistorico
  # end

  # DELETE /cabecera_facturas/1
  def destroy
    @cabecera_factura.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cabecera_factura
    @cabecera_factura = CabeceraFactura.find(params[:id])
    if params[:vendedor_id]
      @vendedor_id = params[:vendedor_id]
    end
  end

  # Only allow a trusted parameter "white list" through.
  def cabecera_factura_params
    params.require(:cabecera_factura).permit(:tipo_factura_id, :suplidor_id, :cliente_id, :user_id, :fecha_facturacion, :fecha_vencimiento, :fecha_valida, :numero_comprobante, :numero_factura, :condicion, :Bruto, :forma_pago, :total_factura, :itbis, :descuento, :estado, :tipo, :NoCliente_nombre, :NoCliente_direccion, :costoYgasto,
                                             :pagada, :vendedor_id, :balance, :devuelta, :adelantada, :is_nota, :aplicada_a, :tiene_nota,
                                             detalle_facturas_attributes: [:cabecera_factura_id, :id, :unidad, :articulo_id, :cantidad, :total, :descuento_valor, :descuento_porciento, :itbis, :precio, :descuento_valor, :retirado,
                                                                           :retirado_en_venta, :cantidad_en_unidades])
  end
end
