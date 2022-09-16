def pasar_notas
  notas                    = CabeceraFactura.where({tipo_factura_id: [TiposNotasId.credito, TiposNotasId.debito]})
  notas.each do |nota|

    factura_aplicada       = CabeceraFactura.find_by_numero_comprobante(nota.aplicada_a)
    detalles_notas         = nota.detalle_facturas
    new_nota               = Nota.new

    new_factura_aplicada   = FacturaAplicada.new

    new_nota.cliente_id                    = nota.cliente_id
    new_nota.user_id                       = nota.user_id
    new_nota.tipo_factura_id               = nota.tipo_factura_id
    new_nota.total                         = nota.total_factura
    new_nota.numero_documento              = nota.numero_factura
    new_nota.numero_comprobante            = nota.numero_comprobante
    new_nota.fecha_equivalente             = nota.fecha_equivalente
    new_nota.fecha_valida                  = nota.fecha_valida
    new_nota.estado                        = nota.estado
    new_nota.no_cliente_nombre             = nota.NoCliente_nombre
    new_nota.no_cliente_direccion          = nota.NoCliente_direccion

    new_nota.save!
    new_nota.identificador                 = Nota.makeIdentificador(new_nota, 1)
    new_nota.save!

    new_factura_aplicada.nota_id                     = new_nota.id
    new_factura_aplicada.cabecera_factura_id         = factura_aplicada.id
    new_factura_aplicada.total                       = nota.total_factura


    new_factura_aplicada.save!

    detalles_notas.each do | detalle |
      new_detalle_nota                           = DetalleFacturaNota.new

      new_detalle_nota.factura_aplicada_id       = new_factura_aplicada.id
      new_detalle_nota.articulo_id               = detalle.articulo_id
      new_detalle_nota.detalle_factura_id        = detalle.detalle_factura_nota
      new_detalle_nota.unidad                    = detalle.unidad
      new_detalle_nota.cantidad                  = detalle.cantidad
      new_detalle_nota.cantidad_en_unidades      = detalle.cantidad_en_unidades
      new_detalle_nota.itbis                     = detalle.itbis
      new_detalle_nota.costo                     = detalle.costo
      new_detalle_nota.precio                    = detalle.precio
      new_detalle_nota.total                     = detalle.total
      new_detalle_nota.descuento                 = 0


      new_detalle_nota.save!

    end
  end
    puts "::::::::::::: FIN :::::::::::::".red
  nil
end

def pasar_choferes
  recibos                    = RecibosIngreso.all

  recibos.each do |recibo|
    if !recibo.chofer.nil? && !recibo.id.nil?
      chofer_viaje = ChoferViaje.create({user_id: recibo.chofer, recibos_ingreso_id: recibo.id})
      puts " "
      puts "chofer_viaje ".green + " #{chofer_viaje.to_json}"
      puts "chofer_viaje ERROR: ".red + " #{chofer_viaje.errors.to_a}"
    end
  end
end

def formar_permisos
  permisos = Permiso.all
  permisos_parsed = {}

  permisos.each do | permisos |
    permisos_parsed[permisos.descripcion] = {}

    permisos.acciones.each do | accion |
      permisos_parsed[permisos.descripcion][accion.descripcion] = "#{permisos.descripcion}_#{accion.descripcion}"
    end

  end
	return permisos_parsed
end


def reponer_formulas

	res = Response.new
	# #  -------------------------------------------------------------------------------------
	# formulas = FormulasProductosTerminado.all

	# formulas.each do |formula|
	#   puts "formula.articulo".red + "#{formula.articulo.contenido_articulos.to_json} "
	# end

	obj = {}
	formulas_sin_repetir = []

	mantenimiento = MantenimientoFormula.select("mantenimiento_formulas.*, articulos.nombre").joins("inner join articulos on mantenimiento_formulas.articulo_id = articulos.id").order("mantenimiento_formulas.created_at desc")
	acu = 0
	mantenimiento.each do |artic|

		unless formulas_sin_repetir.any? { |item| item.articulo_id == artic.articulo_id && item.secuencia != artic.secuencia }

			obj["#{artic.articulo_id}"] = [] if obj["#{artic.articulo_id}"].blank?

			obj["#{artic.articulo_id}"].push(artic)

			formulas_sin_repetir.push(artic)

		end
	end

	obj.each { |key, value|
		puts "key:".red + " #{key}"
		puts "value:".green + " #{value}"

		formula_b = FormulasProductosTerminado.where({articulo_id: key}).count()
		puts "formula_b:".yellow + " #{formula_b}"
		"-------" * 10


		if formula_b == 0
			value.each do |f|
				nueva_formula = FormulasProductosTerminado.new
				nueva_formula.articulo_id        = f.articulo_id
				nueva_formula.cantidad           = f.cantidad
				nueva_formula.costo              = f.costo
				nueva_formula.articulo_combo     = f.articulo_combo
				nueva_formula.precio             = f.precio
				nueva_formula.medida             = "Libra"

				nueva_formula.save!
			end

		end

		acu +=1
		puts " "
	 }




	puts "cuenta ".yellow + "#{acu}"
	res.set_data('fin')
	return res

