module Reportes
  module Clientes
    module BalanceHistorico
      extend self

      def call(params)
        cliente_id = params[:cliente_id]
        desde = params[:desde]
        hasta = params[:hasta] || params[:desde]

        return { body: [], totalizacion: { balance: 0, facturado: 0, pagado: 0 }, sub_t: 'Cliente inactivo' } unless Cliente.where(id: cliente_id, estado: true).exists?

        fecha_hasta = Date.parse(hasta).end_of_day
        query = {
          'cliente_id' => cliente_id,
          'fecha_equivalente' => Date.parse(desde).beginning_of_day..fecha_hasta,
          'tipo' => 'venta',
          'condicion' => 'Crédito',
          'estado' => true,
          'is_nota' => false
        }

        facturas_detalle = []
        total_facturado = 0
        total_pagado = 0
        total_balance = 0

        CabeceraFactura.joins(:cliente).where(query).where(clientes: { estado: true })
                        .order('fecha_equivalente ASC')
                        .includes([
                          :cliente,
                          { detalle_recibos: [:recibos_ingreso] },
                          { facturas_aplicadas: [:nota] }
                        ]).each do |factura|
          pagos_recibos = factura.detalle_recibos
                                 .joins(:recibos_ingreso)
                                 .where('recibos_ingresos.fecha_equivalente <= ?', fecha_hasta)
                                 .where(recibos_ingresos: { estado: true })
                                 .sum(:deposito)

          notas_credito = factura.facturas_aplicadas
                                 .joins(:nota)
                                 .where('notas.fecha_equivalente <= ?', fecha_hasta)
                                 .where(notas: { estado: true })
                                 .where(tipo_factura_id: [TiposNotasId.credito, TiposNotasId.credito_electronica])
                                 .sum(:total)

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
    end
  end
end
