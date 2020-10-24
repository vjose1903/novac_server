class CuadreCaja < ApplicationRecord
  belongs_to :user

  def self.makecuadre
    ventas_contado = CabeceraFactura.where(
      { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
        'fecha_completada': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
        tipo: "venta", condicion: "Contado" }
    )

    ventas_credito = CabeceraFactura.where(
      { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
        tipo: "venta",
        condicion: "Crédito" }
    )

    return ventas_contado
  end
end
