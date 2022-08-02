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