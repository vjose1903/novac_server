class CuadreCaja < ApplicationRecord
  belongs_to :user

  def self.makecuadre(current_user)
    today_cuadre = CuadreCaja.where({ created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day }).to_a
    puts "( #{today_cuadre.nil?} )".red
    if today_cuadre.empty?
      ventas_contado_total_facturado_ = CabeceraFactura.where(
        { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
          'fecha_completada': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
          tipo: "venta", condicion: "Contado", forma_pago: "Efectivo", is_viaje: false }

      ).sum(:total_factura)

      ventas_credito_ = CabeceraFactura.where(
        { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day,
          tipo: "venta",
          condicion: "Crédito" }
      ).sum(:total_factura)

      recibos_ingresos_ = RecibosIngreso.where(
        { 'fecha_equivalente': DateTime.now.beginning_of_day..DateTime.now.end_of_day }
      ).sum(:total)

      # CuadreCaja.find_numero_reporte

      obj = {
        user_id: current_user.id,
        usuario: current_user.nombre.titleize + " " + current_user.apellido.titleize,
        fecha_equivalente: DateTime.now,

        total_general: (ventas_contado_total_facturado_ + recibos_ingresos_).round(2),
        total_venta_credito: ventas_credito_,
        total_venta_contado: ventas_contado_total_facturado_,
        total_recibo_ingreso: recibos_ingresos_,
        total_anterior: 0,
        numero_reporte: CuadreCaja.find_numero_reporte,
      }

      cuadre = CuadreCaja.new(obj)
      res = {}
      CuadreCaja.transaction do
        unless cuadre.save!
          return { :error => true, :msg => cuadre.errors, :status => 400 }
        end

        return { :error => false, :msg => "Cuadre realizado correctamente", :body => obj, :status => 200 }
      end
    else
      obj = {
        user_id: current_user.id,
        usuario: current_user.nombre.titleize + " " + current_user.apellido.titleize,
        fecha_equivalente: DateTime.now,

        total_general: today_cuadre[0]["total_general"],
        total_venta_credito: today_cuadre[0]["total_venta_credito"],
        total_venta_contado: today_cuadre[0]["total_venta_contado"],
        total_recibo_ingreso: today_cuadre[0]["total_recibo_ingreso"],
        total_anterior: today_cuadre[0]["total_anterior"],
        numero_reporte: today_cuadre[0]["numero_reporte"],
        reimprimir: true,
      }
      return { :error => false, :msg => "Cuadre buscado correctamente", :body => obj, :status => 200 }
    end
  end

  # -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
  def self.find_numero_reporte
    ultimo_numero = CuadreCaja.last
    siguiente_numero = 1

    if ultimo_numero
      siguiente_numero = ultimo_numero.numero_reporte + 1
    end
    return siguiente_numero
  end

  def find_total_anterior
    ultimo_numero = CuadreCaja.last(:order => "id asc", :limit => 1).numero_reporte
    siguiente_numero = 0

    if ultimo_numero
      siguiente_numero = ultimo_numero + 1
    end
    return siguiente_numero
  end
end
