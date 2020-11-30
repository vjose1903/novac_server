class Reporte < ApplicationRecord
    # ---------------------------------------------------------------------------------------------------------
    def self.estructura_reporte(titulo, _tipo_reporte, content, total_ ,sub_titulo_ ,current_user)
        obj= {
            titulo_reporte:titulo,
            tipo_reporte: _tipo_reporte,
            fecha: formatearFecha(DateTime.now.to_s ,2),
            realizado_por: current_user.nombre.titleize + " " + current_user.apellido.titleize,
            mostrar_total: total_[:bool],
            total: total_[:bool] ? total_[:total] : 0,
            mostrar_sub_titulo: sub_titulo_[:bool],
            sub_titulo: sub_titulo_[:sub_t],
            contenido_reporte: content,
        }
        
        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_nombre_cliente(factura)
        puts "factura ==> ".red + "#{factura}"
        cliente = ''
        if !factura["cliente_id"].nil? 
            puts "ENTROOOO".yellow
            puts "factura['cliente_id'] ==> ".red + "#{factura['cliente_id']}"
            puts "factura['cliente_id'] 11 ==> ".red + "#{factura[:cliente_id]}"
            cli = Cliente.find_by_id(factura["cliente_id"])
            cliente = "#{cli["nombre"]}".titleize + " #{cli["apellido"]}".titleize
        else
            if !factura["NoCliente_nombre"].nil?
                cliente = factura["NoCliente_nombre"]
            end
        end

        puts "cliente ==> ".green + "#{cliente}"
        return cliente
    end
    # ---------------------------------------------------------------------------------------------------------

    def self.get_antiguedad_saldo(factura)
        factura['cero_to_treinta']= "-"
        factura['treinta_uno_to_sesenta']= "-"
        factura['sesenta_uno_to_noventa']= "-"
        factura['noventa_uno_to_more']= "-"

        if comparar_fecha( factura['fecha_equivalente'].to_s, 1.minutes.ago.to_s, '<=') && comparar_fecha( factura['fecha_equivalente'].to_s, 30.days.ago.to_s, '>=')
            factura['cero_to_treinta'] = factura['numero_comprobante']
        elsif comparar_fecha(factura['fecha_equivalente'].to_s , 31.days.ago.to_s,'<=')  && comparar_fecha(factura['fecha_equivalente'].to_s, 60.days.ago.to_s,'>=') 
            factura['treinta_uno_to_sesenta']= factura['numero_comprobante']
        elsif comparar_fecha(factura['fecha_equivalente'].to_s, 61.days.ago.to_s,'<=')  && comparar_fecha(factura['fecha_equivalente'].to_s, 90.days.ago.to_s,'>=') 
            factura['sesenta_uno_to_noventa']= factura['numero_comprobante']
        elsif comparar_fecha(factura['fecha_equivalente'].to_s, 91.days.ago.to_s, '<=')
            factura['noventa_uno_to_more']= factura['numero_comprobante']
        end
        return factura
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.recalculo_por_nota(factura)
        notas = CabeceraFactura.where({aplicada_a: factura['numero_comprobante']})

        notas.each do |nota|
            tipo_nota = TipoFactura.find_by_id(nota['tipo_factura_id'])
            descripcion = tipo_nota.descripcion.split(" ")[2]

            factura['total_factura'] += nota['total_factura']
            # if descripcion == 'credito'
            #     att['total_factura'] -= nota['total_factura']
            # elsif descripcion == 'contado'
            # end
        end
        return (factura['total_factura']).round(2)
    end
    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_cuentas_cobrar(params)
        tipo = params["tipo"]
        cliente_id = params["cliente_id"]
        
        cuentas_temp = []
        query = {}
        if tipo == '2'
            query['cliente_id'] = cliente_id 
        end
        
        cuentas_temp = CabeceraFactura.where(query).where("balance >= 1")

        total_cuentas=0
        cuentas = []
        cuentas_temp.each do |cuenta|
            att = cuenta.attributes
            
            att = get_antiguedad_saldo(att)

            if att['tiene_nota']
                att['total_factura'] = recalculo_por_nota(att)
            end

            total_cuentas += att['total_factura']
            att['cliente_nombre'] = buscar_nombre_cliente(att)

            cuentas.push(att)
        end

        obj = { body: cuentas, total: (total_cuentas).round(2), sub_t: "Cliente: #{ buscar_nombre_cliente(query) }"}
        # obj = { body: cuentas, total: 0 }

        return obj

    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_ventas(params)

        tipo = params["tipo"]
        condicion = params["condicion"]
        desde = params["desde"]
        hasta = params["hasta"]

        ventas_temp = []
        query={}
        if tipo == '1'
            query['fecha_equivalente'] = DateTime.now.beginning_of_day..DateTime.now.end_of_day
            if condicion != 'todos'
                query['condicion'] = condicion 
            end
        elsif tipo == '2'
            query['fecha_equivalente'] = desde..hasta
            if condicion != 'todos'
                query['condicion'] = condicion 
            end
        end

        query['tipo'] = 'venta'
        query['is_nota'] = false
        ventas_temp = CabeceraFactura.where(query)
        
        ventas=[]
        total_ventas=0
        ventas_temp.each do |factura|
            att = factura.attributes
            
            if att['tiene_nota']
                att['total_factura'] = recalculo_por_nota(att)
            end

            total_ventas += att['total_factura']
            att['cliente_nombre'] = buscar_nombre_cliente(att)
            
            ventas.push(att)
        end

        obj = { body: ventas, total: total_ventas , sub_t:''}

        return obj
    end



    # ---------------------------------------------------------------------------------------------------------
end
