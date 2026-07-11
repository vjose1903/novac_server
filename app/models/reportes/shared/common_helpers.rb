module Reportes
  module Shared
    module CommonHelpers
      extend self
      extend ActionView::Helpers::NumberHelper

      def estructura_reporte(arg)
        titulo = arg[:titulo]
        tipo_reporte = arg[:tipo_reporte]
        content = arg[:content]
        totalizacion = arg[:totalizacion]
        sub_titulo = arg[:sub_titulo]
        tipo_tabla = arg[:tipo_tabla]

        current_user = get_current_user
        temp_emp = current_user.nombre_completo
        longitud = temp_emp.length

        {
          titulo_reporte: titulo,
          tipo_reporte: tipo_reporte,
          fecha: formatearFecha(DateTime.now.to_s, TipoFecha.con_hora),
          realizado_por: longitud > 15 ? "#{temp_emp[0, 15]}..." : temp_emp,
          itbis: (totalizacion[:itbis] || 0).round(2),
          bruto: (totalizacion[:bruto] || 0).round(2),
          descuento: (totalizacion[:descuento] || 0).round(2),
          devuelto: (totalizacion[:devuelto] || 0).round(2),
          total: (totalizacion[:total] || 0).round(2),
          facturado: (totalizacion[:facturado] || 0).round(2),
          mora: (totalizacion[:mora] || 0).round(2),
          pagado: (totalizacion[:pagado] || 0).round(2),
          balance: (totalizacion[:balance] || 0).round(2),
          mostrar_sub_titulo: sub_titulo[:bool],
          sub_titulo: sub_titulo[:sub_t],
          tipo_tabla: tipo_tabla,
          contenido_reporte: content
        }
      end

      def buscar_suplidor(supli, max_lengt = 0)
        suplidor = {}
        suplidor['nombre'] = supli.nombre_completo
        longitud = suplidor['nombre'].length

        if max_lengt > 0 && longitud > max_lengt
          suplidor['nombre'] = "#{suplidor['nombre'][0, (max_lengt + 1)]}..."
        end

        documento = supli.documentos_de_identidad.find { |doc| doc.principal == true }
        suplidor['rnc'] = documento.nil? ? '----------' : documento['documento']
        suplidor
      end

      def buscar_cliente(factura, max_lengt, retornar)
        cliente = {}

        if !factura[:cliente_id].nil?
          cli = factura.cliente if factura.instance_of?(CabeceraFactura) || factura.instance_of?(RecibosIngreso)
          cli = Cliente.find_by_id(factura[:cliente_id]) if !factura.instance_of?(CabeceraFactura) && !factura.instance_of?(RecibosIngreso)

          temp_nom = cli.nombre_completo
          longitud = temp_nom.length

          if retornar.my_includes_str('nombre')
            cliente['nombre'] = longitud > max_lengt ? "#{temp_nom[0, (max_lengt + 1)]}..." : temp_nom
          end

          if retornar.my_includes_str('rnc')
            documento = cli.documentos_de_identidad.find { |doc| doc.principal == true }
            cliente['rnc'] = documento.nil? ? '----------' : documento.documento
          end
        elsif !factura['NoCliente_nombre'].nil?
          cliente['nombre'] = factura['NoCliente_nombre']
          cliente['rnc'] = factura['NoCliente_rnc'].present? ? factura['NoCliente_rnc'] : '-------------'
        end

        cliente
      end

      def calcular_cantidades(articulos)
        plural = {
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
        }

        articulos.map do |articulo|
          obj = articulo.attributes
          obj['cantidades'] = Articulo.calcularCantidades(articulo)
          cant = number_with_delimiter(("%.2f" % obj['cantidades'][articulo['medida']]).gsub(',', '.'))
          obj['cantidad_principal'] = "#{cant} #{cant.to_i == 1 ? articulo['medida'] : plural[articulo['medida'].to_sym]}"
          obj
        end
      end
    end
  end
end
