module Reportes
  module Suplidores
    module Productos
      extend self

      def get_suplidores_por_producto(params)
        articulo_id = params['articulo_id']
        desde = params['desde']
        hasta = params['hasta']

        query = {}
        query_join = {}
        query['articulo_id'] = articulo_id
        query_join['fecha_equivalente'] = Date.parse(desde).beginning_of_day..Date.parse(hasta).end_of_day
        query_join['tipo'] = 'compra'

        temp = DetalleFactura.where(query)
                             .select('detalle_facturas.* ,cabecera_facturas.suplidor_id, cabecera_facturas.fecha_equivalente')
                             .joins(:cabecera_factura)
                             .where(cabecera_facturas: query_join)
                             .order('detalle_facturas.id ASC')
                             .includes([{ cabecera_factura: [:suplidor] }])

        contenido = []
        temp.each do |detalle|
          att = detalle.attributes
          att['suplidor_nombre'] = detalle.cabecera_factura.suplidor.nombre_completo
          contenido.push(att)
        end

        articulo = Articulo.find_by_id(articulo_id)
        {
          body: contenido,
          totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0, facturado: 0 },
          sub_t: "Producto: #{articulo.nombre}"
        }
      end

      alias call get_suplidores_por_producto
    end
  end
end
