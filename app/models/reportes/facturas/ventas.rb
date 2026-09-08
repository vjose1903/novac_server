module Reportes
  module Facturas
    module Ventas
      extend self

      def get_ventas(params)
        tipo_reporte = params[:tipo_reporte]
        tipo = params[:tipo]
        tipo_factura_id = params[:tipo_factura_id]
        condicion = params[:condicion]
        desde = params[:desde]
        hasta = params[:hasta]
        formas_pago = params[:formas_pago]
        serie = params[:serie].present? ? params[:serie] : SerieFactura.all
        cliente_id = params[:cliente_id]
        sub_titulo = ''

        where_formas = "forma_pago IN #{formas_pago}"
        query = {}

        is_viaje_credito = "( lower(condicion) = 'crédito' )"
        is_viaje_contado = tipo_reporte == TipoReporteVentas.ventas_hoy ? "( lower(condicion) = 'contado' AND is_viaje = false )" : "( lower(condicion) = 'contado')"
        query_is_viaje = if condicion.downcase == 'todos'
          "#{is_viaje_contado} OR #{is_viaje_credito}"
        elsif condicion.downcase == 'contado'
          is_viaje_contado
        else
          is_viaje_credito
        end

        query['fecha_equivalente'] = tipo_reporte == TipoReporteVentas.ventas_hoy ? DateTime.now.beginning_of_day..DateTime.now.end_of_day : Date.parse(desde).beginning_of_day..Date.parse(hasta).end_of_day
        query['cliente_id'] = cliente_id if tipo_reporte == TipoReporteVentas.ventas_cliente
        query['tipo_factura_id'] = tipo_factura_id if params[:tipo_factura_id].present? && tipo_factura_id != '0'
        query['serie'] = serie if serie != SerieFactura.all
        query['tipo'] = 'venta'
        query['is_nota'] = false
        query['estado'] = true

        tipos_nota_credito = [TiposNotasId.credito, TiposNotasId.credito_electronica]

        select_ = "cabecera_facturas.id, coalesce(clientes.nombre || ' ' || clientes.apellido, cabecera_facturas.\"NoCliente_nombre\", 'Cliente contado') as cliente_nombre,
		cabecera_facturas.tipo_factura_id as tipo_factura_id, cabecera_facturas.fecha_equivalente,
		cabecera_facturas.numero_comprobante, cabecera_facturas.condicion,
		cabecera_facturas.total_factura, cabecera_facturas.itbis, cabecera_facturas.descuento,
		coalesce( SUM (CASE WHEN notas.tipo_factura_id IN (#{tipos_nota_credito.join(',')}) THEN facturas_aplicadas.total ELSE 0 END), 0) as total_devuelto"
        select_ += ', "cabecera_facturas"."Bruto"'

        joins_ = "LEFT JOIN clientes ON cabecera_facturas.cliente_id = clientes.id
                    LEFT JOIN facturas_aplicadas ON cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id
                    LEFT JOIN notas ON notas.id = facturas_aplicadas.nota_id"

        group_by = 'cabecera_facturas.id, clientes.nombre, clientes.apellido'

        total_devuelto = 0
        bruto = 0
        itbis = 0
        descuento = 0

        ventas = CabeceraFactura
                 .select(select_)
                 .joins(joins_)
                 .where(query)
                 .where(where_formas)
                 .where(query_is_viaje)
                 .where(Reportes::Shared::CommonHelpers.external_invoice_filter_sql(params))
                 .group(group_by)
                 .order('cabecera_facturas.id ASC').each do |cf|
          total_devuelto += cf[:total_devuelto]
          bruto += cf[:Bruto] || 0
          itbis += cf[:itbis] || 0
          descuento += cf[:descuento] || 0
        end

        total_ventas = ((bruto + itbis) - descuento) - total_devuelto
        if tipo_reporte == TipoReporteVentas.ventas_cliente
          sub_titulo = "Cliente: #{Reportes::Shared::CommonHelpers.buscar_cliente({ cliente_id: params[:cliente_id] }.with_indifferent_access, 125, ['nombre'])['nombre']}"
        end

        ventas = sum_by_day(ventas) if tipo == 'agrupado'

        { body: ventas, totalizacion: { bruto: bruto, descuento: descuento, itbis: itbis, total: total_ventas, devuelto: total_devuelto, facturado: 0 }, sub_t: sub_titulo }
      end

      alias call get_ventas

      def sum_by_day_ventas(records)
        sum_by_day(records)
      end

      def sum_by_day(records)
        records.group_by { |record| record.fecha_equivalente.to_date }.map do |date, group|
          ventas_contado = group.select { |factura| factura.condicion.downcase == 'contado' }
          ventas_credito = group.select { |factura| factura.condicion.downcase == 'crédito' }

          {
            fecha: formatearFecha(date.to_s, TipoFecha.sin_hora),
            ventas_contado: ventas_contado.sum(&:total_factura),
            ventas_credito: ventas_credito.sum(&:total_factura),
            descuento_general: group.sum(&:descuento),
            itbis_general: group.sum(&:itbis),
            bruto_general: group.sum(&:Bruto),
            devuelto_general: group.sum(&:total_devuelto),
            total_general: group.sum(&:total_factura) - group.sum(&:total_devuelto)
          }
        end
      end
    end
  end
end
