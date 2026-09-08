module Reportes
  module Facturas
    module CuentasConPagos
      extend self

      def get_cuentas_con_pagos(params)
        query = {}
        query['estado'] = true
        query['fecha_equivalente'] = Date.parse(params['desde']).beginning_of_day..Date.parse(params['hasta']).end_of_day
        query['tipo'] = 'venta'
        query['condicion'] = 'Crédito'
        query['is_nota'] = false
        query['cliente_id'] = params['cliente_id']

        movimientos = []
        cliente = nil

        CabeceraFactura.joins(:cliente).where(query)
                       .where(clientes: { estado: true })
                       .where(Reportes::Shared::CommonHelpers.external_invoice_filter_sql(params))
                       .order('cabecera_facturas.fecha_equivalente ASC')
                       .includes([{ detalle_recibos: [:recibos_ingreso] }, { facturas_aplicadas: [:nota, :tipo_factura] }, :cliente]).each do |cabeza_factura|
          items_factura = []

          cabeza_factura.detalle_recibos.each do |detalle_recibo|
            recibo = detalle_recibo.recibos_ingreso
            items_factura.push(
              numero_documento: "%08d" % recibo.numero_recibo,
              tipo: 'Recibo ingreso',
              fecha: recibo.fecha_equivalente,
              total: detalle_recibo.deposito,
              factura_numero_comprobante: cabeza_factura.numero_comprobante,
              factura_fecha: cabeza_factura.fecha_equivalente,
              factura_total: cabeza_factura.total_factura,
              factura_balance_al_momento: 0
            )
          end

          facturas_aplicadas = cabeza_factura.facturas_aplicadas.select { |fa| fa.nota.estado == true }

          facturas_aplicadas.each do |factura_aplicada|
            nota = factura_aplicada.nota
            es_nota_debito = factura_aplicada.tipo_factura.key == TiposFacturasKey.nota_de_debito

            items_factura.push(
              numero_documento: nota.numero_comprobante,
              tipo: "Nota #{es_nota_debito ? 'Débito' : 'Crédito'}",
              fecha: nota.fecha_equivalente,
              total: factura_aplicada.total,
              es_nota_debito: es_nota_debito,
              factura_numero_comprobante: cabeza_factura.numero_comprobante,
              factura_fecha: cabeza_factura.fecha_equivalente,
              factura_total: cabeza_factura.total_factura,
              factura_balance_al_momento: 0
            )
          end

          if items_factura.empty?
            movimientos.push(
              numero_documento: nil,
              tipo: nil,
              fecha: nil,
              total: nil,
              es_nota_debito: nil,
              factura_numero_comprobante: cabeza_factura.numero_comprobante,
              factura_fecha: cabeza_factura.fecha_equivalente,
              factura_total: cabeza_factura.total_factura,
              factura_balance_al_momento: cabeza_factura.total_factura
            )
          else
            items_factura.sort_by! { |item| item[:fecha].to_i }

            balance_recalculado = cabeza_factura.total_factura
            items_factura.each do |item|
              balance_recalculado = item[:es_nota_debito] ? balance_recalculado + item[:total] : balance_recalculado - item[:total]
              item[:factura_balance_al_momento] = balance_recalculado
            end

            movimientos.concat(items_factura)
          end

          cliente = cabeza_factura.cliente
        end

        cliente = Cliente.find_by_id(params['cliente_id']) if cliente.nil?
        sub_titulo = "Cliente: #{cliente.nombre_completo}, Desde: #{formatearFecha(params['desde'], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params['hasta'], TipoFecha.sin_hora)}"

        { body: movimientos, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0, facturado: 0 }, sub_t: sub_titulo }
      end

      alias call get_cuentas_con_pagos
    end
  end
end
