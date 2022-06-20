class Reporte < ApplicationRecord
    # ---------------------------------------------------------------------------------------------------------
    def self.estructura_reporte(titulo, _tipo_reporte, content, totalizacion, sub_titulo_, tipo_tabla)

        current_user     = get_current_user

        temp_Emp         = current_user.nombre_completo
        longitud         = temp_Emp.length

        # maximo de caracteres 15
        obj = {
            titulo_reporte:         titulo,
            tipo_reporte:           _tipo_reporte,
            fecha:                  formatearFecha(DateTime.now.to_s ,2),
            realizado_por:          longitud > 15 ? "#{temp_Emp[0, 15]}..." : temp_Emp,
            bruto:                  totalizacion[:bruto].round(2),
            devuelto:               totalizacion[:devuelto].round(2),
            total:                  totalizacion[:total].round(2),
            mostrar_sub_titulo:     sub_titulo_[:bool],
            sub_titulo:             sub_titulo_[:sub_t],
            tipo_tabla:             tipo_tabla,
            contenido_reporte:      content,
        }

        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_suplidor(supli, max_lengt=0)
        suplidor={}

        suplidor["nombre"]   = supli.nombre_completo
        longitud             = suplidor["nombre"].length

        suplidor["nombre"] = "#{tempNom[0, (max_lengt + 1)]}..." if max_lengt > 0 && ( longitud > max_lengt )

        documento              = supli.documentos_de_identidad.find { | doc |  doc.principal == true }
        suplidor["rnc"]        = documento.nil? ? '----------' : documento["documento"]

        return suplidor
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_cliente(factura, max_lengt, retornar)
        cliente = {}
        if !factura["cliente_id"].nil?

            cli = factura.cliente if (factura.instance_of? CabeceraFactura) || (factura.instance_of? RecibosIngreso)
            cli = Cliente.find_by_id(factura['cliente_id']) if (!factura.instance_of? CabeceraFactura) && (!factura.instance_of? RecibosIngreso)


            tempNom = cli.nombre_completo
            longitud= tempNom.length

            cliente["nombre"] = longitud > max_lengt ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom if retornar.my_includes_str('nombre')

            documento = cli.documentos_de_identidad.find { |doc| doc.principal == true } if retornar.my_includes_str('rnc')
            cliente["rnc"] = documento.nil? ? "----------" : documento.documento   if retornar.my_includes_str('rnc')
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
        tipo                = params["tipo"]
        cliente_id          = params["cliente_id"]
        longitud            = tipo == '1' ? 55 : tipo == '2' ? 75 : 100
        cuentas_temp        = []

        query               = {}
        query['tipo']       = "venta"
        query['estado']     = true

        query['cliente_id'] = cliente_id if tipo == '1'

        total_cuentas       = 0
        cuentas             = []
        inicio_select       = "clientes.id, SUBSTRING(clientes.nombre || ' ' || clientes.apellido,0 ,#{longitud}) as cliente_nombre #{tipo == '3' ? '' : ', cabecera_facturas.fecha_equivalente, cabecera_facturas.id, cabecera_facturas.numero_comprobante'}"

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

        obj = { body: cuentas, totalizacion: { bruto: 0, devuelto: 0, total: total_cuentas }, sub_t: "Cliente: #{ buscar_cliente(query, 48, ['nombre'])["nombre"] }"}
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
        inventario_temp    = Articulo.all.where({estado: true}).order('nombre ASC').includes(Articulo.models_includes)
        inventario_temp    = calcularCantidades(inventario_temp)
        cantidad_articulos = inventario_temp.length
        inventario         = inventario_temp.sort_by! { |k| k["nombre"]}

        obj = { body: inventario, totalizacion: { bruto: 0, devuelto: 0, total: 0 }, sub_t: "Cantidad de productos en inventario: #{ cantidad_articulos }"}
        return obj
    end


    # ---------------------------------------------------------------------------------------------------------
    def self.get_notas(params)
      temp        = []
      notas       = []
      query       = {}
      desde       = params["desde"]
      hasta       = params["hasta"].nil? ? params["desde"] : params["hasta"]
      tipo_nota   = params["tipo_factura_id"].to_i

      query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
      query['tipo_factura_id']   = tipo_nota unless tipo_nota == 0

      temp = FacturaAplicada
			.joins("inner join notas on notas.id = facturas_aplicadas.nota_id")
			.joins("inner join cabecera_facturas on cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id")
			.where(notas: query)
			.order("id DESC").includes(FacturaAplicada.models_includes)

      temp.each do | factura_aplicada |
				tipo_nota = factura_aplicada.nota.tipo_factura_id == TiposFacturasId.nota_de_credito  ? 'Crédito' : 'Débito'

				notas.push({
					:factura => factura_aplicada.cabecera_factura.numero_comprobante,
					:numero_comprobante => factura_aplicada.nota.numero_comprobante,
					:tipo_nota => "nota de #{tipo_nota.downcase}",
					:fecha => factura_aplicada.nota.fecha_equivalente,
					:monto => factura_aplicada.total.abs,
				})

      end

      subT = "Notas entre las fechas: #{formatearFecha(params["desde"], 1)} y #{formatearFecha(params["hasta"], 1)}"
      obj  = { body: notas, totalizacion: { bruto: 0, devuelto: 0, total: 0 }, sub_t: subT}
    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_recibos(params)
        temp         = []
        recibos      = []
        query        = {}
        desde        = params["desde"]
        hasta        = params["hasta"].nil? ? params["desde"] : params["hasta"]
        tipo_recibo  = params["tipo_recibo"]
        order        = params["order"]

        query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

        if tipo_recibo == 'todos'
          subT='Tipo de recibo: TODOS'
          temp = RecibosIngreso.where(query).order("id #{order}").includes(RecibosIngreso.models_includes)
        else
          if tipo_recibo == 'viajes'
            subT='Tipo de recibo: VIAJES'
            temp = RecibosIngreso.where(query).where.not(vehiculo_id: nil).order("id #{order}").includes(RecibosIngreso.models_includes)
          elsif tipo_recibo == 'normal'
            subT='Tipo de recibo: NORMAL'
            temp = RecibosIngreso.where(query).where(vehiculo_id: nil).order("id #{order}").includes(RecibosIngreso.models_includes)
          end
        end

        total_recibido = 0
        temp.each do |recibo|
          att = recibo.attributes
          total_recibido += recibo['total']

          client                 = buscar_cliente(recibo, 55, ['nombre'])
          att['cliente_nombre']  = client['nombre']
          att['tipo_recibo']     = att["vehiculo_id"] ? 'Viaje' : 'Normal'
          recibos.push(att)
        end

        obj = { body: recibos, totalizacion: { bruto: 0, devuelto: 0, total: total_recibido }, sub_t: subT}


    end
    # ---------------------------------------------------------------------------------------------------------

    def self.get_suplidores_por_producto(params)
        articulo_id                      = params["articulo_id"]
        desde                            = params["desde"]
        hasta                            = params["hasta"]

        temp                             = []
        contenido                        = []
        query                            = {}
        query_join                       = {}
        query['articulo_id']             = articulo_id
        query_join['fecha_equivalente']  = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        query_join['tipo']               = 'compra'


        temp = DetalleFactura.where(query).select("detalle_facturas.* ,cabecera_facturas.suplidor_id, cabecera_facturas.fecha_equivalente").joins(:cabecera_factura).where(cabecera_facturas: query_join).order('detalle_facturas.id ASC').includes([{ cabecera_factura: [{suplidor: [:documentos_de_identidad]}] } ])

        temp.each do |detalle|
          att                          = detalle.attributes
          suplidor                     = buscar_suplidor(detalle.cabecera_factura.suplidor)
          att["suplidor_nombre"]       = suplidor['nombre']

          contenido.push(att)
        end

        articulo = Articulo.find_by_id(articulo_id)
        subT = "Producto: #{articulo.nombre}"

        obj = { body: contenido, totalizacion: { bruto: 0, devuelto: 0, total: 0 }, sub_t: subT}

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
        cliente = nil

        CabeceraFactura.where(query).order("cabecera_facturas.fecha_equivalente ASC").includes([{detalle_recibos: [:recibos_ingreso]}, {facturas_aplicadas: [:nota]}, :cliente]).each do | cabeza_factura |
          pagos_notas  = []

          total_cuentas += cabeza_factura.total_factura

          cabeza_factura.detalle_recibos.each do | detalle_recibo |
            recibo = detalle_recibo.recibos_ingreso

            pagos_notas.push({
              numero_documento: recibo.numero_recibo,
              tipo:             'Recibo ingreso',
              fecha:            recibo.fecha_equivalente,
              total:            detalle_recibo.deposito
              })
            end

          facturas_aplicadas = cabeza_factura.facturas_aplicadas.select { |factura_aplicada| factura_aplicada.nota.estado == true }

          facturas_aplicadas.each do | fectura_aplicada |
            nota = fectura_aplicada.nota

            pagos_notas.push({
              numero_documento: nota.numero_comprobante,
              tipo:             'Nota crédito',
              fecha:            nota.fecha_equivalente,
              total:            fectura_aplicada.total
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

          cliente = cabeza_factura.cliente
        end



        subtitulo = "Cliente: #{ cliente.nombre_completo }, Facturas entre las fechas: #{formatearFecha(params["desde"], 1)} y #{formatearFecha(params["hasta"], 1)}"
        obj = { body: facturas, totalizacion: { bruto: 0, devuelto: 0, total: total_cuentas }, sub_t: subtitulo}
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
          total_grupo = 0
          temp_ventas = []
          query['articulos.tipo_articulo_id'] = tipo_articulo.id

          select_ = "coalesce(sum(detalles_facturas_notas.cantidad_en_unidades), 0) as cantidad_devuelto, coalesce(sum(detalles_facturas_notas.total), 0) as total_devuelto,
                    detalle_facturas.articulo_id, sum(detalle_facturas.descuento_valor ) as descuento_valor, sum(detalle_facturas.total ) as total, sum(detalle_facturas.cantidad_en_unidades) as cantidad_en_unidades, sum(detalle_facturas.itbis) as itbis"

          joins_ = "inner join cabecera_facturas on cabecera_facturas.id = detalle_facturas.cabecera_factura_id
                    inner join articulos on articulos.id = detalle_facturas.articulo_id
                    left join detalles_facturas_notas on detalles_facturas_notas.detalle_factura_id  = detalle_facturas.id"

          DetalleFactura.select(select_).joins(joins_).where(query).order('articulo_id ASC').group("detalle_facturas.articulo_id")
          .includes([{articulo: [:contenido_articulos, :tipo_articulo]} ]).each do |df|

            detalle                          = df.attributes
            detalle['nombre']                = df.articulo.nombre
            detalle['total_vendido']         = df.total
            detalle['total_general']         = detalle['total_vendido'] - df.total_devuelto
            detalle['contenido']             = Articulo.calcularContenidos(df.articulo, false)
            detalle['contenido']             = Articulo.calcularContenidos(df.articulo, false)

            mostrar = calcular_cantidad_proporcional(detalle)
            detalle['vendido_mostrar']       = mostrar["vendido_mostrar"]
            detalle['devuelto_mostrar']      = mostrar["devuelto_mostrar"]

            total_grupo += detalle['total_general']

            temp_ventas.push detalle
          end

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
          contenido_grupo: nil
        })

        obj = { body: ventas, totalizacion: { bruto: 0, devuelto: 0, total: total_venta }, sub_t: sub_titulo }

    end

    # ---------------------------------------------------------------------------------------------------------
    def self.calcular_cantidad_proporcional(producto)
      total_venta=0
      plural = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos' }

      vendido_mostrar = "0.00"
      devuelto_mostrar = "0.00"

      producto['contenido'].each do |key, value|
        if producto['cantidad_en_unidades'] >= value
          cant = producto['cantidad_en_unidades'] / value.to_f
          vendido_mostrar = "#{("%.2f" % cant).gsub(',','.')} #{cant == 1 ? key : plural[key.to_sym]}"
          break
        end
      end

      producto['contenido'].each do |key, value|
        if producto['cantidad_devuelto'] >= value
          cant = producto['cantidad_devuelto'] / value.to_f
          devuelto_mostrar = "#{("%.2f" % cant).gsub(',','.')} #{cant == 1 ? key : plural[key.to_sym]}"
          break
        end
      end

      return { "vendido_mostrar" => vendido_mostrar, "devuelto_mostrar" => devuelto_mostrar }
    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_ventas(params)

        tipo           = params["tipo"]
        condicion      = params["condicion"]
        desde          = params["desde"]
        hasta          = params["hasta"]
        formas_pago    = params["formas_pago"]

        ventas_temp    = []
        where_formas   = "forma_pago IN #{formas_pago}"
        query          = {}

        is_viaje_credito = "( lower(condicion) = 'crédito' )"
        is_viaje_contado = tipo == '1' ? "( lower(condicion) = 'contado' AND is_viaje = false )" : "( lower(condicion) = 'contado')"
        query_is_viaje   = condicion.downcase == 'todos' ?  "#{is_viaje_contado} OR #{is_viaje_credito}" : condicion.downcase == 'contado' ? is_viaje_contado : is_viaje_credito

        query['fecha_equivalente'] = tipo == '1' ?  DateTime.now.beginning_of_day..DateTime.now.end_of_day : (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

        query['tipo']    = 'venta'
        query['is_nota'] = false

        select_ = "cabecera_facturas.id, coalesce(SUBSTRING(clientes.nombre || ' ' || clientes.apellido,0 ,48),'Cliente contado') as cliente_nombre,
        cabecera_facturas.tipo_factura_id as tipo_factura_id,
        cabecera_facturas.fecha_equivalente,
        cabecera_facturas.numero_comprobante, cabecera_facturas.condicion,
        cabecera_facturas.total_factura,
        coalesce(sum(facturas_aplicadas.total), 0) as total_devuelto"

        joins_="LEFT JOIN clientes ON cabecera_facturas.cliente_id = clientes.id
                LEFT JOIN facturas_aplicadas ON cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id"

        group_by="cabecera_facturas.id, clientes.nombre, clientes.apellido"

        total_devuelto = 0
        bruto = 0

        ventas = CabeceraFactura
        .select(select_).joins(joins_).where(query).where(where_formas).where(query_is_viaje).group(group_by)
        .order("cabecera_facturas.fecha_equivalente ASC").each do |cf|
            total_devuelto += cf['total_devuelto']
            bruto   += cf['total_factura']
        end

        total_ventas = bruto - total_devuelto

        obj = { body: ventas, totalizacion: { bruto: bruto, devuelto: total_devuelto, total: total_ventas } , sub_t:''}

        return obj
    end



    # ---------------------------------------------------------------------------------------------------------
end
