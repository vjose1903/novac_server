class CuadreCaja < ApplicationRecord
  belongs_to :user

  def self.makecuadre
    ventas_contado_total_facturado_ = CabeceraFactura.where(
      { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
        'fecha_completada': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
        tipo: "venta", condicion: "Contado", forma_pago: "Efectivo" }

    ).sum(:total_factura)

    ventas_credito_ = CabeceraFactura.where(
      { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
        tipo: "venta",
        condicion: "Crédito" }
    ).sum(:total_factura)

    recibos_ingresos_ = RecibosIngreso.where(
      { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day }
    ).sum(:total)

    obj = {
      ventas_contado_total_facturado: ventas_contado_total_facturado_,
      recibos_ingresos: recibos_ingresos_,
      total_en_caja: (ventas_contado_total_facturado_ + recibos_ingresos_).round(2),
      ventas_credito: ventas_credito_,
    }

    return obj
  end
end
