module Reportes
  module Clientes
    module CuentasCobrar
      extend self

      def get_cuentas_cobrar(params)
        current_user = get_current_user
        has_permiso_pre_venta = current_user.verificateHasPermiso('pre_venta').status_valid

        tipo = params[:tipo]
        cliente_id = params[:cliente_id]
        include_pagadas = params[:include_pagadas].nil? ? false : params[:include_pagadas].to_boolean
        include_mora = params[:include_mora].nil? ? false : params[:include_mora].to_boolean
        desde = params[:desde]
        hasta = params[:hasta] || params[:desde]
        antiguedad_columns = parse_antiguedad_columns(params)
        bucket_where_sql = build_antiguedad_filter_where(antiguedad_columns)

        fecha_desde = Date.parse(desde).beginning_of_day
        fecha_hasta = Date.parse(hasta).end_of_day

        longitud = if has_permiso_pre_venta
          tipo == Report::CxC.por_cliente ? 49 : (tipo == Report::CxC.detallado ? 30 : 40)
        else
          tipo == Report::CxC.por_cliente ? 60 : (tipo == Report::CxC.detallado ? 38 : 47)
        end

        query = {
          'cabecera_facturas.tipo' => has_permiso_pre_venta ? %w[venta pre_venta] : ['venta'],
          'cabecera_facturas.estado' => true,
          'cabecera_facturas.fecha_equivalente' => fecha_desde..fecha_hasta
        }
        query['cabecera_facturas.cliente_id'] = cliente_id if cliente_id.present?

        cliente_nombre = "CASE WHEN LENGTH(clientes.nombre || ' ' || clientes.apellido) > #{longitud}
                            THEN CONCAT(SUBSTRING(clientes.nombre || ' ' || clientes.apellido, 1, #{longitud}), '...')
                        ELSE clientes.nombre || ' ' || clientes.apellido END AS cliente_nombre"

        base_select = "#{cliente_nombre}, clientes.id"
        bucket_selects = antiguedad_bucket_selects(antiguedad_columns, tipo)

        select_ = if tipo == Report::CxC.agrupado
          "#{base_select}, sum(cabecera_facturas.total_factura) as total_factura, " \
          "sum(cabecera_facturas.balance) as total_pendiente, " \
          "#{bucket_selects.join(', ')}"
        elsif tipo == Report::CxC.por_cliente
          "#{base_select}, cabecera_facturas.fecha_equivalente, cabecera_facturas.id, " \
          "cabecera_facturas.numero_comprobante, cabecera_facturas.tipo, cabecera_facturas.numero_factura, " \
          "cabecera_facturas.total_factura, cabecera_facturas.fecha_vencimiento, cabecera_facturas.condicion, " \
          "cabecera_facturas.balance as total_pendiente"
        else
          "#{base_select}, cabecera_facturas.fecha_equivalente, cabecera_facturas.id, " \
          "cabecera_facturas.numero_comprobante, cabecera_facturas.tipo, cabecera_facturas.numero_factura, " \
          "cabecera_facturas.total_factura, cabecera_facturas.balance as total_pendiente, " \
          "#{bucket_selects.join(', ')}"
        end

        joins_ = 'INNER JOIN clientes ON cabecera_facturas.cliente_id = clientes.id'

        if include_mora
          joins_ += <<-SQL
            LEFT JOIN (
              SELECT
                dr.cabecera_factura_id,
                jsonb_agg(
                  jsonb_build_object(
                    'id', ri.id,
                    'fecha_equivalente', ri.fecha_equivalente,
                    'deposito', dr.deposito,
                    'mora', dr.mora
                  )
                ) as pagos_array
              FROM detalle_recibos dr
              INNER JOIN recibos_ingresos ri ON ri.id = dr.recibos_ingreso_id
              GROUP BY dr.cabecera_factura_id
            ) AS pagos_agrupados ON pagos_agrupados.cabecera_factura_id = cabecera_facturas.id
          SQL

          select_ += ', pagos_agrupados.pagos_array as pagos'
        end

        group_by = case tipo
        when Report::CxC.agrupado
          'clientes.id, clientes.nombre, clientes.apellido'
        when Report::CxC.detallado
          'cabecera_facturas.id, clientes.id, clientes.nombre, clientes.apellido'
        when Report::CxC.por_cliente
          include_mora ? 'cabecera_facturas.id, clientes.id, clientes.nombre, clientes.apellido, pagos_agrupados.pagos_array' :
            'cabecera_facturas.id, clientes.id, clientes.nombre, clientes.apellido'
        else
          ''
        end

        facturas_pagadas_where = include_pagadas ? '' : 'cabecera_facturas.balance >= 1 AND cabecera_facturas.pagada = false'
        order_by = tipo == Report::CxC.agrupado ? '' : 'cabecera_facturas.fecha_equivalente ASC'

        facturas = CabeceraFactura.joins(joins_)
                                  .select(select_)
                                  .where(query)
                                  .where(facturas_pagadas_where)
                                  .where(bucket_where_sql)
                                  .where(clientes: { estado: true })
                                  .group(group_by)
                                  .order(order_by)

        total_facturado = 0
        total_pendiente = 0

        cuentas = facturas.map do |cf|
          cabeza = cf.attributes
          total_facturado += cabeza['total_factura'].to_f
          total_pendiente += cabeza['total_pendiente'].to_f

          cabeza['tipo_documento'] = cabeza['tipo'] == 'venta' ? 'Factura' : 'Pre-venta'
          if tipo != Report::CxC.agrupado
            cabeza['numero_documento'] = cabeza['tipo'] == 'venta' ? cabeza['numero_comprobante'] : ("%08d" % cabeza['numero_factura'].to_s)
          end
          cabeza = sustituir_monto(cabeza, antiguedad_columns) if tipo == Report::CxC.detallado
          cabeza['pagos'] = (cabeza['pagos'] || []).reject(&:nil?)
          cabeza
        end

        cuentas.sort_by! { |item| -item['total_pendiente'].to_f } if tipo == Report::CxC.agrupado

        sub_titulo = cliente_id.present? ? "Cliente: #{Reportes::Shared::CommonHelpers.buscar_cliente({ cliente_id: cliente_id }.with_indifferent_access, 125, ['nombre'])['nombre']}, " : ''
        sub_titulo += "Desde: #{formatearFecha(params['desde'], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params['hasta'], TipoFecha.sin_hora)}"

        {
          body: cuentas,
          totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_pendiente, devuelto: 0, facturado: total_facturado },
          sub_t: sub_titulo
        }
      end

      alias call get_cuentas_cobrar

      def sustituir_monto(detalle, columnas_antiguedad = nil)
        columnas_antiguedad ||= antiguedad_bucket_keys
        columnas_antiguedad.each do |item|
          detalle[item] = detalle[item] >= 1 ? detalle['numero_documento'] : 0
        end
        detalle
      end

      def sustituirMonto(detalle, columnas_antiguedad = nil)
        sustituir_monto(detalle, columnas_antiguedad)
      end

      def antiguedad_bucket_definitions
        {
          'cero_to_treinta' => {
            aliases: %w[cero_to_treinta 0_30 0-30 0a30 0to30],
            condition: "trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 0"
          },
          'treinta_uno_to_sesenta' => {
            aliases: %w[treinta_uno_to_sesenta 31_60 31-60 31a60 31to60],
            condition: "trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 1"
          },
          'sesenta_uno_to_noventa' => {
            aliases: %w[sesenta_uno_to_noventa 61_90 61-90 61a90 61to90],
            condition: "trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 2"
          },
          'noventa_uno_to_more' => {
            aliases: %w[noventa_uno_to_more 90_mas 90+ 91+ mayor_90 mayor_a_90 mas_de_90 over_90],
            condition: "trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) >= 3"
          }
        }
      end

      def antiguedad_bucket_keys
        antiguedad_bucket_definitions.keys
      end

      def parse_antiguedad_columns(params)
        raw_columns = params[:columnas_antiguedad] || params[:antiguedad_columns] || params[:antiguedad]
        return antiguedad_bucket_keys if raw_columns.blank?

        selected_columns = Array(raw_columns)
                           .flat_map { |value| value.to_s.split(',') }
                           .map { |value| normalize_antiguedad_bucket(value) }
                           .compact
                           .uniq

        selected_columns.present? ? selected_columns : antiguedad_bucket_keys
      end

      def normalize_antiguedad_bucket(value)
        value_normalized = value.to_s.strip.downcase
        return nil if value_normalized.blank?

        antiguedad_bucket_definitions.each do |key, definition|
          return key if definition[:aliases].include?(value_normalized)
        end

        nil
      end

      def antiguedad_bucket_selects(columnas_antiguedad, tipo)
        columnas_antiguedad.map do |column|
          condition = antiguedad_bucket_definitions[column][:condition]
          prefix = tipo == Report::CxC.agrupado ? 'sum' : nil
          expression = "case when #{condition} then cabecera_facturas.balance else 0 end"
          prefix ? "#{prefix}(#{expression}) as #{column}" : "#{expression} as #{column}"
        end
      end

      def build_antiguedad_filter_where(columnas_antiguedad)
        columnas_antiguedad.map { |column| "(#{antiguedad_bucket_definitions[column][:condition]})" }.join(' OR ')
      end
    end
  end
end
