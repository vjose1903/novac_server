module Reportes
  module Inventario
    module Inventario
      extend self

      def call(_params)
        inventario_temp = Articulo.all.where(estado: true).order('nombre ASC').includes(Articulo.models_includes)
        inventario_temp = Reportes::Shared::CommonHelpers.calcular_cantidades(inventario_temp)
        cantidad_articulos = inventario_temp.length
        inventario = inventario_temp.sort_by! { |item| item['nombre'] }

        {
          body: inventario,
          totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0, facturado: 0 },
          sub_t: "Cantidad de productos en inventario: #{cantidad_articulos}"
        }
      end
    end
  end
end
