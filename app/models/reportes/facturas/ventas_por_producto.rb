module Reportes
  module Facturas
    module VentasPorProducto
      extend self

      def get_ventas_por_producto(params)
        ventas = []
        desde = params['desde']
        hasta = params['hasta'].nil? ? params['desde'] : params['hasta']
        fecha_desde = Date.parse(desde).beginning_of_day
        fecha_hasta = Date.parse(hasta).end_of_day

        sub_titulo = desde == hasta ? "Fecha: #{formatearFecha(desde, TipoFecha.sin_hora)}" : "Entre las fechas: #{formatearFecha(desde, TipoFecha.sin_hora)} y #{formatearFecha(hasta, TipoFecha.sin_hora)}"
        total_venta = 0
        query = {}

        tipo_factura_nota_credito = TipoFactura.find_by_descripcion(TiposFacturasDescripcion.nota_de_credito)

        query['cabecera_facturas.fecha_equivalente'] = fecha_desde..fecha_hasta
        query['cabecera_facturas.tipo'] = 'venta'
        query['cabecera_facturas.is_nota'] = false
        query['cabecera_facturas.estado'] = true

        TipoArticulo.all.each do |tipo_articulo|
          total_grupo = 0
          temp_ventas = []
          query['articulos.tipo_articulo_id'] = tipo_articulo.id

          select_ = "detalle_facturas.articulo_id,
					coalesce( SUM ( detalle_facturas.descuento_valor ), 0) as descuento_valor,
					coalesce( SUM ( detalle_facturas.total ), 0) as total,
					coalesce( SUM ( detalle_facturas.cantidad_en_unidades ), 0) as cantidad_en_unidades,
					coalesce( SUM ( detalle_facturas.itbis ), 0) as itbis"

          joins_ = "INNER JOIN cabecera_facturas ON cabecera_facturas.id = detalle_facturas.cabecera_factura_id
					INNER JOIN articulos ON articulos.id = detalle_facturas.articulo_id"

          detalles_agrupados = DetalleFactura.select(select_).joins(joins_).where(query).order('articulo_id ASC').group('detalle_facturas.articulo_id')
                                            .includes([{ articulo: [:contenido_articulos, :tipo_articulo] }]).to_a
          articulo_ids = detalles_agrupados.map(&:articulo_id)

          notas_por_articulo = if articulo_ids.empty?
            {}
          else
            DetalleFacturaNota.joins('INNER JOIN facturas_aplicadas ON facturas_aplicadas.id = detalles_facturas_notas.factura_aplicada_id
                                      INNER JOIN notas ON notas.id = facturas_aplicadas.nota_id')
                              .where(detalles_facturas_notas: { articulo_id: articulo_ids, tipo_factura_id: tipo_factura_nota_credito.id })
                              .where(notas: { fecha_equivalente: fecha_desde..fecha_hasta })
                              .group('detalles_facturas_notas.articulo_id')
                              .pluck(
                                'detalles_facturas_notas.articulo_id',
                                'coalesce(SUM(detalles_facturas_notas.cantidad_en_unidades), 0)',
                                'coalesce(SUM(detalles_facturas_notas.total), 0)'
                              )
                              .each_with_object({}) do |(articulo_id, cantidad_devuelto, total_devuelto), memo|
                                memo[articulo_id] = {
                                  'cantidad_devuelto' => cantidad_devuelto,
                                  'total_devuelto' => total_devuelto
                                }
                              end
          end

          detalles_agrupados.each do |df|
            detalle = df.attributes
            notas = notas_por_articulo[df.articulo_id] || { 'cantidad_devuelto' => 0, 'total_devuelto' => 0 }

            detalle['cantidad_devuelto'] = notas['cantidad_devuelto']
            detalle['total_devuelto'] = notas['total_devuelto']
            detalle['nombre'] = df.articulo.nombre
            detalle['total_vendido'] = df.total
            detalle['total_descuento'] = df.descuento_valor
            detalle['total_general'] = detalle['total_vendido'] - detalle['total_devuelto']
            detalle['contenido'] = Articulo.calcularContenidos(df.articulo, false)

            mostrar = calcular_cantidad_proporcional(detalle)
            detalle['vendido_mostrar'] = mostrar['vendido_mostrar']
            detalle['devuelto_mostrar'] = mostrar['devuelto_mostrar']

            total_grupo += detalle['total_general']
            temp_ventas.push(detalle)
          end

          total_venta += total_grupo
          ventas.push(
            contenido_titulo: tipo_articulo.descripcion,
            total: total_grupo,
            contenido_grupo: temp_ventas.sort_by! { |item| item['nombre'] }
          )
        end

        ventas.push(contenido_titulo: 'TOTAL GENERAL', total: total_venta, contenido_grupo: nil)

        { body: ventas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_venta, devuelto: 0, facturado: 0 }, sub_t: sub_titulo }
      end

      alias call get_ventas_por_producto

      def calcular_cantidad_proporcional(detalle)
        plural = {
          Quintal: 'Quintales',
          Libra: 'Libras',
          Caja: 'Cajas',
          Paquete: 'Paquetes',
          Unidad: 'Unidades',
          Saco: 'Sacos',
          Funda: 'Fundas',
          Bolsa: 'Bolsas'
        }

        vendido_mostrar = '0.00'
        devuelto_mostrar = '0.00'

        if detalle['cantidad_en_unidades'] >= 1
          seleccionados = detalle['contenido'].values.select { |contenido_cant| contenido_cant <= detalle['cantidad_en_unidades'] }
          contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.reverse.first)
        else
          seleccionados = detalle['contenido'].values
          contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.first)
        end

        contenido_seleccionado_valor = detalle['contenido'][contenido_seleccionado]
        cant_vendido = detalle['cantidad_en_unidades'] / contenido_seleccionado_valor.to_f
        vendido_mostrar = "#{roundNumberToDecimal(cant_vendido)} #{cant_vendido == 1 ? contenido_seleccionado : plural[contenido_seleccionado.to_sym]}"

        if detalle['cantidad_devuelto'] >= 1
          seleccionados = detalle['contenido'].values.select { |contenido_cant| contenido_cant <= detalle['cantidad_devuelto'] }
          contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.reverse.first)
        else
          seleccionados = detalle['contenido'].values
          contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.first)
        end

        contenido_seleccionado_valor = detalle['contenido'][contenido_seleccionado]
        cant_devuelto = detalle['cantidad_devuelto'] / contenido_seleccionado_valor.to_f
        devuelto_mostrar = "#{roundNumberToDecimal(cant_devuelto)} #{cant_devuelto == 1 ? contenido_seleccionado : plural[contenido_seleccionado.to_sym]}"

        { 'vendido_mostrar' => vendido_mostrar, 'devuelto_mostrar' => devuelto_mostrar }
      end
    end
  end
end
