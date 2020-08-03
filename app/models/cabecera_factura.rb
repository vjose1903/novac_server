class CabeceraFactura < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :suplidor, optional: true
  belongs_to :cliente, optional: true
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
end
