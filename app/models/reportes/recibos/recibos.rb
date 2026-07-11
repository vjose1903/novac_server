module Reportes
  module Recibos
    module Recibos
      extend self

      def call(params)
        recibos = []
        desde = params[:desde]
        hasta = params[:hasta].nil? ? params[:desde] : params[:hasta]
        order = params[:order]
        tipo = params[:tipo]
        buscar_por = params[:search_by].present? ? params[:search_by].to_i : Report::ReciboBuscarPor.general
        cliente_id = params[:cliente_id]

        query = {}
        query['fecha_equivalente'] = Date.parse(desde).beginning_of_day..Date.parse(hasta).end_of_day
        query['estado'] = true
        query['cliente_id'] = cliente_id if buscar_por == Report::ReciboBuscarPor.por_cliente

        temp = RecibosIngreso.where(query).order("id #{order}").includes(RecibosIngreso.models_includes)

        total_recibido = 0
        total_mora = 0
        total_bruto = 0

        temp.each do |recibo|
          att = recibo.attributes
          total_bruto += recibo['bruto']
          total_mora += recibo['mora']
          total_recibido += recibo['total']

          client = Reportes::Shared::CommonHelpers.buscar_cliente(recibo, 55, ['nombre'])
          att['cliente_nombre'] = client['nombre']
          recibos.push(att.with_indifferent_access)
        end

        recibos = sum_by_day(recibos) if tipo == Report::ReciboIngreso.agrupado
        cliente = Cliente.find_by_id(cliente_id) if buscar_por == Report::ReciboBuscarPor.por_cliente

        sub_titulo = "Desde: #{formatearFecha(params['desde'], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params['hasta'], TipoFecha.sin_hora)}"
        sub_titulo = "Cliente: #{cliente.nombre_completo}, #{sub_titulo}" if buscar_por == Report::ReciboBuscarPor.por_cliente

        { body: recibos, totalizacion: { bruto: total_bruto, mora: total_mora, total: total_recibido, devuelto: 0, facturado: 0 }, sub_t: sub_titulo }
      end

      def sum_by_day(records)
        records.group_by { |record| record[:fecha_equivalente].to_date }.map do |date, group|
          {
            fecha: formatearFecha(date.to_s, TipoFecha.sin_hora),
            total_bruto: group.reduce(0) { |acu, item| item[:bruto] + acu },
            total_mora: group.reduce(0) { |acu, item| item[:mora] + acu },
            total_general: group.reduce(0) { |acu, item| item[:total] + acu }
          }
        end
      end
    end
  end
end
