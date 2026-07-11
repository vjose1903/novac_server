module Reportes
  module Shared
    module CommonHelpers
      extend self
      extend ActionView::Helpers::NumberHelper

      TOTALIZATION_KEYS = %i[itbis bruto descuento devuelto total facturado mora pagado balance].freeze
      PRODUCT_PLURALS = {
        Quintal: 'Quintales',
        Libra: 'Libras',
        Caja: 'Cajas',
        Paquete: 'Paquetes',
        Unidad: 'Unidades',
        Saco: 'Sacos',
        Galon: 'Galones',
        Funda: 'Fundas',
        Bolsa: 'Bolsas',
        Producto: 'Productos'
      }.freeze
      DEFAULT_RNC = '----------'.freeze
      DEFAULT_CASUAL_RNC = '-------------'.freeze

      def estructura_reporte(arg)
        totalizacion = arg[:totalizacion] || {}
        sub_titulo = arg[:sub_titulo] || {}
        current_user = get_current_user
        temp_emp = current_user.nombre_completo

        response = {
          titulo_reporte: arg[:titulo],
          tipo_reporte: arg[:tipo_reporte],
          fecha: formatearFecha(DateTime.now.to_s, TipoFecha.con_hora),
          realizado_por: truncate_label(temp_emp, 15),
          mostrar_sub_titulo: sub_titulo[:bool],
          sub_titulo: sub_titulo[:sub_t],
          tipo_tabla: arg[:tipo_tabla],
          contenido_reporte: arg[:content]
        }

        TOTALIZATION_KEYS.each do |key|
          response[key] = (totalizacion[key] || 0).round(2)
        end

        response
      end

      def buscar_suplidor(supli, max_lengt = 0)
        {
          'nombre' => truncate_label(supli.nombre_completo, max_lengt),
          'rnc' => principal_documento_or_default(supli, DEFAULT_RNC)
        }
      end

      def buscar_cliente(factura, max_lengt, retornar)
        cliente = {}
        include_nombre = retornar.my_includes_str('nombre')
        include_rnc = retornar.my_includes_str('rnc')

        if !factura[:cliente_id].nil?
          cli = cliente_from_factura(factura)
          cliente['nombre'] = truncate_label(cli.nombre_completo, max_lengt) if include_nombre
          cliente['rnc'] = principal_documento_or_default(cli, DEFAULT_RNC) if include_rnc
        elsif !factura['NoCliente_nombre'].nil?
          cliente['nombre'] = factura['NoCliente_nombre'] if include_nombre
          cliente['rnc'] = factura['NoCliente_rnc'].present? ? factura['NoCliente_rnc'] : DEFAULT_CASUAL_RNC if include_rnc
        end

        cliente
      end

      def calcular_cantidades(articulos)
        articulos.map do |articulo|
          obj = articulo.attributes
          cantidades = Articulo.calcularCantidades(articulo)
          obj['cantidades'] = cantidades

          cantidad_principal = cantidades[articulo['medida']]
          cant = number_with_delimiter(("%.2f" % cantidad_principal).gsub(',', '.'))
          pluralized_medida = cant.to_i == 1 ? articulo['medida'] : PRODUCT_PLURALS[articulo['medida'].to_sym]
          obj['cantidad_principal'] = "#{cant} #{pluralized_medida}"
          obj
        end
      end

      def calcularCantidades(articulos)
        calcular_cantidades(articulos)
      end

      private

      def truncate_label(value, max_lengt)
        return value if max_lengt.to_i <= 0 || value.length <= max_lengt

        "#{value[0, (max_lengt + 1)]}..."
      end

      def cliente_from_factura(factura)
        return factura.cliente if factura.instance_of?(CabeceraFactura) || factura.instance_of?(RecibosIngreso)

        Cliente.find_by_id(factura[:cliente_id])
      end

      def principal_documento_or_default(entity, default_value)
        documento = entity.documentos_de_identidad.find(&:principal)
        documento.nil? ? default_value : documento.documento
      end
    end
  end
end
