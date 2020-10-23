include ActionView::Helpers::NumberHelper

class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]
  before_action :find_secuencia, only: [:create]
  before_action :find_user, only: [:create]

  # GET /cabecera_facturas
  def index
    # @cabecera_facturas = CabeceraFactura.all
    @cabecera_facturas = []
    CabeceraFactura.all.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])
      @cabecera_facturas.push(parsearData(factura))
    end

    render json: @cabecera_facturas
  end

  # GET /cabecera_facturas/1
  def show
    @usuario_ = User.find_by_id(@cabecera_factura["user_id"])
    cabecera = parsearData(@cabecera_factura)
    render json: cabecera
  end

  def getFacturasByParams
    campoNum = params[:campo]
    valor_des = desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\'))
    tipo_factura_id = params[:tipo_factura_id]
    is_adelantada = params[:is_adelantada]

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

    my_print_log("campo  ==> #{campo}".green)
    my_print_log("valor_des  ==> #{valor_des}".green)

    cabe = CabeceraFactura.get_facturas_venta_by_params(campo, valor_des, tipo_factura_id, is_adelantada)

    puts "=-=".yellow * 20
    puts cabe.to_json
    puts "=-=".yellow * 20

    cabecera = []

    cabe.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])
      cabecera_parsed = parsearData(factura, false, is_adelantada)

      my_print_log("cabecera_parsed  ==> #{cabecera_parsed}".green)
      cabecera.push(cabecera_parsed) unless cabecera_parsed.nil?
    end
    puts "/////".red * 20
    my_print_log("cabecera  ==> #{cabecera}".green)
    puts cabecera.to_json
    render json: cabecera
  end

  def getViajesSinCompletar
    arg = params["arg"]
    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

    cabe_pendientes = CabeceraFactura.where({ is_viaje: true, fecha_completada: nil })
    cabe_completadas_hoy = CabeceraFactura.where({ is_viaje: true, fecha_completada: DateTime.now.beginning_of_day..DateTime.now.end_of_day })

    cabeceras_temp = []
    cabe_pendientes.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])
      cabeceras_temp.push(parsearData(factura))
    end

    cabe_completadas_hoy.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])
      cabeceras_temp.push(parsearData(factura))
    end

    res_cabecera = []

    if paginado
      res_cabecera = cabeceras_temp.to_a.my_paginate(page, per_page)
    end

    render json: res_cabecera
  end

  def getFacturasByClienteIdAndEstado
    cabe = CabeceraFactura.get_facturas_by_cliente_id_and_estado(params[:id], params[:pagada])

    cabecera = []
    cabe.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])
      my_print_log("@tipoFactura ".red + "#{@tipoFactura.to_json}".white)
      cabecera.push(parsearData(factura))
    end
    # cabecera = parsearData(cabe)
    render json: cabecera
  end

  # POST /cabecera_facturas
  def create
    CabeceraFactura.transaction do
      att = cabecera_factura_params

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
        att["fecha_equivalente"] = att["fecha_equivalente"] ? att["fecha_equivalente"] : DateTime.now
        att["numero_comprobante"] = @numero_comprobante.upcase
        att["numero_factura"] = @numero_factura

        @cabecera_factura = CabeceraFactura.new(att)

        puts @cabecera_factura.to_json
        # return render json: { msg: "pruebas", body: cabecera }
        # raise ActiveRecord::Rollback
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

  def parsearData(objeto, movimiento_inventario = false, is_adelantada = false)
    puts "--------------- inicio parsearData ---------------"

    begin
      obj = objeto.attributes
      obj["detalle_facturas"] = objeto.detalle_facturas.to_a

      obj["user"] = objeto.user
      obj["cliente"] = objeto.cliente
      obj["suplidor"] = objeto.suplidor
      obj["tipo_factura"] = objeto.tipo_factura
    rescue
      obj = objeto
    end

    @tipoFactura = TipoFactura.find_by_id(obj["tipo_factura_id"])

    arrayDetalle = DetalleFactura.where({ cabecera_factura_id: obj["id"] })
    detalleFacturas = []
    contador_retirado = 0
    arrayDetalle.each do |detalleF|
      objD = {}

      contenidoArticulo = ContenidoArticulo.where({ articulo_id: detalleF["articulo_id"] })

      articuloSelect = Articulo.find_by_id(detalleF["articulo_id"])
      tipoArticulo = TipoArticulo.find_by_id(articuloSelect["tipo_articulo_id"])

      continuar = compareDateFactura(articuloSelect)

      unless continuar
        articuloSelect = MantenimientoArticulo.get_one_articulo_by_date(objeto["fecha_equivalente"], articuloSelect["id"])
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

      unless objeto["is_adelantada"]
        if movimiento_inventario
          unless @actual_secuencia_factura == nil
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

      if is_adelantada && (objD["retirado"] < objD["cantidad_en_unidades"])
        contador_retirado += 1
      end

      detalleFacturas.push(objD)
    end

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
      my_print_log(":::::::::::: #{@usuario_.to_json}".red)
      usuario = "#{@usuario_["nombre"]} ".titleize + "#{@usuario_["apellido"]}".titleize
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
        detalle_recibo["recibo_created_at"] = recibo["fecha_equivalente"]
        detalle_recibo
      end
    end

    obj["pagos"] = pago_parseo

    puts "--------------- fin parsearData ---------------"
    puts ""
    puts ""
    my_print_log("obj ==> #{obj}".yellow)
    my_print_log("is_adelantada ==> #{is_adelantada}".yellow)
    my_print_log("contador_retirado ==> #{contador_retirado}".yellow)
    if !is_adelantada || (is_adelantada && contador_retirado > 0)
      return obj
    else
      return nil
    end
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
      articulo = Articulo.find_by_id(articulo["id"])
      puts "articulo['existencia']".blue, articulo["existencia"]
      puts "cantidad_en_unidades".green, cantidad_en_unidades

      mov = (articulo["existencia"] - cantidad_en_unidades)

      puts " estas vendiendo #{cantidad_en_unidades} "
      puts " inventario queda en  #{mov} "
      if mov < 0
        mensaje = "Cantidad introducida para el articulo #{articulo.nombre.titleize}  ahora excede la cantidad disponible en inventario. "
        render json: { msg: mensaje }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
      if articulo.update({ existencia: mov })
        puts "::::::::::::::::::::::::::::::::::::::::::"
        puts "::::                                  ::::"
        puts "::::        VENTA EXITOSA             ::::"
        puts "::::                                  ::::"
        puts "::::::::::::::::::::::::::::::::::::::::::"
      else
        render json: articulo.errors, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    else
      # --------- COMPRA ---------
      articulo = Articulo.find_by_id(articulo["id"])
      puts "articulo['existencia']".red + "#{articulo["existencia"]}".white
      puts "cantidad_en_unidades".red + "#{cantidad_en_unidades}".white
      mov = (articulo["existencia"] + cantidad_en_unidades)

      fecha_fact = @cabecera_factura.fecha_equivalente.strftime("%d/%m/%Y")

      obj = {
        user_id: @usuario_["id"],
        articulo_id: articulo["id"],
        cantidad: cantidad_en_unidades,
        accion: "entrada",
        motivo: "Compra de mercancia en la factura con el ncf: " + @numero_comprobante + " de la fecha " + fecha_fact,
        medida: "Unidades",
        tipo_salida: nil,
      }

      movimientos_inventario = MovimientosInventario.new(obj)

      if movimientos_inventario.save!
        if articulo.update({ existencia: mov })
          puts "::::::::::::::::::::::::::::::::::::::::::"
          puts "::::                                  ::::"
          puts "::::         COMPRA EXITOSA           ::::"
          puts "::::                                  ::::"
          puts "::::::::::::::::::::::::::::::::::::::::::"
        else
          render json: articulo.errors, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      else
        return render json: movimientos_inventario.errors, status: :unprocessable_entity
      end
    end
  end

  def find_user
    @usuario_ = User.find_by_id(params["user_id"])
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
    params.require(:cabecera_factura).permit(:tipo_factura_id, :suplidor_id, :cliente_id, :user_id, :fecha_equivalente, :fecha_vencimiento, :fecha_valida, :numero_comprobante, :numero_factura, :condicion, :Bruto, :forma_pago, :total_factura, :itbis, :descuento, :estado, :tipo, :NoCliente_nombre, :NoCliente_direccion, :costoYgasto,
                                             :pagada, :vendedor_id, :balance, :devuelta, :is_adelantada, :is_nota, :aplicada_a, :tiene_nota,
                                             :is_completada, :is_viaje,
                                             detalle_facturas_attributes: [:cabecera_factura_id, :id, :unidad, :articulo_id, :cantidad, :total, :descuento_valor, :descuento_porciento, :itbis, :precio, :descuento_valor, :retirado,
                                                                           :retirado_en_venta, :cantidad_en_unidades])
  end
end