end


def agregar_formula_id_to_mantenimiento_formulas

	MantenimientoFormula.all.each do | mantenimiento |
		formula_equivalente          = FormulasProductosTerminado.where({ articulo_id: mantenimiento.articulo_id, articulo_combo: mantenimiento.articulo_combo }).first

		puts "(#{formula_equivalente})".yellow

		if formula_equivalente != nil
			puts "#{mantenimiento.to_json}".red
			puts "#{formula_equivalente.to_json}".green
			puts " "

			mantenimiento.formula_id   = formula_equivalente.id
			mantenimiento.medida       = formula_equivalente.medida

			mantenimiento.save!
		end
	end
	nil
end


def modificar_secuencia_mantenimiento
	MantenimientoArticulo.all.each do | mantenimiento |
		if mantenimiento.ant_isCombo
			query                = {}
			query['created_at']  = (mantenimiento.created_at - 1)..(mantenimiento.created_at + 1)
			query['articulo_id'] = mantenimiento.articulo_id
			formulas_equivalentes  = MantenimientoFormula.where(query)

			if(formulas_equivalentes.length > 0)
				secuencia                              = "#{Time.now.to_i}#{mantenimiento.articulo_id}"
				mantenimiento.secuencia = secuencia
				mantenimiento.save!
				formulas_equivalentes.update({secuencia: secuencia})
			end
		end
	end
	nil
end


def make_producto_terminado_calcular_saco
	articulos_arreglados = []
	Articulo.where("tipo_articulos.codigo = '#{TipoArticulos.producto_terminado}'").joins("inner join tipo_articulos on articulos.tipo_articulo_id = tipo_articulos.id").includes([:contenido_articulos, :formulas_productos_terminados]).each do | articulo |

		if articulo.calcular_saco == false
			articulo.calcular_saco = true
			articulo.save!
			articulos_arreglados.push(articulo.nombre)
		end
	end

	if articulos_arreglados.length == 0
		puts " "
		puts " ----- TODOS LOS PRODUCTOS TERMINADOS ESTAN BIEN ----- ".green
		puts " "
	else
		puts " "
		puts " ----- PRODUCTOS TERMINADOS ARREGLADOS ----- ".red
		puts " "
		puts "#{articulos_arreglados.to_a}"
	end

	return nil
end

def recalcular_cantidad_en_undidades

	query_principal = "cabecera_facturas.tipo = 'venta' AND articulo_id not in (102, 213)"
	DetalleFactura.where(query_principal).joins("inner join cabecera_facturas on detalle_facturas.cabecera_factura_id = cabecera_facturas.id").includes([ {articulo: [:contenido_articulos, :tipo_articulo]}, :cabecera_factura ]).each do | detalle |
		puts " " * 15
		puts " -=-=-=-=-=" * 15
		articulo           = detalle.articulo
		cabecera_factura   = detalle.cabecera_factura
		tipo_articulo      = articulo.tipo_articulo

		articulo_historico = find_articulo_mantenimiento(articulo, cabecera_factura.fecha_equivalente)
		unidad_en_turno    = detalle.unidad

		unidad_en_turno    = parse_unidad_saco(detalle.unidad, articulo_historico) if detalle.unidad.include? "Saco de"

		contenidos         = calcularContenidos(articulo_historico)
		contenido_en_turno = contenidos[unidad_en_turno]

		# puts " "
		# puts " "
		# puts " "
		# puts "-------------" * 3
		# puts "( #{acu} )  - #{detalle.articulo.nombre}"
		# puts "-------------" * 3
		# puts " "
		# puts " "

		if contenido_en_turno.nil?
			costos           = calcular_costos(articulo_historico, tipo_articulo.descripcion, contenidos.with_indifferent_access, detalle.cantidad)
			obj              = { "vendido_en": articulo.vendido_en, "calcular_saco": articulo.calcular_saco, "costos": costos }.with_indifferent_access
			medida_correct   = get_correct_medida(obj, detalle.total)

		end
	end

	return nil
end

