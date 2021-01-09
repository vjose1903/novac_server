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
    def self.buscar_suplidor(id, max_lengt=0)
        suplidor={}
        supli = Suplidor.find_by_id(id)

        puts 'id -->'.yellow + "#{id}"
        puts 'supli -->'.yellow + "#{supli.to_json}"
        tempNom = "#{supli["nombre"]}".titleize + " #{supli["apellido"]}".titleize
        
        if max_lengt > 0
            longitud= tempNom.length
            suplidor["nombre"] = longitud > max_lengt ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom
        else
            suplidor["nombre"] = tempNom
        end
        
        suplidor["rnc"] = DocumentoDeIdentidad.where({ principal: true, suplidor_id: supli["id"] })[0]["documento"]
        puts 'suplidor -->'.yellow + "#{suplidor.to_json}"
        return suplidor
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
            factura['balance'] += nota['total_factura']
            # if descripcion == 'credito'
            #     att['total_factura'] -= nota['total_factura']
            # elsif descripcion == 'contado'
            # end
        end
        obj = {
            total_factura: (factura['total_factura']).round(2),
            balance: (factura['balance']).round(2),
        }
        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_cuentas_cobrar(params)
        tipo = params["tipo"]
        cliente_id = params["cliente_id"]
        longitud = 11 
        cuentas_temp = []
        query = {}
        query['tipo'] = "venta"

        if tipo == '2'
            query['cliente_id'] = cliente_id 
            longitud = 48 
        end
        
        cuentas_temp = CabeceraFactura.where(query).where("balance >= 1").order('id ASC')

        total_cuentas=0
        cuentas = []
        cuentas_temp.each do |cuenta|
            
            att = cuenta.attributes
            
            att = get_antiguedad_saldo(att)

            if att['tiene_nota']
                recalculo = recalculo_por_nota(att)
                att['total_factura'] = recalculo[:total_factura]
                att['balance'] = recalculo[:balance]
            end

            total_cuentas += att['balance']
            client = buscar_cliente(att, longitud)

            att['cliente_nombre'] = client['nombre']
            att['cliente_rnc'] = client['rnc']

            cuentas.push(att)
        end

        obj = { body: cuentas, total: (total_cuentas).round(2), sub_t: "Cliente: #{ buscar_cliente(query, 48)["nombre"] }"}
        # obj = { body: cuentas, total: 0 }

        return obj
        
    end
    
    # ---------------------------------------------------------------------------------------------------------
    def self.calcularCantidades(articulos)
        array=[]
        plural = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos' }
        articulos.each do |articulo|
            obj                       = articulo.attributes
            obj["cantidades"]         = Articulo.calcularCantidades(articulo)
            # cant = number_with_delimiter(obj["cantidades"][articulo['medida']] , :precision => 2, :delimiter => ",", :separator => ".")
            
            cant = number_with_delimiter( ("%.2f" % obj["cantidades"][articulo['medida']]).gsub(',','.'))
            obj['cantidad_principal'] = "#{cant} #{cant.to_i == 1 ? articulo['medida'] : plural[articulo['medida'].to_sym]}"
            array.push(obj)
        end
        return array
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.get_inventario(params)
        inventario_temp = []
        query={}
        inventario_temp = Articulo.all    
        inventario_temp = calcularCantidades(inventario_temp)
        
        inventario = inventario_temp.sort_by! { |k| k["nombre"]}
        cantidad_articulos = Articulo.countArticulos
        obj = { body: inventario, total: 0, sub_t: "Cantidad de productos en inventario: #{ cantidad_articulos['count'] }"}
        
        return obj
        
    end
    
    # ---------------------------------------------------------------------------------------------------------

    def self.getInfoFactura(objeto, buscando)
        obj={}
        id = objeto.detalle_recibos[0].cabecera_factura_id
        buscando.each do |target|
            obj[target]= CabeceraFactura.find_by_id(id)[target]
        end
        return obj
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.get_recibos(params)
        temp = []
        recibos = []
        query={}
        desde = params["desde"]
        hasta = params["hasta"]
        tipo_recibo = params["tipo_recibo"]
        order = params["order"]

        query['fecha_equivalente'] = desde..hasta
        
        if tipo_recibo == 'todos'
            subT='Tipo de recibo: TODOS'
            temp = RecibosIngreso.where(query).order("id #{order}")
        else
            if tipo_recibo == 'viajes'
                subT='Tipo de recibo: VIAJES'
                temp = RecibosIngreso.where(query).where.not(vehiculo_id: nil).order("id #{order}")
            elsif tipo_recibo == 'normal'
                subT='Tipo de recibo: NORMAL'
                temp = RecibosIngreso.where(query).where(vehiculo_id: nil).order("id #{order}")
            end
        end

        total_recibido = 0
        temp.each do |recibo|
            att = recibo.attributes
            total_recibido += recibo['total']

            client = buscar_cliente(att, 48)
            att['cliente_nombre'] = client['nombre']
            att['tipo_recibo'] = att["vehiculo_id"] ? 'Viaje' : 'Normal'
            factura = getInfoFactura(recibo, ['numero_comprobante'])
            att['factura'] = factura['numero_comprobante']
            recibos.push(att)
        end
        
        obj = { body: recibos, total: total_recibido, sub_t: subT}
        
        
    end
    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_suplidores_por_producto(params)
        articulo_id = params["articulo_id"]
        desde = params["desde"]
        hasta = params["hasta"]
        
        temp = []
        contenido = []
        query={}
        query_join={}
        query['articulo_id'] = articulo_id
        query_join['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        query_join['tipo'] = 'compra'

        
        temp = DetalleFactura.where(query).select("detalle_facturas.* ,cabecera_facturas.suplidor_id,cabecera_facturas.fecha_equivalente").joins(:cabecera_factura).where(cabecera_facturas: query_join).order('detalle_facturas.id ASC')

        temp.each do |detalle|
            att =detalle.attributes
            suplidor = buscar_suplidor(detalle.suplidor_id)
            att["suplidor_nombre"]=suplidor['nombre']
            contenido.push(att)
            
        end
        
        articulo = Articulo.find_by_id(articulo_id)
        subT = "Producto: #{articulo.nombre}"

        obj = { body: contenido, total: 0, sub_t: subT}

    end
    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_ventas_por_producto(params)
        temp = []
        temp_ventas = []
        ventas = []
        fecha = params["fecha"]
        total_venta=0
        query={}
        
        query['fecha_equivalente'] = (Date.parse fecha).beginning_of_day..(Date.parse fecha).end_of_day
        query['tipo'] = 'venta'
        query['is_nota'] = false
        temp = CabeceraFactura.where(query).order('id ASC')
        
        temp.each do |factura|
            
            factura.detalle_facturas.each do |detalle|
                
                articulo = Articulo.find_by_id(detalle.articulo_id)
                is_in_array = temp_ventas.any? {|h| h[:id] == detalle.articulo_id}
                se_calcula_saco = Articulo.checkFechaCalcularSaco(factura["fecha_equivalente"], articulo)
                
                entrar = false
                unless is_in_array
                    entrar = true
                else
                    if se_calcula_saco 
                        if detalle.calcular_saco 
                            index = temp_ventas.index {|h| h[:id] == detalle.articulo_id && h[:calcular_saco] == true}
                            if index 
                                temp_ventas[index][:cantidad_en_unidades] += detalle.cantidad_en_unidades
                                temp_ventas[index][:total_vendido] += detalle.total
                            else
                                entrar = true
                            end
                        else
                            index = temp_ventas.index {|h| h[:id] == detalle.articulo_id && h[:calcular_saco] == false}
                            if index 
                                temp_ventas[index][:cantidad_en_unidades] += detalle.cantidad_en_unidades
                                temp_ventas[index][:total_vendido] += detalle.total
                            else
                                entrar = true
                            end
                        end     
                    else
                        index = temp_ventas.index {|h| h[:id] == detalle.articulo_id}
                        temp_ventas[index][:cantidad_en_unidades] += detalle.cantidad_en_unidades
                        temp_ventas[index][:total_vendido] += detalle.total
                    end 
                end
                
                nombre = ""
                
                if se_calcula_saco
                    nombre  = articulo.nombre + "  (#{detalle.calcular_saco ? 'Con saco': 'Sin saco'})"
                else
                    nombre  = articulo.nombre
                end

                if entrar
                    temp_ventas.push({
                        nombre: nombre,
                        id: articulo.id,
                        cantidad_en_unidades: detalle.cantidad_en_unidades,
                        calcular_saco: detalle.calcular_saco,
                        contenido: Articulo.calcularContenidos(articulo, false),
                        total_vendido: detalle.total,
                    })
                end
            end
        end
        
        total_venta = calcular_cantidad_proporcional(temp_ventas)

        ventas = temp_ventas.sort_by! { |k| k[:nombre]}
        
        obj = { body: ventas, total: total_venta, sub_t: "Fecha: #{formatearFecha(fecha, 1)}" }
        
    end
    
    # ---------------------------------------------------------------------------------------------------------
    def self.calcular_cantidad_proporcional(productos)
        total_venta=0
        plural = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos' }
        productos.each do |producto|
            medida_mostrar = ""
            producto[:contenido].each do |key, value|
                articulo = Articulo.find_by_id(producto[:id])

                if producto[:cantidad_en_unidades] >= value
                    cant = producto[:cantidad_en_unidades] / value.to_f
                    medida_mostrar = "#{("%.2f" % cant).gsub(',','.')} #{cant == 1 ? key : plural[key.to_sym]}"
                    break
                end
            end
            producto["medida_mostrar"] = medida_mostrar
            total_venta += producto[:total_vendido]
        end
        return total_venta
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
                recalculo = recalculo_por_nota(att)
                att['total_factura'] = recalculo[:total_factura]
                att['balance'] = recalculo[:balance]
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
