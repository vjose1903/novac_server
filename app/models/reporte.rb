class Reporte < ApplicationRecord
    # ---------------------------------------------------------------------------------------------------------
    def self.estructura_reporte(titulo, _tipo_reporte, content, total_ ,sub_titulo_ ,current_user)
        temp_Emp = current_user.nombre.titleize + " " + current_user.apellido.titleize
        longitud= temp_Emp.length
        # maximo de caracteres 15
        obj= {
            titulo_reporte:titulo,
            tipo_reporte: _tipo_reporte,
            fecha: formatearFecha(DateTime.now.to_s ,2),
            realizado_por: longitud > 15 ? "#{temp_Emp[0, 15]}..." : temp_Emp,
            mostrar_total: total_[:bool],
            total: total_[:bool] ? total_[:total] : 0,
            mostrar_sub_titulo: sub_titulo_[:bool],
            sub_titulo: sub_titulo_[:sub_t],
            contenido_reporte: content,
        }
        
        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_cliente(factura, max_lengt)
        cliente = {}
        if !factura["cliente_id"].nil? 
            cli = Cliente.find_by_id(factura["cliente_id"])
            tempNom = "#{cli["nombre"]}".titleize + " #{cli["apellido"]}".titleize
            longitud= tempNom.length

            cliente["nombre"] = longitud > max_lengt ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom
            cliente["rnc"] = DocumentoDeIdentidad.where({ principal: true, cliente_id: cli["id"] })[0]["documento"]
        else
            if !factura["NoCliente_nombre"].nil?
                cliente["nombre"] = factura["NoCliente_nombre"]
                cliente["rnc"] = "-------------"
            end
        end

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
        
        cuentas_temp = CabeceraFactura.where(query).where("balance >= 1").order('id ASC')

        total_cuentas=0
        cuentas = []
        cuentas_temp.each do |cuenta|
            
            att = cuenta.attributes
            
            att = get_antiguedad_saldo(att)

            if att['tiene_nota']
                att['total_factura'] = recalculo_por_nota(att)
            end

            total_cuentas += att['total_factura']
            client = buscar_cliente(att, 13)

            att['cliente_nombre'] = client['nombre']
            att['cliente_rnc'] = client['rnc']

            cuentas.push(att)
        end

        obj = { body: cuentas, total: (total_cuentas).round(2), sub_t: "Cliente: #{ buscar_cliente(query, 48)["nombre"] }"}
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
        ventas_temp = CabeceraFactura.where(query).order('id ASC')
        
        ventas=[]
        total_ventas=0
        ventas_temp.each do |factura|
            att = factura.attributes
            
            if att['tiene_nota']
                att['total_factura'] = recalculo_por_nota(att)
            end

            total_ventas += att['total_factura']
            client = buscar_cliente(att, 48)
            att['cliente_nombre'] = client['nombre']
            att['cliente_rnc'] = client['rnc']
            
            ventas.push(att)
        end

        obj = { body: ventas, total: total_ventas , sub_t:''}

        return obj
    end



    # ---------------------------------------------------------------------------------------------------------
end