def get_correct_medida(obj, total)
	medida_selected=nil
	obj["costos"].each { |key, value|
			if obj["vendido_en"] == "Saco" && obj["calcular_saco"] == true && key != "Quintal"
					medida_selected = key if total <= value["calculo"] + 100  && total >=  value["calculo"] - 100
			elsif obj["vendido_en"] != "Saco" || obj["calcular_saco"] == false
					medida_selected = key if total <= value["calculo"] + 100  && total >=  value["calculo"] - 100
			end
			break if medida_selected != nil
	}

	if medida_selected.include? "Saco_"
		medida_selected_split = medida_selected.split("_")
		medida_selected = "Saco de #{medida_selected_split[1]} libras"
	end

	medida_selected
end

def calcular_costos(articulo, tipo_articulo, contenidos, cantidad)

	obj = {}

	obj["#{articulo['medida']}"]             = {}
	obj["#{articulo['medida']}"]["precio"]   = articulo['precio_principal']
	obj["#{articulo['medida']}"]["calculo"]  = (articulo['precio_principal'] * cantidad)

	if articulo['contenido_articulos'].present? && articulo['contenido_articulos'].length > 0

		articulo['contenido_articulos'].each do |conte|
			obj["#{conte.medida}"]            = {}
			obj["#{conte.medida}"]["precio"]  =  conte.precio
			obj["#{conte.medida}"]["calculo"] =  ((conte.precio) * cantidad)
		end

	end

	if articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]
		[100, 50, 25].each do | saco |
			if contenidos["Saco_#{saco}"] != nil
				obj["Saco_#{saco}"]            = {}
				obj["Saco_#{saco}"]["precio"]  = (saco / (100).to_f) * articulo['precio_principal']
				obj["Saco_#{saco}"]["calculo"] = (((saco / (100).to_f) * articulo['precio_principal']) * cantidad)
			end
		end
	end

	obj
end

def calcularContenidos(articulo )

	contenido = articulo["contenido_articulos"]
	contenidos = {}

	if articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]
		[100, 50, 25].each do |c|
			contenidos["Saco_#{c}"] = c
		end
	end

	articulo['medida']                          = articulo['medida'] == "N/A" || articulo['medida'] == nil ? articulo['tipo_articulo'].tipo.titleize : articulo['medida']

	contenidos[articulo["medida"]]              = contenido.to_a.length == 0 ? 1 : contenido.to_a.first["cantidad"]

	if contenido.to_a.length > 0

	else
	end

	contenidos[contenido.to_a.first["medida"]]  = 1 if contenido.to_a.length > 0


	if contenido.to_a.length == 2

		cantPrincipal = 1
		cantHijo      = 1
		cantPadre     = 1

		contenido.to_a.each do |conte|
			cantPrincipal *= conte["cantidad"]
			cantPadre      = conte["cantidad"] if conte["referencia"] != nil
		end

		contenidos[articulo["medida"]]          = cantPrincipal
		contenidos[contenido.to_a[0]["medida"]] = cantPadre
		contenidos[contenido.to_a[1]["medida"]] = cantHijo
	end
	contenidos
end

def parse_unidad_saco(unidad, articulo)
	unidad_split  = unidad.split(" ")
	if articulo["vendido_en"] == "Saco" && articulo["calcular_saco"]
		unidad_parsed = "#{unidad_split[0]}_#{unidad_split[2]}"
	else
		unidad_parsed = unidad
	end
	return unidad_parsed
end


def find_articulo_mantenimiento(articulo, hasta)
	desde                           = '2020-10-31 19:59:59'
	query_previo                    = {}
	query_previo['created_at']      = (desde)..(hasta.strftime("%Y-%m-%d %H:%M:%S"))
	query_previo['articulo_id']     = articulo.id

	mantenimiento_previo            = MantenimientoArticulo.where(query_previo).order("created_at desc").limit(1)

	if mantenimiento_previo.length > 0
		mantenimiento_previo          = mantenimiento_previo[0]

		query_posterior               = "id > #{mantenimiento_previo.id} AND articulo_id = #{articulo.id}"
		mantenimiento_posterior       = MantenimientoArticulo.where(query_posterior).order("created_at asc").limit(1)

		mantenimiento_posterior       = mantenimiento_posterior[0]
		mantenimiento_posterior       = mantenimiento_previo if mantenimiento_posterior.nil?


		historico = MantenimientoArticulo.crearArticuloHistorico(mantenimiento_posterior, articulo)
		historico = historico.with_indifferent_access
	else
		primer_mantenimiento            = MantenimientoArticulo.where("articulo_id = #{articulo.id}").order("created_at asc").limit(1)
		if primer_mantenimiento.length > 0
			primer_mantenimiento          = primer_mantenimiento[0]
			historico                     = MantenimientoArticulo.crearArticuloHistorico(primer_mantenimiento, articulo)
			historico                     = historico.with_indifferent_access
		else
			historico = articulo
		end

	end

	return historico
end