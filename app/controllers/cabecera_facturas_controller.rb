include ActionView::Helpers::NumberHelper

class CabeceraFacturasController < ApplicationController
  before_action :set_cabecera_factura, only: [:show, :update, :destroy]
  before_action :find_secuencia, only: [:create]

  # GET /cabecera_facturas
  def index
    # @cabecera_facturas = CabeceraFactura.all
    @cabecera_facturas = []
    CabeceraFactura.all.each do |factura|
      @cabecera_facturas.push(parseal(factura))
    end

    render json: @cabecera_facturas
  end

  # GET /cabecera_facturas/1
  def show
    cabecera = parseal(@cabecera_factura)
    render json: cabecera
  end

  def getFacturasByParams
    campoNum = params[:campo]
    valor_des = desencriptarBase64(params[:valor].gsub(/\b&^IC\b/, '\\'))
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

    cabe = CabeceraFactura.get_facturas_venta_by_params(campo, valor_des)

    puts "=-=".yellow * 20
    puts cabe.to_json
    puts "=-=".yellow * 20

    cabecera = []

    cabe.each do |factura|
      cabecera.push(parseoSelecM(factura))
    end
    puts "/////".red * 20
    puts cabecera.to_json
    render json: cabecera
  end

  def getFacturasByClienteIdAndEstado
    cabe = CabeceraFactura.get_facturas_by_cliente_id_and_estado(params[:id], params[:pagada])

    cabecera = []
    cabe.each do |factura|
      cabecera.push(parseoSelecM(factura))
    end
    # cabecera = parseal(cabe)
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
      if att["condicion"] == "Crédito" && att["tipo"] == "venta"
        resultCliente = Cliente.CalculateBalanceCLiente(att["cliente_id"], att["total_factura"], "+")
      end
      puts resultCliente.to_json.red
      if resultCliente[:error]
        render json: resultCliente
        break
      else
        att["fecha_facturacion"] = att["fecha_facturacion"] ? att["fecha_facturacion"] : DateTime.now
        att["numero_comprobante"] = @numero_comprobante.upcase
        att["numero_factura"] = @numero_factura

        @cabecera_factura = CabeceraFactura.new(att)

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

  def makeContenidoArticulo(contenido)
    contents = []
    contenido.each do |con|
      conte = {}
      conte["id"] = con["id"]
      conte["articulo_id"] = con["articulo_id"]
      conte["referencia"] = con["referencia"]
      conte["costo"] = con["costo"]
      conte["precio"] = con["precio"]
      conte["cantidad"] = con["cantidad"]
      conte["calcular_itbis"] = con["calcular_itbis"]
      conte["condicion"] = con["condicion"]
      conte["medida"] = con["medida"]
      conte["created_at"] = con["created_at"]
      conte["updated_at"] = con["updated_at"]
      contents.push(conte)
    end
    return contents
  end

  def parseoSelecM(objeto)
    puts "--------------- inicio parseoSelecM ---------------"
    obj = objeto

    arrayDetalle = DetalleFactura.where({ cabecera_factura_id: obj["id"] })
    detalleFacturas = []

    arrayDetalle.each do |detalleF|
      objD = {}

      condicionDetalle = ContenidoArticulo.get_condicion_contenido_by_id(detalleF["articulo_id"])

      articuloSelect = Articulo.find_by_id(detalleF["articulo_id"])
      tipoArticulo = TipoArticulo.find_by_id(articuloSelect["tipo_articulo_id"])

      continuar = compareDateFactura(articuloSelect)
      puts ":::::::::::::::::  continuar   :::::::::::::::::"
      puts "                     #{continuar}   "
      puts "::::::::::::::::::::::::::::::::::::::::::::::::"
      unless continuar
        articuloSelect = MantenimientoArticulo.get_one_articulo_by_date(objeto["fecha_facturacion"], articuloSelect["id"])
        articuloSelect = articuloSelect[0]
      end

      precioPrincipal = articuloSelect["precio_principal"]
      costoPrincipal = articuloSelect["costo_principal"]

      tipoArticuloD = tipoArticulo["descripcion"]

      contenidoCantidad = 0
      precio = 0
      costo_calculado = 0

      unidad = detalleF["unidad"].split(" ")

      if unidad.length > 1
        objD["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)"
        objD["unidad"] = "#{unidad[0]}"
      else
        objD["descripcion"] = "#{articuloSelect["nombre"]}"
        objD["unidad"] = detalleF["unidad"]
      end

      if unidad[0] == "Quintal" || unidad[0] == "Caja"
        costo_calculado = costoPrincipal
      elsif unidad[0] == "Saco"
        condicionDetalle.each do |condi|
          if condi["medida"] == "Libra"
            costoC = (unidad[2].to_f * condi["costo"])
            costo_calculado = costoC.to_d.truncate(2).to_f
          end
        end
      else unidad[0] == "Paquete" || unidad[0] == "Libra"
        condicionDetalle.each do |condi|
        if condi["medida"] == unidad[0]
          contenidoCantidad = condi["cantidad"]
          precio = condi["precio"]
          costo_calculado = condi["costo"]
        end
      end       end

      objD["costo"] = costo_calculado
      objD["precio"] = detalleF["precio"]
      objD["total"] = detalleF["total"]
      objD["descuento_valor"] = detalleF["descuento_valor"]
      objD["descuento_porciento"] = detalleF["descuento_porciento"]
      objD["itbis"] = detalleF["itbis"]
      objD["cantidad"] = detalleF["cantidad"]
      objD["tipo"] = tipoArticuloD
      objD["id"] = detalleF["id"]

      # unless objeto["adelantada"]
      #   unless @actual_secuencia_factura == nil
      #     factura_tipo = @actual_secuencia_factura["tipo_factura_id"]

      #     if articuloSelect["contenido_articulos"] == nil
      #       array_contenido = ContenidoArticulo.get_contenido_articulo_by_id(doc["articulo_id"])
      #       articuloSelect["contenido_articulos"] = array_contenido
      #     end

      #     movimientos_de_inventario(factura_tipo, articuloSelect, unidad, objD["cantidad"])
      #   end
      # end

      detalleFacturas.push(objD)
    end

    obj["detalle_facturas"] = detalleFacturas

    puts "??????".blue * 20
    puts arrayDetalle.to_json
    puts "??????".blue * 20

    cliente = {}

    if objeto["cliente_id"]
      cli = Cliente.find_by_id(obj["cliente_id"])
      cliente["nombre"] = "#{cli["nombre"]} #{cli["apellido"]}".titleize
      cliente["direccion"] = cli["direccion"]
      cliente["rnc"] = DocumentoDeIdentidad.where({ principal: true, cliente_id: cli["id"] })[0]["documento"]
    else
      cliente["nombre"] = objeto["NoCliente_nombre"]
      cliente["direccion"] = objeto["NoCliente_direccion"]
      cliente["rnc"] = nil
    end

    if obj["vendedor_id"]
      vendedor_ = User.get_vendedor_by_id(objeto["vendedor_id"])[0]
      vendedor = "#{vendedor_["nombre"]} #{vendedor_["apellido"]}"
      obj["vendedor"] = vendedor
    end

    obj["cliente"] = cliente

    puts "--------------- fin parseoSelecM ---------------"
    puts ""
    puts ""
    return obj
  end

  def parseal(objeto)
    puts "--------------- inicio parseal ---------------"
    puts objeto.to_json
    detalle_facturas = []
    att = objeto.attributes
    # att = objeto

    if objeto["tipo"] === "venta"
      cliente = {}

      if objeto["cliente_id"]
        cliente["nombre"] = "#{objeto.cliente["nombre"]} #{objeto.cliente["apellido"]}".titleize
        cliente["direccion"] = objeto.cliente["direccion"]
        cliente["rnc"] = DocumentoDeIdentidad.where({ principal: true, cliente_id: objeto.cliente["id"] })[0]["documento"]
      else
        cliente["nombre"] = objeto["NoCliente_nombre"]
        cliente["direccion"] = objeto["NoCliente_direccion"]
        cliente["rnc"] = nil
      end
    else
      suplidor = {}
      suplidor["nombre"] = objeto.suplidor["nombre"]
      suplidor["direccion"] = objeto.suplidor["direccion"]
      suplidor["rnc"] = DocumentoDeIdentidad.where({ principal: true, suplidor_id: objeto.suplidor["id"] })[0]["documento"]
    end

    responsableFact = User.find_by_id(objeto["user_id"])

    usuario = "#{responsableFact["nombre"]} #{responsableFact["apellido"]}"

    if objeto["vendedor_id"]
      vendedor_ = User.get_vendedor_by_id(objeto["vendedor_id"])[0]
      vendedor = "#{vendedor_["nombre"]} #{vendedor_["apellido"]}".titleize
      att["vendedor"] = vendedor
    end

    objeto.detalle_facturas.each do |doc|
      objD = {}

      condicionDetalle = ContenidoArticulo.get_condicion_contenido_by_id(doc["articulo_id"])

      articuloSelect = Articulo.find_by_id(doc["articulo_id"])
      tipoArticulo = TipoArticulo.find_by_id(articuloSelect["tipo_articulo_id"])

      continuar = compareDateFactura(articuloSelect)
      puts ":::::::::::::::::  continuar   :::::::::::::::::"
      puts "                     #{continuar}   "
      puts "::::::::::::::::::::::::::::::::::::::::::::::::"
      unless continuar
        articuloSelect = MantenimientoArticulo.get_one_articulo_by_date(objeto["fecha_facturacion"], articuloSelect["id"])
        articuloSelect = articuloSelect[0]
      end

      puts "=====".blue * 20
      puts "=====".blue * 20
      puts "=====".blue * 20
      puts "=====".blue * 20
      puts "=====".blue * 20
      puts articuloSelect.to_json

      precioPrincipal = articuloSelect["precio_principal"]
      costoPrincipal = articuloSelect["costo_principal"]

      tipoArticuloD = tipoArticulo["descripcion"]

      contenidoCantidad = 0
      precio = 0
      costo_calculado = 0

      unidad = doc["unidad"].split(" ")

      if unidad.length > 1
        objD["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)"
        objD["unidad"] = "#{unidad[0]}"
      else
        objD["descripcion"] = "#{articuloSelect["nombre"]}"
        objD["unidad"] = doc["unidad"]
      end

      if unidad[0] == "Quintal" || unidad[0] == "Caja"
        costo_calculado = costoPrincipal
      elsif unidad[0] == "Saco"
        condicionDetalle.each do |condi|
          if condi["medida"] == "Libra"
            costoC = (unidad[2].to_f * condi["costo"])
            costo_calculado = costoC.to_d.truncate(2).to_f
          end
        end
      else unidad[0] == "Paquete" || unidad[0] == "Libra"
        condicionDetalle.each do |condi|
        if condi["medida"] == unidad[0]
          contenidoCantidad = condi["cantidad"]
          precio = condi["precio"]
          costo_calculado = condi["costo"]
        end
      end       end

      objD["costo"] = costo_calculado
      objD["precio"] = doc["precio"]
      objD["total"] = doc["total"]
      objD["descuento_valor"] = doc["descuento_valor"]
      objD["descuento_porciento"] = doc["descuento_porciento"]
      objD["itbis"] = doc["itbis"]
      objD["cantidad"] = doc["cantidad"]
      objD["tipo"] = tipoArticuloD
      objD["id"] = doc["id"]

      unless objeto["adelantada"]
        unless @actual_secuencia_factura == nil
          factura_tipo = @actual_secuencia_factura["tipo_factura_id"]

          if articuloSelect["contenido_articulos"] == nil
            array_contenido = ContenidoArticulo.get_contenido_articulo_by_id(doc["articulo_id"])
            articuloSelect["contenido_articulos"] = array_contenido
          end

          movimientos_de_inventario(factura_tipo, articuloSelect, unidad, objD["cantidad"])
        end
      end

      detalle_facturas.push(objD)
    end

    att["detalle_facturas"] = detalle_facturas
    att["cliente"] = cliente
    att["usuario"] = usuario
    att["suplidor"] = suplidor
    att["tipo_factura"] = objeto.tipo_factura["descripcion"]

    puts "--------------- fin parseal ---------------"
    puts " "
    puts " "
    return att
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
    res = CabeceraFactura.cancelar_factura(params[:id])

    if res
      render json: { msg: "Factura anulada correctamente", status: 200 }, status: 200
    else
      render json: { msg: "Error anulando factura" }, status: :unprocessable_entity
    end
  end

  def update_secuencia
    CabeceraFactura.transaction do
      if @actual_secuencia_factura["tipo_factura_id"] == 13
        # --------- VENTA ---------
        actualizando = SecuenciaComprobante.aumentar_secuencia_venta(@actual_secuencia_comprobante["id"])
        unless actualizando
          render json: { msg: "Error actualizando la tabla de secuencia de comprobante Venta" }, status: :unprocessable_entity
          # render json: @actual_secuencia_comprobante.errors, status: :unprocessable_entity
        else
          unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
            render json: { msg: "Error actualizando la tabla de secuencia de Factura Venta" }, status: :unprocessable_entity
            # render json: @actual_secuencia_factura.errors, status: :unprocessable_entity
          else
            cabecera = parseal(@cabecera_factura)
            render json: cabecera, status: :created, location: @cabecera_factura
          end
        end
      else
        # --------- COMPRA ---------

        unless @actual_secuencia_factura.update({ secuencia: @next_secuencia_factura })
          render json: { msg: "Error actualizando la tabla de secuencia de Factura Compra" }, status: :unprocessable_entity
        else
          cabecera = parseal(@cabecera_factura)
          render json: cabecera, status: :created, location: @cabecera_factura
        end
      end
    end
  end

  def movimientos_de_inventario(accion, articulo, unidad, cantidad)
    medida = unidad[0]
    cantSacos = 0
    cantSacos = unidad[2].to_f

    if cantidad == nil
      cantidad = 0
    end

    cantPrincipal = 1
    cantPadre = 0
    cantHijo = 1
    maxCant = 1

    if medida === "Saco"
      medida = "Libra"
    end

    medidaEs = ""
    if medida == articulo["medida"]
      medidaEs = "principal"
    end

    if articulo["contenido_articulos"].length === 0
      cantPrincipal = 1
    else
      articulo["contenido_articulos"].each do |contenido|
        cantPrincipal = contenido["cantidad"] * cantPrincipal
        if contenido["condicion"] == "hijo"
          cantPadre = contenido["cantidad"]
        end
        if contenido["condicion"] == "padre"
          if contenido["medida"] == "Libra" || contenido["medida"] == "Unidad"
            cantPadre = 1
          end

          if medida == contenido["medida"]
            medidaEs = "padre"
          end
        else
          if medida == contenido["medida"]
            medidaEs = "hijo"
          end
        end
      end
    end

    if medidaEs == "principal"
      maxCant = cantPrincipal
    elsif medidaEs == "padre"
      maxCant = cantPadre
    else
      maxCant = cantHijo
    end

    if cantSacos > 0 && medida == "Libra"
      maxCant = cantSacos.to_f
    end

    puts "cantPrincipal #{cantPrincipal}"
    puts "cantPadre #{cantPadre}"
    puts "cantHijo #{cantHijo}"
    puts ""
    puts "cantidad #{cantidad}"
    puts "medidaEs #{medidaEs}"

    cant = (maxCant * cantidad)

    if accion == 13
      # --------- VENTA ---------
      puts " estas vendiendo #{cant} "
      movimiento = Articulo.find_by_id(articulo["id"])
      mov = (movimiento["existencia"] - cant)
      if movimiento.update({ existencia: mov })
        puts "::::::::::::::::::::::::::::::::::::::::::"
        puts "::::                                  ::::"
        puts "::::        VENTA EXITOSA             ::::"
        puts "::::                                  ::::"
        puts "::::::::::::::::::::::::::::::::::::::::::"
      end
    else
      # --------- COMPRA ---------
      puts " estas comprando #{cant} "
      movimiento = Articulo.find_by_id(articulo["id"])
      mov = (movimiento["existencia"] + cant)
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
    if params["tipo"] == "venta"
      @actual_secuencia_comprobante = SecuenciaComprobante.get_paquete_rnc_by_estado(params[:tipo_factura_id], true)
      if @actual_secuencia_comprobante[:error]
        return render :json => @actual_secuencia_comprobante, status: @actual_secuencia_comprobante[:status]
      end
      @actual_secuencia_comprobante = @actual_secuencia_comprobante[:body]
      @next_secuencia_comprobante = @actual_secuencia_comprobante["secuencia"]
    end

    @tipoFactura = TipoFactura.find_by_id(params[:tipo_factura_id])
    @actual_secuencia_factura = SecuenciaFactura.find_by_tipo_factura_id(params[:FACTURA_DE])

    @next_secuencia_factura = @actual_secuencia_factura["secuencia"] + 1

    @numero_factura = @next_secuencia_factura

    if @actual_secuencia_factura["tipo_factura_id"] == 13
      # --------- VENTA ---------
      @numero_comprobante = "B" + @tipoFactura["referencia"] + ("%08d" % @next_secuencia_comprobante)
    else
      # --------- COMPRA ---------
      @numero_comprobante = cabecera_factura_params["numero_comprobante"].upcase
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
                                             :pagada, :vendedor_id, :balance, :devuelta, :adelantada, :is_nota, :aplicada_a,
                                             detalle_facturas_attributes: [:cabecera_factura_id, :id, :unidad, :articulo_id, :cantidad, :total, :descuento_valor, :descuento_porciento, :itbis, :precio, :descuento_valor])
  end
end
