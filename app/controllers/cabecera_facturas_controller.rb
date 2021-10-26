include ActionView::Helpers::NumberHelper

class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]
  before_action :find_secuencia, only: [:create]
  before_action :find_user, only: [:create]

  # GET /cabecera_facturas
  def index
    # @cabecera_facturas = CabeceraFactura.all
    @get_contenidos = params["get_contenidos"] == "true" ? true : false
    @cabecera_facturas = []
    CabeceraFactura.all.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])
      @cabecera_facturas.push(parsearData(factura))
    end
    
    render json: @cabecera_facturas
  end
  
  # GET /cabecera_facturas/1
  def show
    
    @get_contenidos = params["get_contenidos"] == "true" ? true : false

    @usuario_ = User.find_by_id(@cabecera_factura["user_id"])
    cabecera = parsearData(@cabecera_factura)
    render json: cabecera
  end
  
  def updateFacturaById
    CabeceraFactura.transaction do
      id = params[:id]
      respuesta = CabeceraFactura.updateFactura(id, params, current_user)
      # return render json: {msg:'Esta función esta inhabilitada por reparaciones!!!'}, status: 400
      # raise ActiveRecord::Rollback
      render json: respuesta, status: respuesta[:status]
      
    end
  end
  
  
  def getCantidadDevuelto
    aplicadaA = params[:aplicadaA]
    detalles = CabeceraFactura.getDetallesNotasByFactura(aplicadaA)
    render json: detalles
  end
  
  def getInfoFacturas
    campos = params[:campos]
    ids = params[:ids]
  end

  def verificateCanUpdateById
    id = params[:id]
    render json: CabeceraFactura.verificateCanUpdate(id)
  end

  def getFacturasByParams
    campoNum = params[:campo]
    valor_des = desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\'))
    tipo_factura_id = params[:tipo_factura_id]
    is_adelantada = params[:is_adelantada].to_boolean

    puts "campoNum       : ".cyan + "#{campoNum}"
    puts "is_adelantada  : ".red + "#{is_adelantada}"
    puts "valor_des      : ".yellow + "#{valor_des}"
    puts "tipo_factura_id: ".green + "#{tipo_factura_id}"
    puts "is_adelantada  : ".blue + "#{is_adelantada}"

    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true : false

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
      campo = "last_50"
    end

    facturas = []

    cabe_ = CabeceraFactura.get_facturas_venta_by_params(campo, valor_des, tipo_factura_id, is_adelantada)

    
    if paginado

      facturas = cabe_.to_a.my_paginate(page, per_page)
      puts "facturas --> ".red + "#{facturas.to_json}"
      facturas["data"].each do |factura|
        @usuario_ = User.find_by_id(factura["user_id"])
        cabecera_parsed = parsearData(factura, false, is_adelantada)
        factura = cabecera_parsed unless cabecera_parsed.nil?
      end
    else
      cabe = cabe_

      cabe.each do |factura|
        @usuario_ = User.find_by_id(factura["user_id"])
        cabecera_parsed = parsearData(factura, false, is_adelantada)
        facturas.push(cabecera_parsed) unless cabecera_parsed.nil?
      end
    end



    render json: facturas
  end

  def getViajesSinCompletar
    arg = params["arg"]
    page = params["page"]
    per_page = params["per_page"]
    paginado = params["paginado"] === "true" ? true :  false

    where = "is_viaje = true and ( fecha_completada is null or (fecha_completada between '#{DateTime.now.beginning_of_day}' and '#{DateTime.now.end_of_day}') )"
    
    cabeceras = CabeceraFactura.joins("inner join clientes on clientes.id = cabecera_facturas.cliente_id").where("#{where} and lower(cabecera_facturas.numero_comprobante || ' ' || cabecera_facturas.numero_factura || ' ' || clientes.nombre || ' ' || clientes.apellido) like lower('%#{arg}%') ").to_a
    

    cabeceras_temp = []

    cabeceras.each do |factura|
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
    cabe = CabeceraFactura.get_facturas_by_cliente_id_and_estado(params[:id], params[:pagada]).to_a
    cabe_viajes_contado_deviendo = CabeceraFactura.where({ cliente_id: params[:id], is_viaje: true, condicion: "Contado", estado: true }).where.not(balance: 0).to_a

    cabe.concat cabe_viajes_contado_deviendo

    cabecera = []
    cabe.each do |factura|
      @usuario_ = User.find_by_id(factura["user_id"])

      cabecera.push(parsearData(factura))
    end

    render json: cabecera
  end

  # POST /cabecera_facturas
  def create
    CabeceraFactura.transaction do
      att = cabecera_factura_params

      num_factura_valid = CabeceraFactura.find_by_numero_factura(@numero_factura).nil?

      if num_factura_valid
        resultCliente     = { :error => false }
        resultAgregarNota = { :error => false }

        if att["condicion"] == "Crédito" && att["tipo"] == "venta" || att["is_viaje"]
          resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"], "+")
        end

        # NOTA DE CREDITO
        if att["is_nota"] && att["tipo_factura_id"] == 5
          resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"].to_f.abs, "-")
          resultAgregarNota = CabeceraFactura.agregarNotaACabeceraFactura(@factura_aplicada_id, att)
        end

        # NOTA DE DEBITO
        if att["is_nota"] && att["tipo_factura_id"] == 4
          resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"].to_f.abs, "+")
          resultAgregarNota = CabeceraFactura.agregarNotaACabeceraFactura(@factura_aplicada_id, att)
        end

        if resultCliente[:error]
          render json: resultCliente, status: 400
          raise ActiveRecord::Rollback
        elsif resultAgregarNota[:error]
          render json: resultAgregarNota, status: 400
          raise ActiveRecord::Rollback
        else
          today_cuadre = CuadreCaja.where({ fecha_equivalente: DateTime.now.beginning_of_day..DateTime.now.end_of_day})

          if today_cuadre.empty?
            att["fecha_equivalente"] = att["fecha_equivalente"] ? att["fecha_equivalente"] : DateTime.now
            att["fecha_completada"] = att["condicion"] === "Contado" && !att["is_viaje"] ? att["fecha_equivalente"] : nil
          else
            att["fecha_equivalente"] = att["fecha_equivalente"] ? att["fecha_equivalente"] : CabeceraFactura.calculateNextDay
            att["fecha_completada"] = att["condicion"] === "Contado" && !att["is_viaje"] ? att["fecha_equivalente"] : nil
          end

          att["numero_comprobante"] = @numero_comprobante.upcase
          att["numero_factura"] = @numero_factura

          @cabecera_factura = CabeceraFactura.new(att)

          # return render json: { msg: "pruebas", body: cabecera }
          # raise ActiveRecord::Rollback
          
          unless @cabecera_factura.save
            # render json: @cabecera_factura, status: :created, location: @cabecera_factura
            render json: @cabecera_factura.errors, status: :unprocessable_entity
          else
            update_secuencia
          end
        end
      else
        render json: { :error => true, :msg => "El número de factura ya existe.", :status => 400 }, status: :unprocessable_entity
      end

      
    end
  end

  def articuloWasEdited(articulo)
    if parsearDateTimeUTC(articulo["updated_at"]) != parsearDateTimeUTC(articulo["created_at"]) 
      return false
    else
      return true
    end
  end

  def parsearDate(date)
    return DateTime.parse(date.to_s)
  end

  

  def parsearData(objeto, movimiento_inventario = false, is_adelantada = false)
    resParser = {:error => false, :msg => '', :status => 200}
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
      
      continuar = articuloWasEdited(articuloSelect)


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
      end       
    end

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
      objD["calcular_saco"] = detalleF["calcular_saco"]
      objD["se_calcula_saco"] = Articulo.checkFechaCalcularSaco(objeto["fecha_equivalente"], articuloSelect)

      if @get_contenidos
        objD["contenidos"] = Articulo.calcularContenidos(articuloSelect)
      end
      
      if unidad.length > 1
        if objD["se_calcula_saco"]
          
          objD["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)#{objD["calcular_saco"] ? '' : '*'}"
        else
          objD["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)"
        end
        
        objD["unidad"] = "#{unidad[0]}"
        objD["peso_saco"] = unidad[2]
      else
        objD["descripcion"] = "#{articuloSelect["nombre"]}"
        objD["unidad"] = detalleF["unidad"]
      end
      
      
      unless objeto["is_adelantada"]
        if movimiento_inventario
          unless @actual_secuencia_factura == nil
            factura_tipo = @actual_secuencia_factura["tipo_factura_id"]

            if articuloSelect["medida"] != "Unidad" && ( articuloSelect["contenido_articulos"] == nil || articuloSelect["contenido_articulos"].nil? || articuloSelect["contenido_articulos"].length == 0 )
              my_print_log("articuloSelect ==>  #{articuloSelect.to_json}")
              my_print_log("articuloSelect[contenido_articulos] ==>  #{articuloSelect["contenido_articulos"].to_json}")
              my_print_log("articuloSelect[contenido_articulos].nil? ==>  #{articuloSelect["contenido_articulos"].nil?}")
              array_contenido = ContenidoArticulo.get_contenido_articulo_by_id(articuloSelect["id"])
              begin
                articuloSelect.contenido_articulos = array_contenido
              rescue => exception
                articuloSelect["contenido_articulos"] = array_contenido
              end
              my_print_log("articuloSelect ==>  #{articuloSelect.to_json}")
            end
            

            if factura_tipo != 4 || factura_tipo != "4"
              if articuloSelect["nombre"] != 'Transporte'
                res_mov = CabeceraFactura.movimientos_de_inventario(articuloSelect, objD["cantidad_en_unidades"], params[:FACTURA_DE], 'facturacion' , @cabecera_factura, current_user)

                if res_mov[:error]
                  return {:error => false, :msg=> res_mov[:msg] , :status => 400}
                end

              end
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

    # if !objeto["cliente_id"].nil? || objeto["is_nota"]
    if !objeto["cliente_id"].nil? 
      cli = Cliente.find_by_id(obj["cliente_id"])
      cliente["nombre"] = "#{cli["nombre"]}".titleize + " #{cli["apellido"]}".titleize
      cliente["telefono"] = cli["telefono"]
      cliente["direccion"] = cli["direccion"]
      cliente["rnc"] = cli.documentos_de_identidad.where({ principal: true })[0]["documento"]
    else
      if !objeto["NoCliente_nombre"].nil?
        cliente["nombre"] = objeto["NoCliente_nombre"]
        cliente["telefono"] = nil
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
      usuario = "#{@usuario_["nombre"]} ".titleize + "#{@usuario_["apellido"]}".titleize
      obj["usuario"] = usuario
    end

    if !obj["suplidor_id"].nil?
      supli = Suplidor.find_by_id(obj["suplidor_id"])
      suplidor["nombre"] = "#{supli["nombre"]}".titleize
      suplidor["direccion"] = supli["direccion"]
      suplidor["rnc"] = supli.documentos_de_identidad.where({ principal: true })[0]["documento"]
    end

    obj["notas"] = CabeceraFactura.where({ aplicada_a: objeto["numero_comprobante"] })

    obj["suplidor"] = suplidor
    obj["cliente"] = cliente
    obj["tipo_factura"] = @tipoFactura.descripcion.titleize
    obj["tiene_nota"] = objeto["tiene_nota"]
    obj["is_viaje"] = objeto["is_viaje"]
    obj["fecha_equivalente"] = objeto["fecha_equivalente"]
    obj["fecha_completada"] = objeto["fecha_completada"]
    obj["fecha_viaje"] = objeto["fecha_viaje"]

    pago_ = DetalleRecibo.where({ cabecera_factura_id: objeto["id"] }).order('id DESC').as_json
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
    
    res = CabeceraFactura.anular_factura(params[:id])

    if res
      render json: { msg: "Factura anulada correctamente" }, status: 200
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
        render json: cabecera, status: cabecera[:status], location: @cabecera_factura
      end
    else
      # --------- VENTA / NOTA ---------
      actualizando = { :error => false, :msg => "", :status => 200 }

      if @actual_paquete_comprobante["is_paquete"]
        actualizando = SecuenciaComprobante.aumentar_secuencia_comprobante(@actual_paquete_comprobante["id"])
      end

      unless actualizando["error"]
        unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
          render json: { msg: "Error actualizando la tabla de secuencia de Factura Venta", error: @actual_secuencia_factura.errors }, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        else
          cabecera = parsearData(@cabecera_factura, true)

          render json: cabecera, status: cabecera[:status], location: @cabecera_factura
        end
      else
        render json: { msg: actualizando["msg"] }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

    end
    # end

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
                                              :is_completada, :is_viaje, :fecha_viaje,
                                              detalle_facturas_attributes: [:cabecera_factura_id, :id, :unidad, :articulo_id, :cantidad, :total, :descuento_valor, :descuento_porciento, :itbis, :precio, :descuento_valor, :retirado,
                                                                            :retirado_en_venta, :cantidad_en_unidades, :calcular_saco, :detalle_factura_nota])
  end
end
