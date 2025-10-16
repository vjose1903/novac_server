class Reporte < ApplicationRecord
    extend ActionView::Helpers::NumberHelper
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
			itbis:                  (totalizacion[:itbis]     || 0).round(2),
			bruto:                  (totalizacion[:bruto]     || 0).round(2),
			descuento:              (totalizacion[:descuento] || 0).round(2),
			devuelto:               (totalizacion[:devuelto]  || 0).round(2),
			total:                  (totalizacion[:total]     || 0).round(2),
			facturado:              (totalizacion[:facturado] || 0).round(2),
			mora:                   (totalizacion[:mora]      || 0).round(2),
			pagado:                 (totalizacion[:pagado]    || 0).round(2),
			balance:                (totalizacion[:balance]   || 0).round(2),
			mostrar_sub_titulo:     sub_titulo[:bool],
			sub_titulo:             sub_titulo[:sub_t],
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
		if !factura[:cliente_id].nil?
			cli = factura.cliente if (factura.instance_of? CabeceraFactura) || (factura.instance_of? RecibosIngreso)
			cli = Cliente.find_by_id(factura[:cliente_id]) if (!factura.instance_of? CabeceraFactura) && (!factura.instance_of? RecibosIngreso)

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
        current_user          = get_current_user
        has_permiso_pre_venta = current_user.verificateHasPermiso('pre_venta').status_valid

        tipo            = params[:tipo]
        cliente_id      = params[:cliente_id]
        include_pagadas = params[:include_pagadas].nil? ? false : params[:include_pagadas].to_boolean
        include_mora    = params[:include_mora].nil? ? false : params[:include_mora].to_boolean
        desde           = params[:desde]
        hasta           = params[:hasta] || params[:desde]

        # Parsear fechas una sola vez
        fecha_desde = Date.parse(desde).beginning_of_day
        fecha_hasta = Date.parse(hasta).end_of_day

        # Definir longitud en un solo lugar usando operador ternario
        longitud = if has_permiso_pre_venta
			tipo == Report::CxC.por_cliente ? 49 : (tipo == Report::CxC.detallado ? 30 : 40)
        else
			tipo == Report::CxC.por_cliente ? 60 : (tipo == Report::CxC.detallado ? 38 : 47)
        end

        # Construir query de manera más eficiente
        query = {
			'cabecera_facturas.tipo' => has_permiso_pre_venta ? ['venta', 'pre_venta'] : ['venta'],
			'cabecera_facturas.estado' => true,
			'cabecera_facturas.fecha_equivalente' => fecha_desde..fecha_hasta
        }
        query['cabecera_facturas.cliente_id'] = cliente_id if tipo == Report::CxC.por_cliente

        # Construir select con interpolación de variables
        cliente_nombre = "CASE WHEN LENGTH(clientes.nombre || ' ' || clientes.apellido) > #{longitud}
                            THEN CONCAT(SUBSTRING(clientes.nombre || ' ' || clientes.apellido, 1, #{longitud}), '...')
                        ELSE clientes.nombre || ' ' || clientes.apellido END AS cliente_nombre"

        base_select = "#{cliente_nombre}, clientes.id"

        # Usar condicionales para construir la cláusula SELECT según el tipo
        select_ = if tipo == Report::CxC.agrupado
			"#{base_select}, sum(cabecera_facturas.total_factura) as total_factura, " +
			"sum(cabecera_facturas.balance) as total_pendiente, " +
			"sum(case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 0 then cabecera_facturas.balance else 0 end) as cero_to_treinta, " +
			"sum(case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 1 then cabecera_facturas.balance else 0 end) as treinta_uno_to_sesenta, " +
			"sum(case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 2 then cabecera_facturas.balance else 0 end) as sesenta_uno_to_noventa, " +
			"sum(case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) >= 3 then cabecera_facturas.balance else 0 end) as noventa_uno_to_more"

        elsif tipo == Report::CxC.por_cliente
			"#{base_select}, cabecera_facturas.fecha_equivalente, cabecera_facturas.id, " +
			"cabecera_facturas.numero_comprobante, cabecera_facturas.tipo, cabecera_facturas.numero_factura, " +
			"cabecera_facturas.total_factura, cabecera_facturas.fecha_vencimiento, cabecera_facturas.condicion, " +
			"cabecera_facturas.balance as total_pendiente"

        else # Report::CxC.detallado
			"#{base_select}, cabecera_facturas.fecha_equivalente, cabecera_facturas.id, " +
			"cabecera_facturas.numero_comprobante, cabecera_facturas.tipo, cabecera_facturas.numero_factura, " +
			"cabecera_facturas.total_factura, cabecera_facturas.balance as total_pendiente, " +
			"case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 0 then cabecera_facturas.balance else 0 end as cero_to_treinta, " +
			"case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 1 then cabecera_facturas.balance else 0 end as treinta_uno_to_sesenta, " +
			"case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) = 2 then cabecera_facturas.balance else 0 end as sesenta_uno_to_noventa, " +
			"case when trunc(((current_date - cabecera_facturas.fecha_equivalente::date))/30) >= 3 then cabecera_facturas.balance else 0 end as noventa_uno_to_more"
        end

        # Construir joins
        joins_ = "INNER JOIN clientes ON cabecera_facturas.cliente_id = clientes.id"

        if include_mora
			# Primero creamos una subconsulta que agrupe los pagos por factura
			joins_ += <<-SQL
            LEFT JOIN (
			SELECT
                dr.cabecera_factura_id,
                jsonb_agg(
					jsonb_build_object(
						'id', ri.id,
						'fecha_equivalente', ri.fecha_equivalente,
						'deposito', dr.deposito,
						'mora', dr.mora
					)
                ) as pagos_array
					FROM detalle_recibos dr
					INNER JOIN recibos_ingresos ri ON ri.id = dr.recibos_ingreso_id
					GROUP BY dr.cabecera_factura_id
            	) AS pagos_agrupados ON pagos_agrupados.cabecera_factura_id = cabecera_facturas.id
			SQL

			# Modificar select para incluir los pagos ya agrupados
			select_ += ", pagos_agrupados.pagos_array as pagos"
        end

        # Definir group_by según el tipo
        group_by = case tipo
			when Report::CxC.agrupado then 'clientes.id, clientes.nombre, clientes.apellido'
			when Report::CxC.detallado then 'cabecera_facturas.id, clientes.id, clientes.nombre, clientes.apellido'
			when Report::CxC.por_cliente then 
				if include_mora 
					'cabecera_facturas.id, clientes.id, clientes.nombre, clientes.apellido, pagos_agrupados.pagos_array'
				else 
					'cabecera_facturas.id, clientes.id, clientes.nombre, clientes.apellido'
				end

			else ''
        end

        # Condición para facturas pagadas
        facturas_pagadas_where = include_pagadas ? '' : 'cabecera_facturas.balance >= 1 AND cabecera_facturas.pagada = false'

        # Ordenamiento
        order_by = tipo == Report::CxC.agrupado ? '' : 'cabecera_facturas.fecha_equivalente ASC'

        # Consulta principal - usar un scope para limitar la cantidad de registros cargados en memoria
        facturas = CabeceraFactura.joins(joins_)
								.select(select_)
								.where(query)
								.where(facturas_pagadas_where)
								.group(group_by)
								.order(order_by)

        # Procesar resultados una sola vez
        total_facturado = 0
        total_pendiente = 0

        cuentas = facturas.map do |cf|
			cabeza = cf.attributes
			total_facturado += cabeza['total_factura'].to_f
			total_pendiente += cabeza['total_pendiente'].to_f

			# Asignar valores en el mismo mapeo
			cabeza['tipo_documento']    = cabeza['tipo'] == 'venta' ? 'Factura' : 'Pre-venta'
			cabeza['numero_documento']  = cabeza['tipo'] == 'venta' ? cabeza['numero_comprobante']: ("%08d" % cabeza['numero_factura'].to_s) if tipo != Report::CxC.agrupado
			cabeza                      = sustituirMonto(cabeza) if tipo == Report::CxC.detallado

			# Los pagos ya vienen agrupados desde la consulta SQL
			cabeza['pagos'] = (cabeza['pagos'] || []).reject(&:nil?)

			cabeza
        end

        # Ordenar si es necesario (sólo para agrupado)
        cuentas.sort_by! { |item| -item['total_pendiente'].to_f } if tipo == Report::CxC.agrupado

        # Construir subtítulo
        sub_titulo = tipo == Report::CxC.por_cliente ? "Cliente: #{ buscar_cliente({ cliente_id: cliente_id }.with_indifferent_access , 125, ['nombre'])['nombre'] }, " : ''
        sub_titulo += "Desde: #{formatearFecha(params["desde"], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params["hasta"], TipoFecha.sin_hora)}"

        # Retornar resultado
        { body: cuentas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_pendiente, devuelto: 0, facturado: total_facturado }, sub_t: sub_titulo }
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
	def self.calcularCantidades(articulos)
		array                         =[]
		plural                        = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos', Galon: 'Galones', Funda: 'Fundas', Bolsa: 'Bolsas', Producto: 'Productos' }
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
		inventario         = inventario_temp.sort_by! { |item| item["nombre"]}

		obj = { body: inventario, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0, facturado: 0 }, sub_t: "Cantidad de productos en inventario: #{ cantidad_articulos }"}
		return obj
	end

	# ---------------------------------------------------------------------------------------------------------
	def self.get_notas(params)
        notas       = []
        query       = {}
        desde       = params["desde"]
        hasta       = params["hasta"].nil? ? params["desde"] : params["hasta"]
        tipo_nota   = params["tipo_factura_id"].to_i

        query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
        query['tipo_factura_id']   = tipo_nota unless tipo_nota == 0
        query['estado']            = true

        temp = FacturaAplicada
        .joins("inner join notas on notas.id = facturas_aplicadas.nota_id")
        .joins("inner join cabecera_facturas on cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id")
        .where(notas: query)
        .order("id DESC").includes(FacturaAplicada.models_includes)

        temp.each do | factura_aplicada |
			notas.push({
				:factura => factura_aplicada.cabecera_factura.numero_comprobante,
				:numero_comprobante => factura_aplicada.nota.numero_comprobante,
				:tipo_nota => factura_aplicada.tipo_nota,
				:fecha => factura_aplicada.nota.fecha_equivalente,
				:monto => factura_aplicada.total.abs,
			})
        end

        sub_titulo = "Desde: #{formatearFecha(params["desde"], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params["hasta"], TipoFecha.sin_hora)}"
        obj  = { body: notas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0, facturado: 0 }, sub_t: sub_titulo}
	end

	# ---------------------------------------------------------------------------------------------------------

	def self.get_recibos(params)
		temp         = []
		recibos      = []
		desde        = params[:desde]
		hasta        = params[:hasta].nil? ? params[:desde] : params[:hasta]
		order        = params[:order]
		tipo         = params[:tipo]
		buscar_por   = params[:search_by].present? ? params[:search_by].to_i : Report::ReciboBuscarPor.general
		cliente_id   = params[:cliente_id]

		query                      = {}
		query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
		query['estado']            = true
		query['cliente_id']        = cliente_id if buscar_por == Report::ReciboBuscarPor.por_cliente

		temp = RecibosIngreso.where(query).order("id #{order}").includes(RecibosIngreso.models_includes)

		total_recibido = 0
		total_mora = 0
		total_bruto = 0

		temp.each do |recibo|
            att = recibo.attributes
            total_bruto    += recibo['bruto']
            total_mora     += recibo['mora']
            total_recibido += recibo['total']

            client                 = buscar_cliente(recibo, 55, ['nombre'])
            att['cliente_nombre']  = client['nombre']
            recibos.push(att.with_indifferent_access)
		end

		recibos = sum_by_day_recibos(recibos)      if tipo == Report::ReciboIngreso.agrupado
		cliente = Cliente.find_by_id(cliente_id)   if buscar_por == Report::ReciboBuscarPor.por_cliente

		sub_titulo = "Desde: #{formatearFecha(params["desde"], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params["hasta"], TipoFecha.sin_hora)}"
		sub_titulo = "Cliente: #{cliente.nombre_completo}, " + sub_titulo if buscar_por == Report::ReciboBuscarPor.por_cliente

		obj = { body: recibos, totalizacion: { bruto: total_bruto, mora: total_mora, total: total_recibido, devuelto: 0, facturado: 0 }, sub_t: sub_titulo}

		return obj
	end

	# ---------------------------------------------------------------------------------------------------------

	def self.sum_by_day_recibos(records)
        recibos_agrupadas = records.group_by { |record| record[:fecha_equivalente].to_date }.map do |date, group|
			{
				fecha: formatearFecha(date.to_s, TipoFecha.sin_hora),
				total_bruto:   group.reduce(0) { | acu, item |  item[:bruto] + acu },
				total_mora:    group.reduce(0) { | acu, item |  item[:mora] + acu },
				total_general: group.reduce(0) { | acu, item |  item[:total] + acu }
			}
        end

        return recibos_agrupadas
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
		sub_titulo = "Producto: #{articulo.nombre}"

		obj = { body: contenido, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: 0, devuelto: 0, facturado: 0 }, sub_t: sub_titulo}

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


        sub_titulo = "Viajes realizados en el camión: << #{vehiculo.info_vehiculo} >> entre las fechas: #{formatearFecha(params["desde"], TipoFecha.sin_hora)} y #{formatearFecha(params["hasta"], TipoFecha.sin_hora)}"

        obj = { body: viajes_por_vehiculo, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_fletes, devuelto: 0, facturado: 0 } , sub_t: sub_titulo}

        return obj
	end

	# ---------------------------------------------------------------------------------------------------------

	def self.get_cuentas_con_pagos(params)
		longitud      = 100

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
					numero_documento: "%08d" % recibo.numero_recibo,
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
					tipo:             fectura_aplicada.tipo_factura.descripcion,
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
                contenido_grupo:    pagos_notas.sort_by! { |item| item[:fecha].to_i }
            })

            cliente = cabeza_factura.cliente
		end


		cliente = Cliente.find_by_id(params['cliente_id']) if cliente == nil

		sub_titulo = "Cliente: #{ cliente.nombre_completo }, Desde: #{formatearFecha(params["desde"], TipoFecha.sin_hora)}, Hasta: #{formatearFecha(params["hasta"], TipoFecha.sin_hora)}"
		obj = { body: facturas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_cuentas, devuelto: 0, facturado: 0 }, sub_t: sub_titulo}
		return obj
	end
	# ---------------------------------------------------------------------------------------------------------

	# ---------------------------------------------------------------------------------------------------------
	def self.get_ventas_por_producto(params)

		ventas      = []
		desde       = params["desde"]
		hasta       = params["hasta"].nil? ? params["desde"] : params["hasta"]

		sub_titulo  = desde == hasta ? "Fecha: #{formatearFecha(desde, TipoFecha.sin_hora)}" : "Entre las fechas: #{formatearFecha(desde, TipoFecha.sin_hora)} y #{formatearFecha(hasta, TipoFecha.sin_hora)}"
		total_venta = 0
		query       = {}

		tipoFacturaNotaCredito = TipoFactura.find_by_descripcion(TiposFacturasDescripcion.nota_de_credito)


		query['cabecera_facturas.fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
		query['cabecera_facturas.tipo']              = 'venta'
		query['cabecera_facturas.is_nota']           = false
		query['cabecera_facturas.estado']            = true

		TipoArticulo.all.each do | tipo_articulo |

            total_grupo = 0
            temp_ventas = []
            query['articulos.tipo_articulo_id'] = tipo_articulo.id


            select_ = "detalle_facturas.articulo_id,
					coalesce( SUM ( detalle_facturas.descuento_valor ), 0) as descuento_valor,
					coalesce( SUM ( detalle_facturas.total ), 0) as total,
					coalesce( SUM ( detalle_facturas.cantidad_en_unidades ), 0) as cantidad_en_unidades,
					coalesce( SUM ( detalle_facturas.itbis ), 0) as itbis"

            joins_ = "INNER JOIN cabecera_facturas ON cabecera_facturas.id = detalle_facturas.cabecera_factura_id
					INNER JOIN articulos ON articulos.id = detalle_facturas.articulo_id"

            acu = 0
            DetalleFactura.select(select_).joins(joins_).where(query).order('articulo_id ASC').group("detalle_facturas.articulo_id")
            .includes([{articulo: [:contenido_articulos, :tipo_articulo]} ]).each do | df |
				acu += 1
				query_nota       = {}
				query_nota['detalles_facturas_notas.articulo_id']      = df.articulo_id
				query_nota['detalles_facturas_notas.tipo_factura_id']  = tipoFacturaNotaCredito.id
				query_nota['notas.fecha_equivalente']                  = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day

				select_notas = "coalesce( SUM (detalles_facturas_notas.cantidad_en_unidades), 0) as cantidad_devuelto, coalesce( SUM (detalles_facturas_notas.total), 0) as total_devuelto"

	        	joins_notas  = "INNER JOIN facturas_aplicadas ON facturas_aplicadas.id = detalles_facturas_notas.factura_aplicada_id
                        INNER JOIN notas ON notas.id = facturas_aplicadas.nota_id"

				notas = DetalleFacturaNota.select(select_notas).joins(joins_notas).where(query_nota)
	            notas = notas[0]

	            detalle                          = df.attributes


                detalle['cantidad_devuelto']     = notas['cantidad_devuelto']
                detalle['total_devuelto']        = notas['total_devuelto']
                detalle['nombre']                = df.articulo.nombre
                detalle['total_vendido']         = df.total
                detalle['total_descuento']       = df.descuento_valor
                detalle['total_general']         = detalle['total_vendido'] - detalle['total_devuelto']
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
				contenido_grupo:   temp_ventas.sort_by! { |item| item['nombre']}
            })

		end

		ventas.push({
            contenido_titulo:  'TOTAL GENERAL',
            total:           total_venta,
            contenido_grupo: nil
		})

		obj = { body: ventas, totalizacion: { bruto: 0, descuento: 0, itbis: 0, total: total_venta, devuelto: 0, facturado: 0 }, sub_t: sub_titulo }

	end

	# ---------------------------------------------------------------------------------------------------------
	def self.calcular_cantidad_proporcional(detalle)

        total_venta=0
        plural = { Quintal: 'Quintales', Libra: 'Libras', Caja: 'Cajas', Paquete: 'Paquetes', Unidad: 'Unidades', Saco: 'Sacos', Funda: 'Fundas', Bolsa: 'Bolsas' }

        vendido_mostrar  = "0.00"
        devuelto_mostrar = "0.00"

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

        return { "vendido_mostrar" => vendido_mostrar, "devuelto_mostrar" => devuelto_mostrar }
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
		serie             = params[:serie].present? ? params[:serie] : SerieFactura.all
		cliente_id        = params[:cliente_id]
		sub_titulo        = ""

		ventas_temp       = []
		where_formas      = "forma_pago IN #{formas_pago}"
		query             = {}

		is_viaje_credito = "( lower(condicion) = 'crédito' )"
		is_viaje_contado = tipo_reporte == TipoReporteVentas.ventas_hoy ? "( lower(condicion) = 'contado' AND is_viaje = false )" : "( lower(condicion) = 'contado')"

		query_is_viaje   = condicion.downcase == 'todos' ?  "#{is_viaje_contado} OR #{is_viaje_credito}" : condicion.downcase == 'contado' ? is_viaje_contado : is_viaje_credito

		query['fecha_equivalente']    = tipo_reporte == TipoReporteVentas.ventas_hoy ?  DateTime.now.beginning_of_day..DateTime.now.end_of_day : (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
		query['cliente_id']           = cliente_id         if tipo_reporte == TipoReporteVentas.ventas_cliente
		query['tipo_factura_id']      = tipo_factura_id    if params[:tipo_factura_id].present? && tipo_factura_id != "0"
		query['serie']                = serie              if serie != SerieFactura.all
		query['tipo']                 = 'venta'
		query['is_nota']              = false
		query['estado']               = true

		tipos_nota_credito = [TiposNotasId.credito, TiposNotasId.credito_electronica]

		select_ = "cabecera_facturas.id, coalesce(clientes.nombre || ' ' || clientes.apellido,'Cliente contado') as cliente_nombre,
		cabecera_facturas.tipo_factura_id as tipo_factura_id, cabecera_facturas.fecha_equivalente,
		cabecera_facturas.numero_comprobante, cabecera_facturas.condicion,
		cabecera_facturas.total_factura, cabecera_facturas.itbis, cabecera_facturas.descuento,
		coalesce( SUM (CASE WHEN notas.tipo_factura_id IN (#{tipos_nota_credito.join(',')}) THEN facturas_aplicadas.total ELSE 0 END), 0) as total_devuelto"

		select_ += ', "cabecera_facturas"."Bruto"'

		joins_ =  "LEFT JOIN clientes ON cabecera_facturas.cliente_id = clientes.id
                    LEFT JOIN facturas_aplicadas ON cabecera_facturas.id = facturas_aplicadas.cabecera_factura_id
                    LEFT JOIN notas ON notas.id = facturas_aplicadas.nota_id"

		group_by="cabecera_facturas.id, clientes.nombre, clientes.apellido"

		total_devuelto  = 0
		bruto           = 0
		itbis           = 0
		descuento       = 0

		ventas = CabeceraFactura
		.select(select_).joins(joins_).where(query).where(where_formas).where(query_is_viaje).group(group_by)
		.order("cabecera_facturas.id ASC").each do |cf|

			total_devuelto    += cf[:total_devuelto]
			bruto             += cf[:Bruto] || 0
			itbis             += cf[:itbis] || 0
			descuento         += cf[:descuento] || 0
		end

		total_ventas = ((bruto + itbis) - descuento) - total_devuelto  
		sub_titulo   = "Cliente: #{ buscar_cliente({cliente_id: params[:cliente_id]}.with_indifferent_access , 125, ['nombre'])["nombre"] }" if tipo_reporte == TipoReporteVentas.ventas_cliente

		ventas       = sum_by_day_ventas(ventas) if tipo == 'agrupado'

		obj = { body: ventas, totalizacion: { bruto: bruto, descuento: descuento, itbis: itbis, total: total_ventas, devuelto: total_devuelto, facturado: 0 } , sub_t: sub_titulo }  
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

	def self.get_balance_cliente_historico(params)
        cliente_id = params[:cliente_id]
        desde      = params[:desde]
        hasta      = params[:hasta] || params[:desde]

        # Convertir fechas para comparaciones
        fecha_hasta = (Date.parse hasta).end_of_day

        # Query para facturas a crédito del cliente
        query = {
            'cliente_id'         => cliente_id,
            'fecha_equivalente'  => (Date.parse desde).beginning_of_day..fecha_hasta,
            'tipo'               => 'venta',
            'condicion'          => 'Crédito',
            'estado'             => true,
            'is_nota'            => false
        }

        facturas_detalle = []
        total_facturado = 0
        total_pagado = 0
        total_balance = 0

        # Obtener facturas a crédito del cliente
        CabeceraFactura.where(query)
                        .order('fecha_equivalente ASC')
                        .includes([
                            :cliente,
                            { detalle_recibos: [:recibos_ingreso] },
                        	{ facturas_aplicadas: [:nota] }
                        ]).each do |factura|

            # Calcular total de pagos recibidos para esta factura (solo hasta la fecha límite)
	        pagos_recibos = factura.detalle_recibos
                                .joins(:recibos_ingreso)
                                .where('recibos_ingresos.fecha_equivalente <= ?', fecha_hasta)
                                .where(recibos_ingresos: { estado: true })
                                .sum(:deposito)

            # Calcular total de notas de crédito aplicadas (solo hasta la fecha límite)
            notas_credito = factura.facturas_aplicadas
                                .joins(:nota)
                                .where('notas.fecha_equivalente <= ?', fecha_hasta)
                                .where(notas: { estado: true })
                                .where(tipo_factura_id: [TiposNotasId.credito, TiposNotasId.credito_electronica])
                                .sum(:total)

			total_pagos_factura = pagos_recibos + notas_credito
			balance_factura = factura.total_factura - total_pagos_factura

			# Acumular totales
			total_facturado += factura.total_factura
			total_pagado += total_pagos_factura
			total_balance += balance_factura

        	facturas_detalle << {
				numero_documento: factura.numero_comprobante,
				fecha_equivalente: factura.fecha_equivalente,
				total_factura: factura.total_factura,
				total_pagado: total_pagos_factura,
				balance_pendiente: balance_factura,
            }
        end  
        # Obtener información del cliente
        cliente = Cliente.find_by_id(cliente_id)
        cliente_nombre = cliente ? cliente.nombre_completo : 'Cliente no encontrado'

        # Construir subtítulo
        sub_titulo = "Cliente: #{cliente_nombre}, "
        sub_titulo += desde == hasta ?
	        "Fecha: #{formatearFecha(desde, TipoFecha.sin_hora)}" :
    	    "Desde: #{formatearFecha(desde, TipoFecha.sin_hora)}, Hasta: #{formatearFecha(hasta, TipoFecha.sin_hora)}"

        # Retornar resultado siguiendo la estructura estándar
        {
        	body: facturas_detalle,
        	totalizacion: {
				balance: total_balance,
				facturado: total_facturado,
				pagado: total_pagado
			},
	        sub_t: sub_titulo
        }
	end

	# ---------------------------------------------------------------------------------------------------------
end