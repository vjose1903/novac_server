class CuadreCaja < ApplicationRecord
  belongs_to :user

  def self.makecuadre(current_user, params)
    fecha = params["fecha"] ? params["fecha"] : DateTime.now    
    cuadre = CuadreCaja.where("fecha_equivalente::date='#{fecha}'").to_a
    

    if cuadre.empty?
      ventas_credito_total_facturado_ = 0
      ventas_contado_total_facturado_ = 0

      ventas_contado = CabeceraFactura.where("(forma_pago = 'Efectivo' OR forma_pago = 'Cheque' OR forma_pago ='Tarjeta') and fecha_equivalente::date='#{fecha}' and fecha_completada::date='#{fecha}'")
      .where( { tipo: "venta", condicion: "Contado", is_viaje: false  })

      ventas_contado.each do |factura|
        recalculo = CabeceraFactura.recalcularMonto(factura)        
        ventas_contado_total_facturado_ = ventas_contado_total_facturado_ + recalculo[:total_facturado]
      end
      
      ventas_credito_ = CabeceraFactura.where( "fecha_equivalente::date='#{fecha}' and lower(tipo)='venta' and  lower(condicion)='crédito'")

      ventas_credito_.each do |factura|
        recalculo = CabeceraFactura.recalcularMonto(factura)        
        ventas_credito_total_facturado_ = ventas_credito_total_facturado_ + recalculo[:total_facturado]
      end

      recibos_ingresos_ = RecibosIngreso.where("(forma_pago = 'Efectivo' OR forma_pago = 'Cheque' OR forma_pago ='Tarjeta') and fecha_equivalente::date='#{fecha}'").sum(:total)

      obj = {
        user_id: current_user.id,
        total_general: (ventas_contado_total_facturado_ + recibos_ingresos_).round(2),
        total_venta_credito: ventas_credito_total_facturado_,
        total_venta_contado: ventas_contado_total_facturado_,
        total_recibo_ingreso: recibos_ingresos_,
        fecha_equivalente: DateTime.now -  (Date.today - Date.parse(params["fecha"])).to_i.day,
        total_anterior: 0,
        numero_reporte: CuadreCaja.find_numero_reporte,
      }
      
      cuadre = CuadreCaja.new(obj)
      
      CuadreCaja.transaction do
        unless cuadre.save!
          return { :error => true, :msg => cuadre.errors, :status => 400 }
        end

        att = cuadre.attributes
        att['usuario']= current_user.nombre.titleize + " " + current_user.apellido.titleize

        return { :error => false, :msg => "Cuadre realizado correctamente", :body => att, :status => 200 }
      end
    else

      user_cuadro = User.find_by_id(cuadre[0]["user_id"])
      obj = {
        user_id: cuadre[0]["user_id"],
        usuario: user_cuadro.nombre.titleize + " " + user_cuadro.apellido.titleize,
        fecha_equivalente: cuadre[0]["fecha_equivalente"],
        total_general: cuadre[0]["total_general"],
        total_venta_credito: cuadre[0]["total_venta_credito"],
        total_venta_contado: cuadre[0]["total_venta_contado"],
        total_recibo_ingreso: cuadre[0]["total_recibo_ingreso"],
        total_anterior: cuadre[0]["total_anterior"],
        numero_reporte: cuadre[0]["numero_reporte"],
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
