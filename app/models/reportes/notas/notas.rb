module Reportes
  module Notas
    module Notas
      extend self

      def get_notas(params)
        notas = []
        query = {}
        desde = params['desde']
        hasta = params['hasta'].nil? ? params['desde'] : params['hasta']
        tipo_nota = params['tipo_factura_id'].to_i
        buscar_por = params[:search_by].present? ? params[:search_by].to_i : Report::NotaBuscarPor.general
        cliente_id = params[:cliente_id]

        monto_total = 0
        query['fecha_equivalente'] = Date.parse(desde).beginning_of_day..Date.parse(hasta).end_of_day
        query['tipo_factura_id'] = tipo_nota unless tipo_nota == 0
        query['estado'] = true

        query_factura = {}
        query_factura['cabecera_facturas.cliente_id'] = cliente_id if buscar_por == Report::NotaBuscarPor.por_cliente

        select_ = "facturas_aplicadas.*, cabecera_facturas.numero_comprobante as factura_numero_comprobante,
                   notas.numero_comprobante as nota_numero_comprobante, notas.fecha_equivalente as nota_fecha,
                   coalesce(trim(clientes.nombre || ' ' || clientes.apellido), cabecera_facturas.\"NoCliente_nombre\", 'Cliente contado') as cliente_nombre"

        temp = FacturaAplicada
               .select(select_)
               .joins('inner join notas on notas.id = facturas_aplicadas.nota_id')
               .joins('inner join cabecera_facturas on cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id')
               .joins('left join clientes on clientes.id = cabecera_facturas.cliente_id')
               .where(notas: query)
               .where(query_factura)
               .where(Reportes::Shared::CommonHelpers.external_invoice_filter_sql(params))
               .order('facturas_aplicadas.id DESC')

        temp.each do |factura_aplicada|
          monto_total += factura_aplicada.total.abs
          notas.push(
            factura: factura_aplicada[:factura_numero_comprobante],
            numero_comprobante: factura_aplicada[:nota_numero_comprobante],
            tipo_nota: factura_aplicada.tipo_nota.gsub(' ', '').titleize,
            fecha: factura_aplicada[:nota_fecha],
            monto: factura_aplicada.total.abs,
            cliente_nombre: factura_aplicada[:cliente_nombre]
          )
        end

        cliente = Cliente.find_by_id(cliente_id) if buscar_por == Report::NotaBuscarPor.por_cliente
        sub_titulo = "Desde: #{formatearFecha(params['desde'], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params['hasta'], TipoFecha.sin_hora)}"
        sub_titulo = "Cliente: #{cliente.nombre_completo}, #{sub_titulo}" if buscar_por == Report::NotaBuscarPor.por_cliente

        { body: notas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: monto_total, devuelto: 0, facturado: 0 }, sub_t: sub_titulo }
      end

      alias call get_notas
    end
  end
end
