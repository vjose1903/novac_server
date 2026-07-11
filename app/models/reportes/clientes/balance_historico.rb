module Reportes
  module Clientes
    module BalanceHistorico
      extend self

      def get_balance_cliente_historico(params)
        cliente_id = params[:cliente_id]
        desde = params[:desde]
        hasta = params[:hasta] || params[:desde]

        return { body: [], totalizacion: { balance: 0, facturado: 0, pagado: 0 }, sub_t: 'Cliente inactivo' } unless Cliente.where(id: cliente_id, estado: true).exists?

        fecha_desde = Date.parse(desde).beginning_of_day
        fecha_hasta = Date.parse(hasta).end_of_day
        query = {
          'cliente_id' => cliente_id,
          'fecha_equivalente' => fecha_desde..fecha_hasta,
          'tipo' => 'venta',
          'condicion' => 'Crédito',
          'estado' => true,
          'is_nota' => false
        }

        facturas_detalle = []
        total_facturado = 0
        total_pagado = 0
        total_balance = 0

        facturas = CabeceraFactura.joins(:cliente).where(query).where(clientes: { estado: true }).order('fecha_equivalente ASC').to_a
        factura_ids = facturas.map(&:id)

        pagos_por_factura = if factura_ids.empty?
          {}
        else
          DetalleRecibo.joins(:recibos_ingreso)
                       .where(cabecera_factura_id: factura_ids)
                       .where('recibos_ingresos.fecha_equivalente <= ?', fecha_hasta)
                       .where(recibos_ingresos: { estado: true })
                       .group(:cabecera_factura_id)
                       .sum(:deposito)
        end

        notas_por_factura = if factura_ids.empty?
          {}
        else
          FacturaAplicada.joins(:nota)
                         .where(cabecera_factura_id: factura_ids)
                         .where('notas.fecha_equivalente <= ?', fecha_hasta)
                         .where(notas: { estado: true })
                         .where(tipo_factura_id: [TiposNotasId.credito, TiposNotasId.credito_electronica])
                         .group(:cabecera_factura_id)
                         .sum(:total)
        end

        facturas.each do |factura|
          pagos_recibos = pagos_por_factura[factura.id] || 0
          notas_credito = notas_por_factura[factura.id] || 0

          total_pagos_factura = pagos_recibos + notas_credito
          balance_factura = factura.total_factura - total_pagos_factura

          total_facturado += factura.total_factura
          total_pagado += total_pagos_factura
          total_balance += balance_factura

          facturas_detalle << {
            numero_documento: factura.numero_comprobante,
            fecha_equivalente: factura.fecha_equivalente,
            total_factura: factura.total_factura,
            total_pagado: total_pagos_factura,
            balance_pendiente: balance_factura
          }
        end

        cliente = Cliente.find_by_id(cliente_id)
        cliente_nombre = cliente ? cliente.nombre_completo : 'Cliente no encontrado'
        sub_titulo = "Cliente: #{cliente_nombre}, "
        sub_titulo += desde == hasta ? "Fecha: #{formatearFecha(desde, TipoFecha.sin_hora)}" : "Desde: #{formatearFecha(desde, TipoFecha.sin_hora)}, Hasta: #{formatearFecha(hasta, TipoFecha.sin_hora)}"

        {
          body: facturas_detalle,
          totalizacion: { balance: total_balance, facturado: total_facturado, pagado: total_pagado },
          sub_t: sub_titulo
        }
      end

      alias call get_balance_cliente_historico
    end
  end
end
