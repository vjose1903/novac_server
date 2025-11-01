class CuadreCaja < ApplicationRecord
  belongs_to :user

  def self.makecuadre(params)
    res              = Response.new
    current_user     = get_current_user

    fecha            = params[:fecha] ? params[:fecha] : DateTime.now
    cuadre           = CuadreCaja.where("fecha_equivalente::date='#{fecha}'").includes(:user)


    if cuadre.empty?
      ventas_credito_total_facturado_ = 0
      ventas_contado_total_facturado_ = 0

      # Totales base de facturas
      ventas_contado_total_facturado_    = CabeceraFactura.where("( forma_pago = 'Efectivo' OR forma_pago = 'Cheque' OR forma_pago ='Tarjeta' OR forma_pago = 'Transferencia' ) and fecha_equivalente::date='#{fecha}' and fecha_completada::date='#{fecha}' and lower(tipo)='venta' and lower(condicion)='contado' AND estado=true").sum(:total_factura)
      ventas_credito_total_facturado_    = CabeceraFactura.where("fecha_equivalente::date='#{fecha}' and lower(tipo)='venta' and lower(condicion)='crédito' AND estado=true").sum(:total_factura)

      # Ajustes por notas de crédito/débito en una consulta SQL directa
      ajuste_contado = FacturaAplicada.joins(:cabecera_factura, :tipo_factura)
        .where("cabecera_facturas.forma_pago IN ('Efectivo', 'Cheque', 'Tarjeta', 'Transferencia') 
                AND cabecera_facturas.fecha_equivalente::date = '#{fecha}' 
                AND cabecera_facturas.fecha_completada::date = '#{fecha}' 
                AND LOWER(cabecera_facturas.tipo) = 'venta' 
                AND LOWER(cabecera_facturas.condicion) = 'contado' 
                AND cabecera_facturas.estado = true
                AND tipo_facturas.key IN ('nota_de_credito', 'nota_de_debito')")
        .sum("CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END")

      ajuste_credito = FacturaAplicada.joins(:cabecera_factura, :tipo_factura)
        .where("cabecera_facturas.fecha_equivalente::date = '#{fecha}' 
                AND LOWER(cabecera_facturas.tipo) = 'venta' 
                AND LOWER(cabecera_facturas.condicion) = 'crédito' 
                AND cabecera_facturas.estado = true
                AND tipo_facturas.key IN ('nota_de_credito', 'nota_de_debito')")
        .sum("CASE WHEN tipo_facturas.key = 'nota_de_debito' THEN facturas_aplicadas.total ELSE -facturas_aplicadas.total END")

      ventas_contado_total_facturado_ += ajuste_contado || 0
      ventas_credito_total_facturado_ += ajuste_credito || 0

      recibos_ingresos_                  = RecibosIngreso.where("( forma_pago = 'Efectivo' OR forma_pago = 'Cheque' OR forma_pago ='Tarjeta' OR forma_pago = 'Transferencia' ) and fecha_equivalente::date='#{fecha}' AND estado=true").sum(:total)

      obj = {
        user_id:              current_user.id,
        total_general:        (ventas_contado_total_facturado_ + recibos_ingresos_).round(2),
        total_venta_credito:  ventas_credito_total_facturado_,
        total_venta_contado:  ventas_contado_total_facturado_,
        total_recibo_ingreso: recibos_ingresos_,
        total_anterior:       0,
        fecha_equivalente:    DateTime.now -  (Date.today - Date.parse(params[:fecha])).to_i.day,
        numero_reporte:       CuadreCaja.find_numero_reporte,
      }

      cuadre            = CuadreCaja.new(obj)

      CuadreCaja.transaction do
        if cuadre.save!
          att             = cuadre.attributes
          att['usuario']  = current_user.nombre_completo

          att['contenido_reporte']  = [
						{descripcion: 'facturas_contado', titulo: 'Total facturado a contado', valor: att['total_venta_contado'] },
            {descripcion: 'recibos_ingresos', titulo: 'Total recibo de ingreso',   valor: att['total_recibo_ingreso'] },
            {descripcion: 'total_anterior', 	titulo: 'Total día anterior',        valor: att['total_anterior'] },
            {descripcion: 'total_general', 		titulo: 'Total en caja',             valor: att['total_general'] },
            {descripcion: 'facturas_credito', titulo: 'Total facturado a crédito', valor: att['total_venta_credito'] },
          ]

          res.set_data(att)
          res.add_msg("Cuadre realizado correctamente")
        else
          res.add_msgs(cuadre.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])

          transaction_rollback
        end
      end

    else

      cuadre = cuadre.first

      user_cuadro = cuadre.user

      obj = {
        user_id:              cuadre["user_id"],
        usuario:              user_cuadro.nombre_completo,
        fecha_equivalente:    cuadre["fecha_equivalente"],
        numero_reporte:       cuadre["numero_reporte"],
        reimprimir:           true,
        contenido_reporte: [
          {descripcion: 'facturas_contado', titulo: 'Total facturado a contado', valor: cuadre["total_venta_contado"]},
          {descripcion: 'recibos_ingresos', titulo: 'Total recibo de ingreso', 	 valor: cuadre["total_recibo_ingreso"]},
          {descripcion: 'total_anterior', 	titulo: 'Total anterior', 	 				 valor: cuadre["total_anterior"]},
          {descripcion: 'total_general', 		titulo: 'Total en caja', 						 valor: cuadre["total_general"]},
          {descripcion: 'facturas_credito', titulo: 'Total facturado a crédito', valor: cuadre["total_venta_credito"]},
        ]
      }
			res.set_data(obj)
    end

    return res
  end

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.find_numero_reporte
    ultimo_numero = CuadreCaja.last
    siguiente_numero = 1

    if ultimo_numero
      siguiente_numero = ultimo_numero.numero_reporte + 1
    end
    return siguiente_numero
  end

  def find_total_anterior
    ultimo_numero = CuadreCaja.last(:order => "id asc", :limit => 1).numero_reporte
    siguiente_numero = 0

    if ultimo_numero
      siguiente_numero = ultimo_numero + 1
    end
    return siguiente_numero
  end
end
