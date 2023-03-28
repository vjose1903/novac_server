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


def agregar_movimientos_viajes
  choferes_viajes                    = ChoferViaje.all
  facturas_sin_vehiculo              = []

  choferes_viajes.each do | chofer_viaje |
    movimiento                       = { :user_id => nil, :vehiculo_id => nil, :cabecera_factura_id => nil, :created_at => nil, :updated_at => nil }

    recibo                           = chofer_viaje.recibos_ingreso
    cabecera_factura                 = recibo.detalle_recibos[0].cabecera_factura
    vehiculo                         = cabecera_factura.camiones_viajes[0] || nil

    vehiculo_id                      = vehiculo != nil ? vehiculo.vehiculo_id : recibo.vehiculo_id

    movimiento[:user_id]             = chofer_viaje.user_id
    movimiento[:vehiculo_id]         = vehiculo_id
    movimiento[:cabecera_factura_id] = cabecera_factura.id
    movimiento[:created_at]          = cabecera_factura.created_at
    movimiento[:updated_at]          = cabecera_factura.updated_at

    if movimiento[:vehiculo_id] == nil
      facturas_sin_vehiculo.push(cabecera_factura.numero_comprobante)
    end


    movimiento_backend   = MovimientoViaje.where({user_id: movimiento[:user_id], vehiculo_id: movimiento[:vehiculo_id], cabecera_factura_id: movimiento[:cabecera_factura_id]})

    if movimiento_backend.empty?
      movimiento_viaje   = MovimientoViaje.create(movimiento)
    end
  end



  puts "facturas_sin_vehiculo ===> ".magenta + " #{facturas_sin_vehiculo}"
  return nil
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

    puts " "
   }




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

def crear_cuentas_tipo_articulos

  TipoArticulo.all.each do | tipo_articulo |
    tipo_articulo.descripcion = "#{tipo_articulo.descripcion}"
    resultado = TipoArticulo.create_update_tipo_articulo(tipo_articulo.attributes.with_indifferent_access, true)
  end

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
  # query_principal = "cabecera_facturas.tipo = 'venta' AND articulo_id not in (102, 213, 165, 69, 214, 108, 214)"
  query_principal = "cabecera_facturas.tipo = 'venta'"
  DetalleFactura.where(query_principal).joins("inner join cabecera_facturas on detalle_facturas.cabecera_factura_id = cabecera_facturas.id").includes([ {articulo: [:contenido_articulos, :tipo_articulo]}, :cabecera_factura ]).each do | detalle |
    articulo           = detalle.articulo
    cabecera_factura   = detalle.cabecera_factura
    tipo_articulo      = articulo.tipo_articulo

    articulo_historico = find_articulo_mantenimiento(articulo, cabecera_factura.fecha_equivalente)
    unidad_en_turno    = detalle.unidad

    unidad_en_turno    = parse_unidad_saco(detalle.unidad, articulo_historico) if detalle.unidad.include? "Saco de"

    contenidos         = calcularContenidos(articulo_historico)
    contenido_en_turno = contenidos[unidad_en_turno]

    calculo   = 0

    if unidad_en_turno.include? "Saco_"

      unidad_en_turno_split = unidad_en_turno.split("_")
      saco                  = unidad_en_turno_split[1].to_i
      calculo               = saco * detalle.cantidad if !saco.nil?


    elsif unidad_en_turno.include? "Saco de"
      unidad_en_turno_split = unidad_en_turno.split(" ")
      saco                  = unidad_en_turno_split[2].to_i
      calculo               = saco * detalle.cantidad if !saco.nil?


    else

      calculo = detalle.cantidad * contenido_en_turno if !contenido_en_turno.nil?
    end

    if calculo > 0 && (calculo.to_f >= detalle.cantidad_en_unidades + 0.1 || calculo.to_f <= detalle.cantidad_en_unidades - 0.1)
      detalle.cantidad_en_unidades = calculo
      detalle.save!
    end

  end

  return nil
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