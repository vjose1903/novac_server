module Reportes
  module Facturas
    module MovimientosVehiculo
      extend self

      def get_movimientos_vehiculo(params)
        viajes_por_vehiculo = []
        total_fletes = 0
        vehiculo_id = params[:vehiculo_id].to_i

        query = {}
        query['estado'] = true
        query['fecha_equivalente'] = Date.parse(params[:desde]).beginning_of_day..Date.parse(params[:hasta]).end_of_day
        query['tipo'] = 'venta'
        query['is_viaje'] = true
        query['is_nota'] = false

        all_viajes_por_vehiculo = CabeceraFactura.joins(:movimientos_viaje)
                                                  .where(query)
                                                  .where(movimientos_viaje: { vehiculo_id: vehiculo_id })
                                                  .distinct
                                                  .order('cabecera_facturas.fecha_equivalente DESC')
                                                  .includes([{ movimientos_viaje: [:vehiculo, :user] }, { detalle_facturas: [:articulo] }])
        vehiculo = Vehiculo.find_by_id(vehiculo_id)

        all_viajes_por_vehiculo.each do |viaje|
          chofer = if viaje.movimientos_viaje.length == 0
            'No tiene chofer registrado'
          elsif viaje.movimientos_viaje.length == 1
            viaje.movimientos_viaje.first.user.nombre_completo
          else
            'Varios...'
          end

          flete = viaje.detalle_facturas.select do |detalle|
            detalle.articulo.nombre.downcase.include?('transporte') || detalle.articulo.nombre.downcase.include?('flete')
          end

          obj_movimiento = {
            chofer: chofer,
            flete: flete.length > 0 ? flete.first.total : 0,
            fecha_equivalente: viaje['fecha_equivalente'],
            fecha_viaje: viaje['fecha_viaje'],
            numero_comprobante: viaje['numero_comprobante']
          }

          viajes_por_vehiculo.push(obj_movimiento)
          total_fletes += obj_movimiento[:flete]
        end

        sub_titulo = "Viajes realizados en el camión: << #{vehiculo.info_vehiculo} >> entre las fechas: #{formatearFecha(params['desde'], TipoFecha.sin_hora)} y #{formatearFecha(params['hasta'], TipoFecha.sin_hora)}"

        {
          body: viajes_por_vehiculo,
          totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_fletes, devuelto: 0, facturado: 0 },
          sub_t: sub_titulo
        }
      end

      alias call get_movimientos_vehiculo
    end
  end
end
