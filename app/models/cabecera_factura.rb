class CabeceraFactura < ApplicationRecord
  belongs_to :user

  attribute :cliente
  attribute :suplidor
  attribute :tipo_factura

  has_many :detalle_facturas, dependent: :destroy
  attribute :detalle_facturas
  accepts_nested_attributes_for :detalle_facturas, :allow_destroy => true
  # ===================================================================================================================================================
  def self.get_facturas_venta_by_params(campo, valor, tipo_factura_id, adelantada)
    puts "campo ".red + "#{campo}"
    puts "valor ".green + "#{valor}"

    select_ = 'SELECT ca.id, tipo_factura_id ,tf.descripcion as tipo_factura, suplidor_id, cliente_id, user_id, fecha_facturacion, fecha_vencimiento, fecha_valida, numero_comprobante, numero_factura, condicion, forma_pago, total_factura, itbis, descuento, ca.estado, tipo, ca.created_at, ca.updated_at, ca."Bruto", ca."NoCliente_nombre", ca."NoCliente_direccion", pagada, ca.vendedor_id, ca.balance, ca.devuelta, ca.adelantada, ca.is_nota, ca.aplicada_a, ca.tiene_nota,
    CONCAT(u.nombre, ' + "' '" + ", u.apellido)as usuario"
    from_ = "FROM cabecera_facturas ca"
    joins_ = "inner join tipo_facturas tf on ca.tipo_factura_id = tf.id
    inner join users u on ca.user_id = u.id"
    where_ = ""

    if tipo_factura_id == 0 || tipo_factura_id == "0"
      if campo == "numero_comprobante"
        where_ = "WHERE #{campo} = '#{valor}' and tipo = 'venta' and adelantada = #{adelantada}"
      else
        where_ = "WHERE #{campo} = #{valor} and tipo = 'venta' and adelantada = #{adelantada}"
      end
    else
      if campo == "numero_comprobante"
        where_ = "WHERE #{campo} = '#{valor}' and tipo = 'venta' and tipo_factura_id = #{tipo_factura_id} and adelantada = #{adelantada}"
      else
        where_ = "WHERE #{campo} = #{valor} and tipo = 'venta' and tipo_factura_id = #{tipo_factura_id} and adelantada = #{adelantada}"
      end
    end

    query = "#{select_} #{from_} #{joins_} #{where_}"

    return my_query(query)
  end
  # ===================================================================================================================================================
  def self.get_facturas_by_cliente_id_and_estado(cliente_id, pagada)
    select_ = 'SELECT ca.id, tipo_factura_id ,tf.descripcion as tipo_factura, suplidor_id, cliente_id, user_id, fecha_facturacion, fecha_vencimiento, fecha_valida, numero_comprobante, numero_factura, condicion, forma_pago, total_factura, itbis, descuento, ca.estado, tipo, ca.created_at, ca.updated_at, ca."Bruto", ca."NoCliente_nombre", ca."NoCliente_direccion", pagada, ca.vendedor_id, ca.balance, ca.devuelta, ca.adelantada, ca.is_nota, ca.aplicada_a, ca.tiene_nota,
    CONCAT(u.nombre, ' + "' '" + ", u.apellido)as usuario"
    from_ = "FROM cabecera_facturas ca"
    joins_ =
      "inner join tipo_facturas tf on ca.tipo_factura_id = tf.id
    inner join users u on ca.user_id = u.id"
    where_ = " WHERE cliente_id=#{cliente_id} and pagada=#{pagada} and tipo='venta'"
    query = "#{select_} #{from_} #{joins_} #{where_}"
    return my_query(query)
  end
  # ===================================================================================================================================================

  def self.get_facturas_by_cliente_id(cliente_id)
    select_ = 'SELECT ca.id, tipo_factura_id ,tf.descripcion as tipo_factura, suplidor_id, cliente_id, user_id, fecha_facturacion, fecha_vencimiento, fecha_valida, numero_comprobante, numero_factura, condicion, forma_pago, total_factura, itbis, descuento, ca.estado, tipo, ca.created_at, ca.updated_at, ca."Bruto", ca."NoCliente_nombre", ca."NoCliente_direccion", pagada, ca.vendedor_id, ca.balance, ca.devuelta, ca.adelantada, ca.is_nota, ca.aplicada_a, ca.tiene_nota,
    CONCAT(u.nombre, ' + "' '" + ", u.apellido)as usuario"
    from_ = "FROM cabecera_facturas ca"
    joins_ =
      "inner join tipo_facturas tf on ca.tipo_factura_id = tf.id
    inner join users u on ca.user_id = u.id"
    where_ = " WHERE cliente_id=#{cliente_id} and tipo='venta'"
    query = "#{select_} #{from_} #{joins_} #{where_}"

    return my_query(query)
  end

  # ====================================================================================================
  def self.payFacturas(facturas)
    res = { error: false, msg: "facturas actualizadas" }
    facturas["detalle_recibos_attributes"].each do |f|
      factura_a_pagar = CabeceraFactura.find_by_id(f["cabecera_factura_id"])

      if factura_a_pagar["tiene_nota"]
        monto_editado_por_notas = 0
        notas = CabeceraFactura.where({ aplicada_a: factura_a_pagar["numero_comprobante"] })
        notas.each do |nota|
          if nota["tipo_factura_id"] === 5
            monto_editado_por_notas = monto_editado_por_notas - nota["total_factura"].abs
          elsif nota["tipo_factura_id"] === 4
            monto_editado_por_notas = monto_editado_por_notas + nota["total_factura"].abs
          end
        end
        factura_a_pagar["balance"] = factura_a_pagar["balance"] + monto_editado_por_notas
      end

      if f["pago_total"]
        if f["deposito"] == factura_a_pagar["balance"]
          unless factura_a_pagar.update({ balance: 0, pagada: true })
            res = { error: true, msg: factura_a_pagar.errors }
            return res
          end
        else
          res = { error: true, msg: factura_a_pagar.errors }
          return res
        end
      else
        # si la factura tiene una nota le quito el valor modificado
        if factura_a_pagar["tiene_nota"]
          factura_a_pagar["balance"] = factura_a_pagar["balance"] - monto_editado_por_notas
        end

        newBalance = factura_a_pagar["balance"] - f["deposito"]

        # si la factura tiene una nota le agrego el valor modificado
        if factura_a_pagar["tiene_nota"]
          balance = factura_a_pagar["balance"] + monto_editado_por_notas
        else
          balance = factura_a_pagar["balance"]
        end

        if f["deposito"] == balance
          unless factura_a_pagar.update({ balance: newBalance, pagada: true })
            res = { error: true, msg: factura_a_pagar.errors }
            return res
          end
        else
          unless factura_a_pagar.update({ balance: newBalance })
            res = { error: true, msg: factura_a_pagar.errors }
            return res
          end
        end
      end
    end
    return res
  end

  # =====================================================================================================================
  def self.anular_factura(id)
    puts "ANTES DE ENTRAR EN LA FUNCION QUE CAMBIA EL ESTADO".yellow
    peticion = my_query("UPDATE cabecera_facturas SET estado=#{false} WHERE id=#{id}")

    if peticion
      return true
    else
      return false
    end
  end
  # =====================================================================================================================
  def self.ReCalculateBalanceFactura(id, totalFactura, operacion)
    puts " -------------- Inicio ReCalculateBalanceFactura -------------- "

    factura = CabeceraFactura.find_by_id(id)
    puts "-----".blue * 15
    puts "factura" + factura.to_json
    puts "-----".blue * 15
    balance = factura["balance"]

    if operacion == "+"
      sumatoria = balance + totalFactura.to_f
    else
      if totalFactura.to_f > balance
        return { :error => true, :msg => "El monto ingresado es mayor al balance de la factura", :status => 400 }
      else
        sumatoria = balance - totalFactura.to_f
      end
    end
    sumatoria = sumatoria.to_d.truncate(2).to_f

    unless factura.update({ balance: sumatoria })
      puts " -------------- fin ReCalculateBalanceFactura -------------- "
      return { :error => true, :msg => "Error actualizanco el balance de la factura", :status => 400 }
    else
      puts " -------------- fin ReCalculateBalanceFactura -------------- "
      return { :error => false, :balance => sumatoria }
    end
  end
  # =====================================================================================================================
  def self.agregarNotaACabeceraFactura(id)
    puts " -------------- Inicio agregarNotaACabeceraFactura -------------- "

    factura = CabeceraFactura.find_by_id(id)
    unless factura.update({ tiene_nota: true })
      puts " -------------- fin agregarNotaACabeceraFactura -------------- "
      return { :error => true, :msg => "Error agregando nota la factura", :status => 400 }
    else
      puts " -------------- fin agregarNotaACabeceraFactura -------------- "
      return { :error => false, :tiene_nota => true }
    end
  end

  # =====================================================================================================================

  def parsearDate(date)
    return DateTime.parse(date.to_s)
  end

  # =====================================================================================================================
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

  # =====================================================================================================================
  def compareDateFactura(articulo)
    if parsearDate(articulo["updated_at"]) != parsearDate(articulo["created_at"])
      return false
    else
      return true
    end
  end

  # =====================================================================================================================
  def self.parsearData(objeto, factura_de)
    CabeceraFactura.transaction do
      puts "--------------- inicio parsearData ---------------"

      begin
        obj = objeto.attributes
      rescue
        obj = objeto
      end

      arrayDetalle = DetalleFactura.where({ cabecera_factura_id: obj["id"] })
      detalleFacturas = []

      puts "obj -->".blue, " #{obj}"
      puts "detalleFacturas --> #{detalleFacturas}".red
      arrayDetalle.each do |detalleF|
        objD = {}
        # =-=-=-=-=
        condicionDetalle = ContenidoArticulo.get_condicion_contenido_by_id(detalleF["articulo_id"])
        # =-=-=-=-=

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

        contenidoCantidad = 0

        objD["descripcion"] = "#{articuloSelect["nombre"]}"
        objD["unidad"] = detalleF["unidad"]

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
        objD["tipo"] = tipoArticuloD
        objD["id"] = detalleF["id"]
        objD["retirado"] = detalleF["retirado"]

        if articuloSelect["contenido_articulos"] == nil
          array_contenido = ContenidoArticulo.where({ id: articuloSelect["id"] })
          articuloSelect["contenido_articulos"] = array_contenido
        end

        movimientos_de_inventario(factura_de, articuloSelect, detalleF["unidad"], objD["cantidad"], detalleF["medida_es"])

        # puts "****" * 20
        # puts objD
        detalleFacturas.push(objD)
        puts "****".yellow * 20
      end

      puts detalleFacturas.to_json.blue

      # obj["detalle_facturas"] = []
      obj["detalle_facturas"] = detalleFacturas

      puts "*" * 20
      puts obj["detalle_facturas"].to_json

      puts obj.to_json.yellow
      cliente = {}

      if objeto["cliente_id"] || objeto["is_nota"]
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

      obj["notas"] = CabeceraFactura.where({ aplicada_a: objeto["numero_comprobante"] })

      obj["cliente"] = cliente
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
  end

  # =====================================================================================================================

  def movimientos_de_inventario(accion, articulo, unidad, cantidad, medida_es)
    medida = unidad

    if cantidad == nil
      cantidad = 0
    end

    cantPrincipal = 1
    cantPadre = 0
    cantHijo = 1
    maxCant = 1

    if articulo["contenido_articulos"].length > 0
      articulo["contenido_articulos"].each do |contenido|
        cantPrincipal = contenido["cantidad"] * cantPrincipal

        if contenido["condicion"] == "padre"
          cantPadre = contenido["cantidad"]
        end
      end
    end

    if medida_es == "principal"
      maxCant = cantPrincipal
    elsif medida_es == "padre"
      maxCant = cantPadre
    else
      maxCant = cantHijo
    end

    puts "cantPrincipal #{cantPrincipal}"
    puts "cantPadre #{cantPadre}"
    puts "cantHijo #{cantHijo}"
    puts ""
    puts "cantidad #{cantidad}"
    puts "medida_es #{medida_es}"

    cant = (maxCant * cantidad)

    if accion == "Venta"
      # --------- VENTA ---------
      puts " estas vendiendo #{cant} "
      movimiento = Articulo.find_by_id(articulo["id"])
      mov = (movimiento["existencia"] - cant)
      puts " existencia actual #{cant} "

      # if movimiento.update({ existencia: mov })
      #   puts "::::::::::::::::::::::::::::::::::::::::::"
      #   puts "::::                                  ::::"
      #   puts "::::        VENTA EXITOSA             ::::"
      #   puts "::::                                  ::::"
      #   puts "::::::::::::::::::::::::::::::::::::::::::"
      # end
    else
      # --------- COMPRA ---------
      puts " estas comprando #{cant} "
      movimiento = Articulo.find_by_id(articulo["id"])
      mov = (movimiento["existencia"] + cant)
      # if movimiento.update({ existencia: mov })
      #   puts "::::::::::::::::::::::::::::::::::::::::::"
      #   puts "::::                                  ::::"
      #   puts "::::         COMPRA EXITOSA           ::::"
      #   puts "::::                                  ::::"
      #   puts "::::::::::::::::::::::::::::::::::::::::::"
      # end
    end
  end

  # =====================================================================================================================
end
