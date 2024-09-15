class Reporte < ApplicationRecord
    # ---------------------------------------------------------------------------------------------------------
    def self.estructura_reporte(arg)
        titulo           = arg[:titulo]
        tipo_reporte     = arg[:tipo_reporte]
        content          = arg[:content]
        totalizacion     = arg[:totalizacion]
        sub_titulo       = arg[:sub_titulo]
        tipo_tabla       = arg[:tipo_tabla]

        current_user     = get_current_user

        temp_Emp         = current_user.nombre_completo
        longitud         = temp_Emp.length

        # máximo de caracteres 15
        obj = {
            titulo_reporte:         titulo,
            tipo_reporte:           tipo_reporte,
            fecha:                  formatearFecha(DateTime.now.to_s ,TipoFecha.con_hora),
            realizado_por:          longitud > 15 ? "#{temp_Emp[0, 15]}..." : temp_Emp,
            itbis:                  totalizacion[:itbis].round(2),
            bruto:                  totalizacion[:bruto].round(2),
            descuento:              totalizacion[:descuento].round(2),
            devuelto:               totalizacion[:devuelto].round(2),
            total:                  totalizacion[:total].round(2),
            mostrar_sub_titulo:     sub_titulo[:bool],
            sub_titulo:             sub_titulo[:sub_t],
            tipo_tabla:             tipo_tabla,
            contenido_reporte:      content,
        }

        return obj
    end
    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_suplidor(suplidor_id, max_lengt=0, retornar)
        objSuplidor = {}
				unless suplidor_id.nil?
					suplidor    = Suplidor.find_by_id(suplidor_id)

					tempNom               = suplidor.nombre_completo
					longitud              = tempNom.length

					objSuplidor[:nombre]  = ((longitud > max_lengt) && max_lengt != 0) ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom if retornar.my_includes_str('nombre')

					documento             = suplidor.documentos_de_identidad.find { | doc |  doc.principal == true } if retornar.my_includes_str('rnc')
					objSuplidor[:rnc]     = documento.nil? ? '----------' : documento.documento if retornar.my_includes_str('rnc')
				end

        return objSuplidor.with_indifferent_access
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.buscar_cliente(factura, max_lengt, retornar)
        objCliente   = {}
        if !factura['cliente_id'].nil?
            cliente  = factura.cliente if (factura.instance_of? CabeceraFactura) || (factura.instance_of? RecibosIngreso)
            cliente  = Cliente.find_by_id(factura['cliente_id']) if (!factura.instance_of? CabeceraFactura) && (!factura.instance_of? RecibosIngreso)

            tempNom  = cliente.nombre_completo
            longitud = tempNom.length

            objCliente[:nombre] = longitud > max_lengt ? "#{tempNom[0, (max_lengt + 1)]}..." : tempNom if retornar.my_includes_str('nombre')

            documento = cliente.documentos_de_identidad.find { |doc| doc.principal == true } if retornar.my_includes_str('rnc')
            objCliente[:rnc] = documento.nil? ? '----------' : documento.documento   if retornar.my_includes_str('rnc')
        else
            if !factura['NoCliente_nombre'].nil?
                objCliente[:nombre] = factura['NoCliente_nombre']
                objCliente[:rnc] = '-------------'
            end
        end

        return objCliente.with_indifferent_access
    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_cuentas_cobrar(params)
        # tipo 1 = por cliente
        # tipo 2 = general detallado
        # tipo 3 = general agrupado
        #
        current_user                 = get_current_user
        result_has_permiso_pre_venta = current_user.verificateHasPermiso('pre_venta')

        tipo                         = params[:tipo]
        cliente_id                   = params[:cliente_id]
        desde                        = params[:desde]
        hasta                        = params[:hasta].nil? ? params[:desde] : params[:hasta]

        longitud                     = tipo == Report::CxC.por_cliente ? 60 : tipo == Report::CxC.detallado ? 58 : 78
        longitud                     = tipo == Report::CxC.por_cliente ? 49 : tipo == Report::CxC.detallado ? 44 : 58 if result_has_permiso_pre_venta.status_valid

        has_permiso_pre_venta = result_has_permiso_pre_venta.status_valid

        query = {}
        query['cabecera_facturas.tipo']              = ['venta']
        query['cabecera_facturas.tipo'].push('pre_venta')  if has_permiso_pre_venta
        query['cabecera_facturas.estado']            = true
        query['cabecera_facturas.cliente_id']        = cliente_id if tipo == Report::CxC.por_cliente
        query['cabecera_facturas.fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day if tipo == Report::CxC.detallado || tipo == Report::CxC.agrupado

        total_cuentas      = 0
        cuentas            = []
        inicio_select      = "CASE WHEN LENGTH(clientes.nombre || ' ' || clientes.apellido) > #{longitud}
                                  THEN CONCAT(SUBSTRING(clientes.nombre || ' ' || clientes.apellido, 1, #{longitud}), '...')
                                ELSE clientes.nombre || ' ' || clientes.apellido END AS cliente_nombre, "

        inicio_select     += "clientes.id #{tipo == Report::CxC.agrupado ? '' : ', cabecera_facturas.fecha_equivalente, cabecera_facturas.id, cabecera_facturas.numero_comprobante, cabecera_facturas.tipo, cabecera_facturas.numero_factura'}"
        if tipo == Report::CxC.por_cliente
          select_ = "#{inicio_select}, cabecera_facturas.condicion, cabecera_facturas.balance as total_pendiente"
        else
          select_ = "#{inicio_select}, #{tipo == Report::CxC.agrupado ? 'sum (' : ''} cabecera_facturas.balance#{tipo == Report::CxC.agrupado ? ')' : ''} as total_pendiente,
            #{tipo == Report::CxC.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 0  then cabecera_facturas.balance else 0 end  )  as cero_to_treinta,
            #{tipo == Report::CxC.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 1  then cabecera_facturas.balance else 0 end  )  as treinta_uno_to_sesenta,
            #{tipo == Report::CxC.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 2  then cabecera_facturas.balance else 0 end  )  as sesenta_uno_to_noventa,
            #{tipo == Report::CxC.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) >= 3 then cabecera_facturas.balance else 0 end  )  as noventa_uno_to_more"
        end

        group_by = tipo == Report::CxC.por_cliente ? '' : tipo == Report::CxC.detallado ? 'cabecera_facturas.id, clientes.id' : 'clientes.id'

        CabeceraFactura.joins('inner join clientes on cabecera_facturas.cliente_id = clientes.id')
                       .select(select_).where(query).where('cabecera_facturas.balance >= 1 AND cabecera_facturas.pagada = false').group(group_by)
                       .order("#{tipo == Report::CxC.agrupado ? '' : 'cabecera_facturas.fecha_equivalente ASC'}").each do |cf|

          cabeza                      = cf.attributes
          total_cuentas              += cabeza['total_pendiente']
          cabeza['tipo_documento']    = cabeza['tipo'] == 'venta' ? 'Factura' : 'Pre-venta'
          cabeza['numero_documento']  = cabeza['tipo'] == 'venta' ? cabeza['numero_comprobante']: ("%08d" % cabeza['numero_factura'].to_s) if tipo != Report::CxC.agrupado
          cabeza                      = sustituirMonto(cabeza ) if tipo == Report::CxC.detallado
          cuentas.push(cabeza)
        end

        cuentas = cuentas.sort_by! { |item| item['total_pendiente']}.reverse if tipo == Report::CxC.agrupado

        obj = { body: cuentas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_cuentas, devuelto: 0 }, sub_t: "Cliente: #{ buscar_cliente({ cliente_id: cliente_id }.with_indifferent_access , 125, ['nombre'])['nombre'] }"}
        return obj

    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_cuentas_pagar(params)

        tipo                         = params[:tipo]
        suplidor_id                  = params[:suplidor_id]
        desde                        = params[:desde]
        hasta                        = params[:hasta].nil? ? params[:desde] : params[:hasta]

        longitud                     = tipo == Report::CxP.por_suplidor ? 60 : tipo == Report::CxP.detallado ? 58 : 78
        query = {}
        query['cabecera_facturas.tipo']              = ['compra']
        query['cabecera_facturas.estado']            = true
        query['cabecera_facturas.can_pagar']         = true
        query['cabecera_facturas.suplidor_id']       = suplidor_id if tipo == Report::CxP.por_suplidor
        query['cabecera_facturas.fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day


        total_cuentas      = 0
        cuentas            = []
        inicio_select      = "CASE WHEN LENGTH(suplidores.nombre) > #{longitud}
                                THEN CONCAT(SUBSTRING(suplidores.nombre, 1, #{longitud}), '...')
                              ELSE suplidores.nombre END AS suplidor_nombre,"

        inicio_select     += "suplidores.id #{tipo == Report::CxP.agrupado ? '' : ', cabecera_facturas.fecha_equivalente, cabecera_facturas.id, cabecera_facturas.numero_comprobante, cabecera_facturas.tipo, cabecera_facturas.numero_factura'}"

        select_ = ''
        if tipo == Report::CxP.por_suplidor
          select_ = "#{inicio_select}, cabecera_facturas.condicion, cabecera_facturas.balance as total_pendiente"
        else
          select_ = "#{inicio_select}, #{tipo == Report::CxP.agrupado ? 'sum (' : ''} cabecera_facturas.balance#{tipo == Report::CxP.agrupado ? ')' : ''} as total_pendiente,
          #{tipo == Report::CxP.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 0  then cabecera_facturas.balance else 0 end  )  as cero_to_treinta,
          #{tipo == Report::CxP.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 1  then cabecera_facturas.balance else 0 end  )  as treinta_uno_to_sesenta,
          #{tipo == Report::CxP.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 2  then cabecera_facturas.balance else 0 end  )  as sesenta_uno_to_noventa,
          #{tipo == Report::CxP.agrupado ? 'sum' : ''}( case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) >= 3 then cabecera_facturas.balance else 0 end  )  as noventa_uno_to_more"
        end

        group_by = tipo == Report::CxP.por_suplidor ? '' : tipo == Report::CxP.detallado ? 'cabecera_facturas.id, suplidores.id' : 'suplidores.id'

        CabeceraFactura.joins('inner join suplidores on cabecera_facturas.suplidor_id = suplidores.id')
        .select(select_).where(query).where('cabecera_facturas.balance >= 1 AND cabecera_facturas.pagada = false').group(group_by)
        .order("#{tipo == Report::CxP.agrupado ? '' : 'cabecera_facturas.fecha_equivalente ASC'}").each do |cf|
            cabeza                      = cf.attributes

            total_cuentas              += cabeza['total_pendiente']
            cabeza['tipo_documento']    = 'Compra'
            cabeza['numero_documento']  = cabeza['numero_comprobante'] if tipo != Report::CxP.agrupado
            cabeza                      = sustituirMonto(cabeza) if tipo == Report::CxP.detallado
            cuentas.push(cabeza)
        end

        cuentas = cuentas.sort_by! { |item| item['total_pendiente']}.reverse if tipo == Report::CxP.agrupado

        obj = { body: cuentas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_cuentas, devuelto: 0 }, sub_t: "Suplidor: #{ buscar_suplidor(suplidor_id , 125, ['nombre'])['nombre'] }"}
        return obj

    end

    # ---------------------------------------------------------------------------------------------------------
    def self.sustituirMonto(detalle)
        arrayDias = [ 'cero_to_treinta', 'treinta_uno_to_sesenta', 'sesenta_uno_to_noventa', 'noventa_uno_to_more' ]
        arrayDias.each do |item|
            detalle[item] = detalle[item] >= 1 ? detalle['numero_documento'] : 0
        end
        return detalle
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.getCantidades(articulos)
        array                         = []
        plural                        = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos', Galon: 'Galones', Funda: 'Fundas', Producto: 'Productos' }
        articulos.each do |articulo|
            obj                       = articulo.attributes
            obj['cantidades']         = articulo.calcularCantidades

            cant                      = number_with_delimiter( ('%.2f' % obj['cantidades'][articulo['medida']]).gsub(',','.'))

            obj['cantidad_principal'] = "#{cant} #{cant.to_i == 1 ? articulo['medida'] : plural[articulo['medida'].to_sym]}"
            array.push(obj)
        end
        return array
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.get_inventario(params)

        inventario_temp    = []
        inventario_temp    = Articulo.all.where({estado: true}).order('nombre ASC').includes(Articulo.models_includes)
        inventario_temp    = getCantidades(inventario_temp)
        cantidad_articulos = inventario_temp.length
        inventario         = inventario_temp.sort_by! { |item| item['nombre']}

        obj = { body: inventario, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0 }, sub_t: "Cantidad de productos en inventario: #{ cantidad_articulos }"}
        return obj
    end

    # ---------------------------------------------------------------------------------------------------------
    def self.get_notas(params)
      notas       = []
      query       = {}
      desde       = params[:desde]
      hasta       = params[:hasta].nil? ? params[:desde] : params[:hasta]
      tipo_nota   = params[:tipo_factura_id].to_i

      query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
      query['tipo_factura_id']   = tipo_nota unless tipo_nota == 0
      query['tipo_factura_id']   = tipo_nota unless tipo_nota == 0
      query['estado']      = true

      temp = FacturaAplicada
      .joins('inner join notas on notas.id = facturas_aplicadas.nota_id')
      .joins('inner join cabecera_facturas on cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id')
      .where(notas: query)
      .order('id DESC').includes(FacturaAplicada.models_includes)

      temp.each do | factura_aplicada |
        tipo_nota = factura_aplicada.tipo_nota == TiposNotas.credito  ? 'Crédito' : 'Débito'

        notas.push({
          :factura => factura_aplicada.cabecera_factura.numero_comprobante,
          :numero_comprobante => factura_aplicada.nota.numero_comprobante,
          :tipo_nota => "nota de #{tipo_nota.downcase}",
          :fecha => factura_aplicada.nota.fecha_equivalente,
          :monto => factura_aplicada.total.abs,
        })

      end

      subT = "Notas entre las fechas: #{formatearFecha(params[:desde], TipoFecha.sin_hora)} y #{formatearFecha(params[:hasta], TipoFecha.sin_hora)}"
      obj  = { body: notas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0 }, sub_t: subT}
    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_recibos(params)
        temp         = []
        recibos      = []
        desde        = params[:desde]
        hasta        = params[:hasta].nil? ? params[:desde] : params[:hasta]
        order        = params[:order]
        tipo         = params[:tipo]

        query        = {}
        query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

        temp = RecibosIngreso.where(query).order("id #{order}").includes(RecibosIngreso.models_includes)

        total_recibido = 0
        temp.each do |recibo|
          att = recibo.attributes
          total_recibido += recibo['total']

          client                 = buscar_cliente(recibo, 55, ['nombre'])
          att['cliente_nombre']  = client[:nombre]
          recibos.push(att.with_indifferent_access)
        end

        recibos = sum_by_day_recibos(recibos) if tipo == 'agrupado'

        obj = { body: recibos, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_recibido, devuelto: 0 }, sub_t: ''}

        return obj
      end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_pagos(params)
        temp         = []
        pagos        = []
        desde        = params[:desde]
        hasta        = params[:hasta].nil? ? params[:desde] : params[:hasta]
        order        = params[:order]
        tipo         = params[:tipo]

        query        = {}
        query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

        temp = PagoFactura.where(query).order("id #{order}").includes(PagoFactura.models_includes)

        total_pagado = 0
        temp.each do |pago|
          att = pago.attributes
          total_pagado += pago['total']

          suplidor                = buscar_suplidor(pago.suplidor_id, 55, ['nombre'])
          att['suplidor_nombre']  = suplidor[:nombre]
          pagos.push(att.with_indifferent_access)
        end

        pagos = sum_by_day_recibos(pagos) if tipo == Report::PagoFactura.agrupado

        obj = { body: pagos, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_pagado, devuelto: 0 }, sub_t: ''}

        return obj
      end

      # ---------------------------------------------------------------------------------------------------------

      def self.sum_by_day_recibos(records)
      pagos_agrupadas = records.group_by { |record| record[:fecha_equivalente].to_date }.map do |date, group|
        {
          fecha: formatearFecha(date.to_s, TipoFecha.sin_hora),
          total_general: group.reduce(0) { | acu, item |  item[:total] + acu }
        }
      end

      return pagos_agrupadas
    end
    # ---------------------------------------------------------------------------------------------------------

    def self.get_suplidores_por_producto(params)
        articulo_id                      = params[:articulo_id]
        desde                            = params[:desde]
        hasta                            = params[:hasta]

        temp                             = []
        contenido                        = []
        query                            = {}
        query_join                       = {}
        query['articulo_id']             = articulo_id
        query_join['fecha_equivalente']  = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        query_join['tipo']               = 'compra'


        temp = DetalleFactura.where(query).select('detalle_facturas.* ,cabecera_facturas.suplidor_id, cabecera_facturas.fecha_equivalente').joins(:cabecera_factura).where(cabecera_facturas: query_join).order('detalle_facturas.id ASC').includes([{ cabecera_factura: [{suplidor: [:documentos_de_identidad]}] } ])

        temp.each do |detalle|
          att                          = detalle.attributes
          suplidor                     = buscar_suplidor(detalle.cabecera_factura.suplidor_id, 0, ['nombre'])['nombre']
          att['suplidor_nombre']       = suplidor[:nombre]

          contenido.push(att)
        end

        articulo = Articulo.find_by_id(articulo_id)
        subT = "Producto: #{articulo.nombre}"

        obj = { body: contenido, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0 }, sub_t: subT}

    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_movimientos_vehiculo(params)
      viajes_por_vehiculo         = []
      total_fletes                = 0

      query                       = {}
      query['estado']             = true
      query['fecha_equivalente']  = (Date.parse params[:desde]).beginning_of_day..(Date.parse params[:hasta]).end_of_day
      query['tipo']               = 'venta'
      query['is_viaje']           = true
      query['is_nota']            = false


      all_viajes               = CabeceraFactura.where(query).order('cabecera_facturas.fecha_equivalente DESC').includes([{ movimientos_viaje: [:vehiculo, :user] }, { detalle_facturas: [:articulo] }])
      all_viajes_por_vehiculo  = all_viajes.select { | viaje | viaje.movimientos_viaje.to_a.my_includes_obj('vehiculo_id', params[:vehiculo_id].to_i) }

      vehiculo                 = Vehiculo.find_by_id(params[:vehiculo_id].to_i)


      all_viajes_por_vehiculo.each do | viaje |

        chofer = viaje.movimientos_viaje.length == 0 ? 'No tiene chofer registrado' : viaje.movimientos_viaje.length == 1 ? viaje.movimientos_viaje.first.user.nombre_completo : 'Varios...'
        flete  = viaje.detalle_facturas.select { | detalle | (detalle.articulo.nombre.downcase.include? 'transporte') || (detalle.articulo.nombre.downcase.include? 'flete') }

        obj_movimiento = {
          chofer:             chofer,
          flete:              flete.length > 0 ? flete.first.total : 0,
          fecha_equivalente:  viaje['fecha_equivalente'],
          fecha_viaje:        viaje['fecha_viaje'],
          numero_comprobante: viaje['numero_comprobante'],
        }

        viajes_por_vehiculo.push(obj_movimiento)
        total_fletes += obj_movimiento[:flete]
      end


      sub_titulo = "Viajes realizados en el camión: << #{vehiculo.info_vehiculo} >> entre las fechas: #{formatearFecha(params[:desde], TipoFecha.sin_hora)} y #{formatearFecha(params[:hasta], TipoFecha.sin_hora)}"

      obj = { body: viajes_por_vehiculo, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_fletes, devuelto: 0 } , sub_t: sub_titulo}

      return obj
    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_cuentas_con_pagos(params)
        longitud      = 100

        query                       = {}
        query['estado']             = true
        query['fecha_equivalente']  = (Date.parse params[:desde]).beginning_of_day..(Date.parse params[:hasta]).end_of_day
        query['tipo']               = 'venta'
        query['condicion']          = 'Crédito'
        query['is_nota']            = false
        query['cliente_id']         = params[:cliente_id]

        total_cuentas = 0
        facturas      = []
        cliente = nil

        CabeceraFactura.where(query).order('cabecera_facturas.fecha_equivalente ASC').includes([{detalle_recibos: [:recibos_ingreso]}, {facturas_aplicadas: [:nota]}, :cliente]).each do | cabeza_factura |
          pagos_notas  = []

          total_cuentas += cabeza_factura.total_factura

          cabeza_factura.detalle_recibos.each do | detalle_recibo |
            recibo = detalle_recibo.recibos_ingreso

            pagos_notas.push({
              numero_documento: '%08d' % recibo.numero_recibo,
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
              tipo:             "Nota #{fectura_aplicada.tipo_nota == TiposNotas.credito  ? 'Crédito' : 'Débito'}",
              fecha:            nota.fecha_equivalente,
              total:            fectura_aplicada.total
            })
          end

          contenido_titulo = []
          contenido_titulo.push({
            fecha_equivalente:  cabeza_factura['fecha_equivalente'],
            numero_comprobante: cabeza_factura['numero_comprobante'],
            total_factura:      cabeza_factura['total_factura'],
            balance:            cabeza_factura['balance'],
          })

          facturas.push({
            contenido_titulo:   contenido_titulo,
            contenido_grupo:    pagos_notas.sort_by! { |item| item[:fecha].to_i }
          })

          cliente = cabeza_factura.cliente
        end


        cliente = Cliente.find_by_id(params[:cliente_id]) if cliente == nil

        subtitulo = "Cliente: #{ cliente.nombre_completo }, Facturas entre las fechas: #{formatearFecha(params[:desde], TipoFecha.sin_hora)} y #{formatearFecha(params[:hasta], TipoFecha.sin_hora)}"
        obj = { body: facturas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_cuentas, devuelto: 0 }, sub_t: subtitulo}
        return obj
    end
    # ---------------------------------------------------------------------------------------------------------

    # ---------------------------------------------------------------------------------------------------------
    def self.get_ventas_por_producto(params)

        ventas      = []
        desde       = params[:desde]
        hasta       = params[:hasta].nil? ? params[:desde] : params[:hasta]

        sub_titulo  = desde == hasta ? "Fecha: #{formatearFecha(desde, TipoFecha.sin_hora)}" : "Entre las fechas: #{formatearFecha(desde, TipoFecha.sin_hora)} y #{formatearFecha(hasta, TipoFecha.sin_hora)}"
        total_venta = 0
        query       = {}

        tipoFacturaNotaCredito = TipoFactura.find_by_descripcion(TiposFacturasDescripcion.nota_de_credito)


        query['cabecera_facturas.fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        query['cabecera_facturas.tipo']              = 'venta'
        query['cabecera_facturas.is_nota']           = false

        TipoArticulo.all.each do | tipo_articulo |

          total_grupo = 0
          temp_ventas = []
          query['articulos.tipo_articulo_id'] = tipo_articulo.id


          select_ = 'detalle_facturas.articulo_id,
                    coalesce( SUM ( detalle_facturas.descuento_valor ), 0) as descuento_valor,
                    coalesce( SUM ( detalle_facturas.total ), 0) as total,
                    coalesce( SUM ( detalle_facturas.cantidad_en_unidades ), 0) as cantidad_en_unidades,
                    coalesce( SUM ( detalle_facturas.itbis ), 0) as itbis'

          joins_ = 'INNER JOIN cabecera_facturas ON cabecera_facturas.id = detalle_facturas.cabecera_factura_id
                    INNER JOIN articulos ON articulos.id = detalle_facturas.articulo_id'

          acu = 0
          DetalleFactura.select(select_).joins(joins_).where(query).order('articulo_id ASC').group('detalle_facturas.articulo_id')
          .includes([{articulo: [:contenido_articulos, :tipo_articulo]} ]).each do | df |
            acu += 1
            query_nota       = {}
            query_nota['detalles_facturas_notas.articulo_id']      = df.articulo_id
            query_nota['detalles_facturas_notas.tipo_factura_id']  = tipoFacturaNotaCredito.id
            query_nota['notas.fecha_equivalente']                  = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

            select_notas = 'coalesce( SUM (detalles_facturas_notas.cantidad_en_unidades), 0) as cantidad_devuelto, coalesce( SUM (detalles_facturas_notas.total), 0) as total_devuelto'

            joins_notas  = 'INNER JOIN facturas_aplicadas ON facturas_aplicadas.id = detalles_facturas_notas.factura_aplicada_id
                            INNER JOIN notas ON notas.id = facturas_aplicadas.nota_id'

            notas = DetalleFacturaNota.select(select_notas).joins(joins_notas).where(query_nota)
            notas = notas[0]

            detalle                          = df.attributes

            detalle['cantidad_devuelto']     = notas['cantidad_devuelto']
            detalle['total_devuelto']        = notas['total_devuelto']
            detalle['nombre']                = df.articulo.nombre
            detalle['total_vendido']         = df.total
            detalle['total_descuento']       = df.descuento_valor
            detalle['total_general']         = detalle['total_vendido'] - detalle['total_devuelto']
            detalle['contenido']             = df.articulo.calcularContenidos(false)

            mostrar = calcular_cantidad_proporcional(detalle)
            detalle['vendido_mostrar']       = mostrar['vendido_mostrar']
            detalle['devuelto_mostrar']      = mostrar['devuelto_mostrar']

            total_grupo += detalle['total_general']

            temp_ventas.push detalle
          end

          total_venta += total_grupo

          ventas.push({
            contenido_titulo:  tipo_articulo.descripcion,
            total:             total_grupo,
            contenido_grupo:   temp_ventas.sort_by! { |item| item['nombre']}
          })

        end

        ventas.push({
          contenido_titulo:  'TOTAL GENERAL',
          total:           total_venta,
          contenido_grupo: nil
        })

        obj = { body: ventas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_venta, devuelto: 0 }, sub_t: sub_titulo }

    end

    # ---------------------------------------------------------------------------------------------------------
    def self.calcular_cantidad_proporcional(detalle)

      total_venta=0
      plural = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos', Funda: 'Fundas' }

      vendido_mostrar  = '0.00'
      devuelto_mostrar = '0.00'

      if detalle['cantidad_en_unidades'] >= 1
        seleccionados          = detalle['contenido'].values.select { | contenido_cant | contenido_cant <= detalle['cantidad_en_unidades'] }
        contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.reverse.first)
      else
        seleccionados          = detalle['contenido'].values
        contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.first)
      end
      contenido_seleccionado_valor = detalle['contenido'][contenido_seleccionado]

      cant_vendido = detalle['cantidad_en_unidades'] / contenido_seleccionado_valor.to_f
      vendido_mostrar = "#{roundNumberToDecimal(cant_vendido)} #{cant_vendido == 1 ? contenido_seleccionado : plural[contenido_seleccionado.to_sym]}"

      if detalle['cantidad_devuelto'] >= 1
        seleccionados          = detalle['contenido'].values.select { | contenido_cant | contenido_cant <= detalle['cantidad_devuelto'] }
        contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.reverse.first)
      else
        seleccionados          = detalle['contenido'].values
        contenido_seleccionado = detalle['contenido'].key(seleccionados.sort.first)
      end
      contenido_seleccionado_valor = detalle['contenido'][contenido_seleccionado]

      cant_devuelto = detalle['cantidad_devuelto'] / contenido_seleccionado_valor.to_f
      devuelto_mostrar = "#{roundNumberToDecimal(cant_devuelto)} #{cant_devuelto == 1 ? contenido_seleccionado : plural[contenido_seleccionado.to_sym]}"
      # TODO: revisar esto

      # detalle['contenido'].each do |key, value|
      #   if detalle['cantidad_devuelto'] >= value
      #     cant = detalle['cantidad_devuelto'] / value.to_f
      #     devuelto_mostrar = "#{("%.2f" % cant).gsub(',','.')} #{cant == 1 ? key : plural[key.to_sym]}"
      #     break
      #   end
      # end

      return { vendido_mostrar: vendido_mostrar, devuelto_mostrar: devuelto_mostrar }.with_indifferent_access
    end

    # ---------------------------------------------------------------------------------------------------------

    def self.get_ventas(params)

        tipo_reporte      = params[:tipo_reporte]
        tipo              = params[:tipo]
        tipo_factura_id   = params[:tipo_factura_id]
        condicion         = params[:condicion]
        desde             = params[:desde]
        hasta             = params[:hasta]
        formas_pago       = params[:formas_pago]
        cliente_id        = params[:cliente_id]
        sub_titulo        = ''

        ventas_temp       = []
        where_formas      = "forma_pago IN #{formas_pago}"
        query             = {}

        is_viaje_credito = "( lower(condicion) = 'crédito' )"
        is_viaje_contado = tipo_reporte == TipoReporteVentas.ventas_hoy ? "( lower(condicion) = 'contado' AND is_viaje = false )" : "( lower(condicion) = 'contado')"

        query_is_viaje   = condicion.downcase == 'todos' ?  "#{is_viaje_contado} OR #{is_viaje_credito}" : condicion.downcase == 'contado' ? is_viaje_contado : is_viaje_credito

        query['fecha_equivalente']    = tipo_reporte == TipoReporteVentas.ventas_hoy ?  DateTime.now.beginning_of_day..DateTime.now.end_of_day : (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        query['cliente_id']           = cliente_id         if tipo_reporte == TipoReporteVentas.ventas_cliente
        query['tipo_factura_id']      = tipo_factura_id    if params.has_key?(:tipo_factura_id) && tipo_factura_id != "0"
        query['tipo']                 = 'venta'
        query['is_nota']              = false

        select_ = "cabecera_facturas.id, coalesce(clientes.nombre || ' ' || clientes.apellido,'Cliente contado') as cliente_nombre,
        cabecera_facturas.tipo_factura_id as tipo_factura_id, cabecera_facturas.fecha_equivalente,
        cabecera_facturas.numero_comprobante, cabecera_facturas.condicion,
        cabecera_facturas.total_factura, cabecera_facturas.itbis, cabecera_facturas.descuento,
        coalesce( SUM (CASE WHEN notas.tipo_factura_id = #{TiposNotasId.credito} THEN facturas_aplicadas.total ELSE 0 END), 0) as total_devuelto"

        select_ += ', "cabecera_facturas"."Bruto"'

        joins_  =  'LEFT JOIN clientes ON cabecera_facturas.cliente_id = clientes.id
                    LEFT JOIN facturas_aplicadas ON cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id
                    LEFT JOIN notas ON notas.id = facturas_aplicadas.nota_id'

        group_by = 'cabecera_facturas.id, clientes.nombre, clientes.apellido'

        total_devuelto  = 0
        bruto           = 0
        itbis           = 0
        descuento       = 0

        ventas = CabeceraFactura
        .select(select_).joins(joins_).where(query).where(where_formas).where(query_is_viaje).group(group_by)
        .order('cabecera_facturas.fecha_equivalente ASC').each do |cf|
          total_devuelto    += cf[:total_devuelto]
          bruto             += cf[:Bruto] || 0
          itbis             += cf[:itbis] || 0
          descuento         += cf[:descuento] || 0
        end

        total_ventas = ((bruto + itbis) - descuento) - total_devuelto

        sub_titulo   = "Cliente: #{ buscar_cliente({cliente_id: params[:cliente_id]}.with_indifferent_access , 125, ['nombre'])['nombre'] }" if tipo_reporte == TipoReporteVentas.ventas_cliente

        ventas       = sum_by_day_ventas(ventas) if tipo == 'agrupado'

        obj = { body: ventas, totalizacion: { bruto: bruto, descuento: descuento, itbis: itbis, total: total_ventas, devuelto: total_devuelto } , sub_t: sub_titulo}

        return obj
    end


    def self.sum_by_day_ventas(records)
      ventas_agrupadas = records.group_by { |record| record.fecha_equivalente.to_date }.map do |date, group|
        ventas_contado = group.select { | factura | factura.condicion.downcase == 'contado'}
        ventas_credito = group.select { | factura | factura.condicion.downcase == 'crédito'}

        {
          fecha: formatearFecha(date.to_s, TipoFecha.sin_hora),
          ventas_contado:     ventas_contado.sum(&:total_factura),
          ventas_credito:     ventas_credito.sum(&:total_factura),
          descuento_general:  group.sum(&:descuento),
          itbis_general:      group.sum(&:itbis),
          bruto_general:      group.sum(&:Bruto),
          devuelto_general:   group.sum(&:total_devuelto),
          total_general:      group.sum(&:total_factura) - group.sum(&:total_devuelto)
        }
      end

      return ventas_agrupadas
    end


    # ---------------------------------------------------------------------------------------------------------
end
