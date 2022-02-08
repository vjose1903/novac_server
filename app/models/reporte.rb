class Reporte < ApplicationRecord
    # ---------------------------------------------------------------------------------------------------------
    def self.estructura_reporte(titulo, _tipo_reporte, content, total_, sub_titulo_, tipo_tabla)

        current_user     = get_current_user

        temp_Emp         = current_user.nombre_completo
        longitud         = temp_Emp.length

        # maximo de caracteres 15
        obj= {
            titulo_reporte:titulo,
            tipo_reporte: _tipo_reporte,
            fecha: formatearFecha(DateTime.now.to_s ,2),
            realizado_por: longitud > 15 ? "#{temp_Emp[0, 15]}..." : temp_Emp,
            total: total_.round(2),
            mostrar_sub_titulo: sub_titulo_[:bool],
            sub_titulo: sub_titulo_[:sub_t],
            tipo_tabla: tipo_tabla,
            contenido_reporte: content,
        }
        
        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_suplidor(id, max_lengt=0)
        suplidor={}
        supli = Suplidor.find_by_id(id)

        tempNom = supli.nombre_completo
        
        if max_lengt > 0
            longitud= tempNom.length
            suplidor["nombre"] = longitud > max_lengt ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom
        else
            suplidor["nombre"] = tempNom
        end
        
        suplidor["rnc"] = DocumentoDeIdentidad.where({ principal: true, suplidor_id: supli["id"] })[0]["documento"]
        return suplidor
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_cliente(factura, max_lengt, retornar)
        cliente = {}
        if !factura["cliente_id"].nil? 

            cli = factura.cliente if (factura.instance_of? CabeceraFactura) || (factura.instance_of? RecibosIngreso)
            cli = Cliente.find_by_id(factura['cliente_id']) unless (factura.instance_of? CabeceraFactura) && (factura.instance_of? RecibosIngreso)

            tempNom = cli.nombre_completo
            longitud= tempNom.length
            
            cliente["nombre"] = longitud > max_lengt ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom if retornar.my_includes_str('nombre')
            cliente["rnc"] = cli.documentos_de_identidad.where({ principal: true })[0]["documento"] if retornar.my_includes_str('rnc')
        else
            if !factura["NoCliente_nombre"].nil?
                cliente["nombre"] = factura["NoCliente_nombre"]
                cliente["rnc"] = "-------------"
            end
        end

        return cliente
    end
    
    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_cuentas_cobrar(params)
        # tipo 1 = por cliente
        # tipo 2 = general detallado
        # tipo 3 = general agrupado
        tipo = params["tipo"]
        cliente_id = params["cliente_id"]
        longitud = tipo == '1' ? 55 : tipo == '2' ? 75 : 100 
        cuentas_temp = []

        query = {}
        query['tipo'] = "venta"
        query['estado'] = true

        if tipo == '1'
            query['cliente_id'] = cliente_id 
        end
    
        
        # cuentas_temp = CabeceraFactura.where(query).where("balance >= 1").order('id ASC')
        total_cuentas = 0
        cuentas = []
        inicio_select = "clientes.id, SUBSTRING(clientes.nombre || ' ' || clientes.apellido,0 ,#{longitud}) as cliente_nombre #{tipo == '3' ? '' : ', cabecera_facturas.fecha_equivalente, cabecera_facturas.id, cabecera_facturas.numero_comprobante'}"  

        select_ = ""
        if tipo == "1"
            select_ = "#{inicio_select}, cabecera_facturas.numero_comprobante, cabecera_facturas.condicion,
            cabecera_facturas.balance as total_pendiente" 
        else
            select_ = "#{inicio_select}, #{tipo == '3' ? 'sum (' : ''} cabecera_facturas.balance#{tipo == '3' ? ')' : ''} as total_pendiente,
            #{tipo == '3' ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 0  then cabecera_facturas.balance else 0 end  )  as cero_to_treinta,
            #{tipo == '3' ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 1  then cabecera_facturas.balance else 0 end  )  as treinta_uno_to_sesenta,
            #{tipo == '3' ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 2  then cabecera_facturas.balance else 0 end  )  as sesenta_uno_to_noventa,
            #{tipo == '3' ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) >= 3 then cabecera_facturas.balance else 0 end  )  as noventa_uno_to_more"
        end

        group_by = tipo == "1" ? "" : tipo == "2" ? "cabecera_facturas.id, clientes.id" : "clientes.id"

        CabeceraFactura.joins("inner join clientes on cabecera_facturas.cliente_id = clientes.id")
        .select(select_).where(query).where("cabecera_facturas.balance >= 1").group(group_by)
        .order("#{tipo == '3' ? '' : 'cabecera_facturas.fecha_equivalente ASC'}").each do |cf| 
            cabeza = cf.attributes
            total_cuentas += cabeza['total_pendiente']
            cabeza = sustituirMonto(cabeza ) if tipo == "2"
            cuentas.push(cabeza)
        end

        cuentas = cuentas.sort_by! { |k| k["total_pendiente"]}.reverse if tipo == '3'

        # numero_comprobante IN ('B0200005287')

        obj = { body: cuentas, total: (total_cuentas), sub_t: "Cliente: #{ buscar_cliente(query, 48, ['nombre'])["nombre"] }"}
        return obj
        
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.sustituirMonto(detalle)
        arrayDias = [ 'cero_to_treinta', 'treinta_uno_to_sesenta', 'sesenta_uno_to_noventa', 'noventa_uno_to_more' ]
        arrayDias.each do |item|
            detalle[item] = detalle[item] >= 1 ? detalle['numero_comprobante'] : 0
        end
        return detalle
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.calcularCantidades(articulos)
        array                         =[]
        plural                        = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos' }
        articulos.each do |articulo|
            obj                       = articulo.attributes
            obj["cantidades"]         = Articulo.calcularCantidades(articulo)
            
            cant                      = number_with_delimiter( ("%.2f" % obj["cantidades"][articulo['medida']]).gsub(',','.'))
            obj['cantidad_principal'] = "#{cant} #{cant.to_i == 1 ? articulo['medida'] : plural[articulo['medida'].to_sym]}"
            array.push(obj)
        end
        return array
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.get_inventario(params)

        inventario_temp    = []
        inventario_temp    = Articulo.all.where({estado: true}).order('nombre ASC')
        inventario_temp    = calcularCantidades(inventario_temp)
        cantidad_articulos = inventario_temp.length
        inventario         = inventario_temp.sort_by! { |k| k["nombre"]}

        obj = { body: inventario, total: 0, sub_t: "Cantidad de productos en inventario: #{ cantidad_articulos }"}
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

        query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        
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

            client = buscar_cliente(recibo, 39, ['nombre'])
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

        
        temp = DetalleFactura.where(query).select("detalle_facturas.* ,cabecera_facturas.suplidor_id, cabecera_facturas.fecha_equivalente").joins(:cabecera_factura).where(cabecera_facturas: query_join).order('detalle_facturas.id ASC')
        
        temp.each do |detalle|
            att = detalle.attributes
            suplidor = buscar_suplidor(detalle.suplidor_id)
            att["suplidor_nombre"]=suplidor['nombre']
            contenido.push(att)
            
        end
        
        articulo = Articulo.find_by_id(articulo_id)
        subT = "Producto: #{articulo.nombre}"
        
        obj = { body: contenido, total: 0, sub_t: subT}
        
    end


    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_cuentas_con_pagos(params)
        longitud      = 100 
        cuentas_temp  = []

        query                       = {}
        query['estado']             = true
        query['fecha_equivalente']  = (Date.parse params["desde"]).beginning_of_day..(Date.parse params["hasta"]).end_of_day
        query['tipo']               = 'venta'
        query['condicion']          = 'Crédito'
        query['is_nota']            = false
        query['cliente_id']         = params['cliente_id']
    
        total_cuentas = 0
        facturas      = []

        select_       = "cabecera_facturas.fecha_equivalente, cabecera_facturas.id, cabecera_facturas.numero_comprobante,
        cabecera_facturas.total_factura, cabecera_facturas.balance"

        
        
        CabeceraFactura.joins("inner join clientes on cabecera_facturas.cliente_id = clientes.id")
        .select(select_).where(query).order("cabecera_facturas.fecha_equivalente ASC").each do | cabeza_factura | 
          pagos_notas  = []
            puts " "
            puts "cabeza_factura ===> ".yellow + "#{cabeza_factura.to_json}" 

            total_cuentas += cabeza_factura.total_factura
            select_pago = "detalle_recibos.deposito, detalle_recibos.recibos_ingreso_id, detalle_recibos.id"
            select_nota = "cabecera_facturas.total_factura, cabecera_facturas.numero_comprobante, cabecera_facturas.fecha_equivalente, cabecera_facturas.id"

            cabeza_factura.detalle_recibos.select(select_pago).order("id ASC").each do | detalle_recibo |
              puts " "
              puts "detalle_recibo ".yellow + " #{detalle_recibo.to_json}"
              puts "detalle_recibo.recibos_ingreso_id ".blue + " #{detalle_recibo.recibos_ingreso_id}"
              recibo = RecibosIngreso.find_by_id(detalle_recibo.recibos_ingreso_id)
              puts " "
              puts "recibo ".red + " #{recibo.to_json}"
              pagos_notas.push({
                numero_documento: recibo.numero_recibo,
                id:               detalle_recibo.id,
                tipo:             'Recibo ingreso',
                fecha:            recibo.fecha_equivalente,
                total:            detalle_recibo.deposito
              })
            end
            CabeceraFactura.select(select_nota).where({aplicada_a: cabeza_factura.numero_comprobante, tipo_factura_id: 5}).order("id ASC").each do | nota |
                pagos_notas.push({
                  numero_documento: nota.numero_comprobante,
                  id:               nota.id,
                  tipo:             'Nota crédito',
                  fecha:            nota.fecha_equivalente,
                  total:            nota.total_factura
                })
            end
            contenido_titulo = []
            contenido_titulo.push({
              fecha_equivalente:  cabeza_factura["fecha_equivalente"],
              numero_comprobante: cabeza_factura["numero_comprobante"],
              total_factura:      cabeza_factura["total_factura"],
              balance:            cabeza_factura["balance"],
            })
            facturas.push({
              contenido_titulo:   contenido_titulo,
              contenido_grupo:    pagos_notas.sort_by! { |k| k[:fecha].to_i }
            })
        end

        # numero_comprobante IN ('B0200005287')
        cliente = Cliente.find_by_id(params["cliente_id"])
        puts "cliente ".red + "#{cliente.to_json}"

        subtitulo = "Cliente: #{ cliente.nombre_completo }, Facturas entre las fechas: #{formatearFecha(params["desde"], 1)} y #{formatearFecha(params["hasta"], 1)}"
        obj = { body: facturas, total: total_cuentas, sub_t: subtitulo}
        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.get_ventas_por_producto(params)
        temp = []
        temp_ventas = []
        ventas = []
        desde = params["desde"]
        hasta = params["hasta"].nil? ? params["desde"] : params["hasta"]

        sub_titulo = desde == hasta ? "Fecha: #{formatearFecha(desde, 1)}" : "Entre las fechas: #{formatearFecha(desde, 1)} y #{formatearFecha(hasta, 1)}"
        total_venta = 0
        query={}
        
        query['cabecera_facturas.fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

        query['cabecera_facturas.tipo'] = 'venta'
        query['cabecera_facturas.is_nota'] = false

        TipoArticulo.all.each do |tipo_articulo|
            temp_ventas = []
            query['articulos.tipo_articulo_id'] = tipo_articulo.id

            DetalleFactura .joins(:cabecera_factura, :articulo)
                .select("articulos.id as id, 
                    (articulos.nombre || case when articulos.calcular_saco = true then (case when detalle_facturas.calcular_saco = true then ' (Con saco)' else ' (Sin saco)' end ) else '' end) as nombre, 
                    sum(detalle_facturas.total - 
                        (select coalesce(sum(d_nota.total),0) from detalle_facturas d_nota 
                        INNER JOIN cabecera_facturas c_nota ON c_nota.id = d_nota.cabecera_factura_id
                        where d_nota.detalle_factura_nota = detalle_facturas.id and 
                        c_nota.fecha_equivalente BETWEEN '2021-02-28 20:00:00' AND '2021-03-31 19:59:59.999999' )) as total_vendido, 
                    sum(detalle_facturas.cantidad_en_unidades - 
                        (select coalesce(sum(d_nota.cantidad_en_unidades),0) from detalle_facturas d_nota 
                        INNER JOIN cabecera_facturas c_nota ON c_nota.id = d_nota.cabecera_factura_id
                        where d_nota.detalle_factura_nota = detalle_facturas.id and 
                        c_nota.fecha_equivalente BETWEEN '2021-02-28 20:00:00' AND '2021-03-31 19:59:59.999999' )) as cantidad_en_unidades")
                .where(query).order('id ASC')
                .group("articulos.id, nombre, detalle_facturas.calcular_saco")
                .each do |df| 
                    detalle = df.attributes
                    detalle['contenido'] = Articulo.calcularContenidos(Articulo.find_by_id(df.id), false)
                    temp_ventas.push detalle
                end

            total_grupo = calcular_cantidad_proporcional(temp_ventas)
            total_venta += total_grupo
            
            

            ventas.push({
              contenido_titulo:  tipo_articulo.descripcion,
              total:             total_grupo,
              contenido_grupo:   temp_ventas.sort_by! { |k| k['nombre']}
            })
        end

        ventas.push({
          contenido_titulo:  'TOTAL GENERAL',
            total:           total_venta,
            contenido_grupo: []
        })

        obj = { body: ventas, total: total_venta, sub_t: sub_titulo }
        
    end
    
    # ---------------------------------------------------------------------------------------------------------
    def self.calcular_cantidad_proporcional(productos)
        total_venta=0
        plural = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos' }
        productos.each do |producto|
            medida_mostrar = ""
            producto['contenido'].each do |key, value|
                articulo = Articulo.find_by_id(producto[:id])

                if producto['cantidad_en_unidades'] >= value
                    cant = producto['cantidad_en_unidades'] / value.to_f
                    medida_mostrar = "#{("%.2f" % cant).gsub(',','.')} #{cant == 1 ? key : plural[key.to_sym]}"
                    break
                end
            end
            producto["medida_mostrar"] = medida_mostrar
            total_venta += producto['total_vendido']
        end
        return total_venta
    end
    
    # ---------------------------------------------------------------------------------------------------------
    
    def self.get_ventas(params)

        tipo = params["tipo"]
        condicion = params["condicion"]
        desde = params["desde"]
        hasta = params["hasta"]
        formas_pago = params["formas_pago"]

        ventas_temp = []
        where_formas = "forma_pago IN #{formas_pago}"
        query={}
        if tipo == '1'
            query['fecha_equivalente'] = DateTime.now.beginning_of_day..DateTime.now.end_of_day
            query['condicion'] = condicion  if condicion != 'todos'
        elsif tipo == '2'
            query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
            if condicion != 'todos'
                query['condicion'] = condicion 
            end
        end

        query['tipo'] = 'venta'
        query['is_nota'] = false
        

        select_ = "cabecera_facturas.id, clientes.id as cliente_id, coalesce(SUBSTRING(clientes.nombre || ' ' || clientes.apellido,0 ,48),'Cliente contado') as cliente_nombre,
        doc.suplidor_id as suplidor_id, cabecera_facturas.tipo_factura_id as tipo_factura_id,
        cabecera_facturas.fecha_equivalente,
        coalesce(doc.documento,'-------------' ) as cliente_rnc,
        cabecera_facturas.numero_comprobante, cabecera_facturas.condicion,
        cabecera_facturas.total_factura" 

        total_ventas=0

        ventas = CabeceraFactura.joins("LEFT JOIN clientes ON cabecera_facturas.cliente_id = clientes.id")
        .joins("LEFT JOIN documentos_de_identidad doc ON cabecera_facturas.cliente_id = doc.cliente_id and doc.principal = true")
        .select(select_).where(query).where(where_formas)
        .order("cabecera_facturas.fecha_equivalente ASC").each do |cf| 
            total_ventas += cf['total_factura']
        end
        

        obj = { body: ventas, total: total_ventas , sub_t:''}

        return obj
    end



    # ---------------------------------------------------------------------------------------------------------
end
