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
