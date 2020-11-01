class DetalleRecibo < ApplicationRecord
  belongs_to :recibos_ingreso
  belongs_to :cabecera_factura

  # ==========================================================================

  def self.CreateDetalleRecibo(recibos_)
    detalles = []
    recibos_.detalle_recibos.each_with_index do |d, idx|
      detalle = DetalleRecibo.find_by_id(d["id"])

      if detalle == [] || detalle == nil
        detalle.cabecera_factura_id = d["cabecera_factura_id"]
        detalle = DetalleRecibo.new
      end

      factura = CabeceraFactura.find_by_id(d["cabecera_factura_id"])

      if factura.balance > 0
        id = factura.cliente_id
        total = detalle.deposito
        resultCliente = Cliente.CalculateBalanceCLiente(id, total, "-")

        if resultCliente[:error]
          return [{ error: true, msg: resultCliente[:msg], status: :unprocessable_entity }]
          raise ActiveRecord::Rollback
        end
      end

      calculo_cabecera = CabeceraFactura.calculateBalanceFactura(detalle["cabecera_factura_id"], detalle["deposito"], (idx + 1))
      my_print_log("calculo_cabecera ==>", calculo_cabecera)

      if calculo_cabecera[:error]
        return [{ error: true, msg: calculo_cabecera[:msg], status: :unprocessable_entity }]
        raise ActiveRecord::Rollback
      end

      detalle.balance_anterior_factura = calculo_cabecera[:balance_anterior]
      detalle.balance_factura = calculo_cabecera[:balance]
      detalle.pago_total = detalle["pago_total"]
      detalle.deposito = detalle["deposito"]
      detalle.descripcion = detalle["descripcion"]
      detalle.pago_a_tiempo = detalle["pago_a_tiempo"]
      detalle["is_ultimo"] = true

      detalles.push detalle
    end
    return detalles
  end
end
