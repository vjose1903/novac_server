module Reportes
  module Recibos
    module Recibos
      extend self

      def get_recibos(params)
        recibos = []
        desde = params[:desde]
        hasta = params[:hasta].nil? ? params[:desde] : params[:hasta]
        order = params[:order]
        tipo = params[:tipo]
        buscar_por = params[:search_by].present? ? params[:search_by].to_i : Report::ReciboBuscarPor.general
        cliente_id = params[:cliente_id]
        mostrar_forma_pago = ActiveModel::Type::Boolean.new.cast(params[:mostrar_forma_pago])

        query = {}
        query['fecha_equivalente'] = Date.parse(desde).beginning_of_day..Date.parse(hasta).end_of_day
        query['estado'] = true
        query['cliente_id'] = cliente_id if buscar_por == Report::ReciboBuscarPor.por_cliente

        select_sql = "recibos_ingresos.*, trim(clientes.nombre || ' ' || clientes.apellido) as cliente_nombre"
        select_sql += ', COALESCE(metodos.formas_pago, recibos_ingresos.forma_pago) as forma_pago' if mostrar_forma_pago
        temp = RecibosIngreso
               .select(select_sql)
               .joins(:cliente)
               .where(query)
               .order("recibos_ingresos.id #{order}")

        if mostrar_forma_pago
          temp = temp.joins(<<~SQL.squish)
          LEFT JOIN LATERAL (
            SELECT CASE WHEN COUNT(*) > 1 THEN string_agg(forma_pago, ' • ' ORDER BY id) ELSE MAX(forma_pago) END AS formas_pago
            FROM metodo_de_pago
            WHERE metodo_de_pago_able_type = 'RecibosIngreso'
              AND metodo_de_pago_able_id = recibos_ingresos.id
          ) metodos ON true
          SQL
        end

        total_recibido = 0
        total_mora = 0
        total_bruto = 0

        temp.each do |recibo|
          att = recibo.attributes
          total_bruto += recibo['bruto']
          total_mora += recibo['mora']
          total_recibido += recibo['total']
          recibos.push(att.with_indifferent_access)
		end

        recibos = sum_by_day(recibos) if tipo == Report::ReciboIngreso.agrupado
        cliente = Cliente.find_by_id(cliente_id) if buscar_por == Report::ReciboBuscarPor.por_cliente

        sub_titulo = "Desde: #{formatearFecha(params['desde'], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params['hasta'], TipoFecha.sin_hora)}"
        sub_titulo = "Cliente: #{cliente.nombre_completo}, #{sub_titulo}" if buscar_por == Report::ReciboBuscarPor.por_cliente

        { body: recibos, totalizacion: { bruto: total_bruto, mora: total_mora, total: total_recibido, devuelto: 0, facturado: 0 }, sub_t: sub_titulo }
      end

      alias call get_recibos

      def sum_by_day_recibos(records)
        sum_by_day(records)
      end

      def sum_by_day(records)
        records.group_by { |record| record[:fecha_equivalente].to_date }.map do |date, group|
          {
            fecha: formatearFecha(date.to_s, TipoFecha.sin_hora),
            total_bruto: group.sum { |item| item[:bruto] },
            total_mora: group.sum { |item| item[:mora] },
            total_general: group.sum { |item| item[:total] }
          }
        end
      end
    end
  end
end
