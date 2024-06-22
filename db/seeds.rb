# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


G_usuarios.each do |user|

  if User.find_by_usuario(user[:usuario]).nil? && User.find_by_email(user[:email]).nil?
    puts "===================================".blue
    puts "a crear el usuario: #{user[:usuario]}"
    puts "===================================".blue
    usuario_creado = User.create(user)

    puts "ERROR- Usuario: ".red + "#{usuario_creado.errors.to_json}" if !usuario_creado.errors.empty?
  end
end

G_clientes.each do |client|
  if Cliente.find_by_nombre(client[:nombre]).nil?
    cliente_ = Cliente.create(client)
    puts " "
    puts "ERROR - Cliente: ".red + "#{cliente_.errors.to_json}" if !cliente_.errors.empty?
  end
end

G_documentos_de_identidad.each do | doc |

  entidad = doc[:origen_type] == 'User' ? User.find_by_usuario(doc[:origen_entity]) : Cliente.find_by_nombre(doc[:origen_entity])

  if DocumentoDeIdentidad.find_by_documento(doc[:documento]).nil?
    documento = DocumentoDeIdentidad.create({ origen_type: doc[:origen_type], origen_id: entidad.id, descripcion: doc[:descripcion], documento: doc[:documento], principal: doc[:principal] })
    puts " "
    puts "ERROR -  documento_identidad: ".red + "#{documento.errors.to_json}" if !documento.errors.empty?
  end
end

G_tipos_articulo.each do |tipo|
  if TipoArticulo.find_by_descripcion(tipo[:descripcion]).nil?
    tipo_articulo =TipoArticulo.create(tipo)
    puts " "
    puts "ERROR - tipo_articulo: ".red + "#{tipo_articulo.errors.to_json}" if !tipo_articulo.errors.empty?
  end
end

tipos_factura = [
  { "referencia": "00", "serie": "normal",  "descripcion": "Factura sin comprobante" },
  { "referencia": "01", "serie": "normal",  "descripcion": "Factura con valor fiscal" },
  { "referencia": "02", "serie": "normal",  "descripcion": "Factura de consumo" },
  { "referencia": "03", "serie": "normal",  "descripcion": "Nota de debito" },
  { "referencia": "04", "serie": "normal",  "descripcion": "Nota de credito" },
  { "referencia": "11", "serie": "normal",  "descripcion": "Comprobante de compras" },
  { "referencia": "12", "serie": "normal",  "descripcion": "Registro de unico ingreso" },
  { "referencia": "13", "serie": "normal",  "descripcion": "Comprobante para gastos menores" },
  { "referencia": "14", "serie": "normal",  "descripcion": "Comprobante de regimen especiales" },
  { "referencia": "15", "serie": "normal",  "descripcion": "Comprobante gubernamental" },
  { "referencia": "16", "serie": "normal",  "descripcion": "Comprobante para exportaciones" },
  { "referencia": "17", "serie": "normal",  "descripcion": "Comprobantes para pago al exterior" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "Venta Contado" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "Compra" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "Conduce" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "Produccion" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "Recibo_ingreso" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "Venta Credito" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "pre_venta" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "cotizacion" },
  { "referencia": nil,  "serie": "normal",  "descripcion": "pago_factura" },

  { "referencia": "31", "serie": "electronica",  "descripcion": "Factura con valor fiscal" },
  { "referencia": "32", "serie": "electronica",  "descripcion": "Factura de consumo" },
  { "referencia": "33", "serie": "electronica",  "descripcion": "Nota de debito" },
  { "referencia": "34", "serie": "electronica",  "descripcion": "Nota de credito" },
  { "referencia": "41", "serie": "electronica",  "descripcion": "Comprobante de compras" },
  { "referencia": "43", "serie": "electronica",  "descripcion": "Comprobante para gastos menores" },
  { "referencia": "44", "serie": "electronica",  "descripcion": "Comprobante de regimen especiales" },
  { "referencia": "45", "serie": "electronica",  "descripcion": "Comprobante gubernamental" },
  { "referencia": "46", "serie": "electronica",  "descripcion": "Comprobante para exportaciones" },
  { "referencia": "47", "serie": "electronica",  "descripcion": "Comprobantes para pago al exterior" },
  { "referencia": nil,  "serie": "electronica",  "descripcion": "Venta Contado" },
  { "referencia": nil,  "serie": "electronica",  "descripcion": "Compra" },
  { "referencia": nil,  "serie": "electronica",  "descripcion": "Venta Credito" },
  { "referencia": nil,  "serie": "electronica",  "descripcion": "pre_venta" },
  { "referencia": nil,  "serie": "electronica",  "descripcion": "pago_factura" },
]

tipos_factura.each do |tipo_fac|
  tipo_factura = TipoFactura.where({ descripcion: tipo_fac[:descripcion], serie: tipo_fac[:serie] })

  if tipo_factura.empty?
    tipo = TipoFactura.create(tipo_fac)
    puts " "
    puts "ERROR- tipo_factura: ".red + "#{tipo.errors.to_json}" if !tipo.errors.empty?

    secuencia = SecuenciaFactura.create( { "tipo_factura_id": tipo.id, "secuencia": 0, } )
    puts " "
    puts "ERROR - secuencia_factura: ".red + "#{secuencia.errors.to_json}" if !secuencia.errors.empty?
  end
end

secuencias = [
  {
    "tipo_factura_id": 1,
    "secuencia": 1,
    "desde": 1,
    "hasta": 9223372036854775807,
    "fecha_compra": Time.now,
    "fecha_valida": nil,
    "estado": true,
    "usado": false,
  },
  {
    "tipo_factura_id": 3,
    "secuencia": 1,
    "desde": 1,
    "hasta": 9223372036854775807,
    "fecha_compra": Time.now,
    "fecha_valida": nil,
    "estado": true,
    "usado": false,
  },
]

secuencias.each do |secuencia|
  if SecuenciaComprobante.find_by_tipo_factura_id(secuencia[:tipo_factura_id]).nil?
    secu = SecuenciaComprobante.create(secuencia)
    puts " "
    puts "ERROR- secuencia_comprobante: ".red + "#{secu.errors.to_json}" if !secu.errors.empty?
  end
end

marcas = [ { "descripcion": "Daihatsu" }, ]

marcas.each do |marca|
  if Marca.find_by_descripcion(marca[:descripcion]).nil?
    marca_ = Marca.create(marca)
    puts " "
    puts "ERROR- marca: ".red + "#{marca_.errors.to_json}" if !marca_.errors.empty?
  end
end

modelos = [ { "marca_id": 1, "descripcion": "Delta" }, ]

modelos.each do |modelo|
  if Modelo.find_by_descripcion(modelo[:descripcion]).nil?
    modelo_ = Modelo.create(modelo)
    puts " "
    puts "ERROR- modelo: ".red + "#{modelo_.errors.to_json}" if !modelo_.errors.empty?
  end
end

PROVINCIAS_MUNICIPIOS.each do |provincia_seed|

  provincia_db = Provincia.find_by_nombre(provincia_seed[:nombre])

  provincia_db = Provincia.create({nombre: provincia_seed[:nombre]}) if provincia_db.nil?
  puts " "
  puts "ERROR- provincia: ".red + "#{provincia_db.errors.to_json}" if !provincia_db.errors.empty?

  provincia_seed[:municipios].each do |municipio_seed|
    if Municipio.find_by_nombre(municipio_seed).nil?
      muni = Municipio.create({nombre: municipio_seed, provincia_id: provincia_db[:id]})
      puts " "
      puts "ERROR- municipio: ".red + "#{muni.errors.to_json}" if !muni.errors.empty?
    end
  end
end

G_PERMISOS.each do | permiso |

  permiso_db = Permiso.find_by_descripcion(permiso[:descripcion])

  if permiso_db.nil?
    puts "------".red * 7
    puts "CREANDO PERMISO: #{permiso[:descripcion]}"
    puts "------".red * 7
    permiso_db = Permiso.create({descripcion: permiso[:descripcion], nombre: permiso[:nombre], controlador: permiso[:controlador], mostrar_front: permiso[:mostrar_front]})
    puts " " if !permiso_db.errors.empty?
    puts "ERROR- permiso: ".red + "#{permiso_db.errors.to_json}" if !permiso_db.errors.empty?
  end

  permiso[:acciones].each do | accion |
    accion_db = Accion.find_by_descripcion(accion[:descripcion])

    if accion_db.nil?
      puts " "
      puts "------".yellow * 7
      puts "CREANDO ACCION #{accion[:descripcion]}"
      puts "------".yellow * 7
      accion_db = Accion.create({descripcion: accion[:descripcion], nombre: accion[:nombre], metodo: accion[:metodo], mostrar_front: accion[:mostrar_front]})
      puts " " if !accion_db.errors.empty?
      puts "ERROR- accion: ".red + "#{accion_db.errors.to_json}" if !accion_db.errors.empty?
    end


    permiso_accion = PermisoAccion.where({permiso_id: permiso_db.id, accion_id: accion_db.id})

    if permiso_accion.empty?
      perm_action = PermisoAccion.create({permiso_id: permiso_db.id, accion_id: accion_db.id})
      puts " "
      puts "------".magenta * 7
      puts "CREANDO PERMISO_ACCION"
      puts "------".magenta * 7
      puts " " if !perm_action.errors.empty?
      puts "ERROR- permiso_accion: ".red + "#{perm_action.errors.to_json}" if !perm_action.errors.empty?
    end
  end
end

role_administrador = Role.find_by_nombre("Administrador")

if role_administrador.nil?
  role_administrador = Role.create({  nombre: "Administrador", key:'admin', descripcion:"Persona encargada de los procesos administrativos de la empresa.", ruta_defecto:"/", estado: true})
  puts " "
  puts "------".yellow * 7
  puts "CREANDO ROLE"
  puts "------".yellow * 7
  puts " "
  puts "ERROR- role administrador: ".red + "#{role_administrador.errors.to_json}" if !role_administrador.errors.empty?
end

all_permisos_aciones         = PermisoAccion.all

all_permisos_aciones.each do | permiso_accion_db |

  if permiso_accion_db.permiso.mostrar_front && permiso_accion_db.accion.mostrar_front
    rol_permiso_accion_molde = {role_id: role_administrador.id , permiso_accion_id: permiso_accion_db.id}
    rol_permiso_accion       = RolPermisoAccion.where(rol_permiso_accion_molde)
    if rol_permiso_accion.empty?
      rol_permiso_accion     = RolPermisoAccion.create(rol_permiso_accion_molde)
      puts " "
      puts "------".blue * 7
      puts "CREANDO ROL PERMISO ACCION"
      puts "------".blue * 7
      puts " " if !rol_permiso_accion.errors.empty?
      puts "ERROR- rol_permiso_accion: ".red + "#{rol_permiso_accion.errors.to_json}" if !rol_permiso_accion.errors.empty?
    end
  end
end



G_ROLES_CUSTOM.each do | rol |
  rol_db = Role.find_by_key(rol[:key])

  if rol_db.nil?
    rol_db = Role.create({ nombre: rol[:nombre], key: rol[:key], descripcion: rol[:descripcion], ruta_defecto: rol[:ruta_defecto], estado: true})
    puts " "
    puts "------".yellow * 7
    puts "CREANDO ROLE <<#{rol_db.nombre}>> "
    puts "------".yellow * 7
    puts " "
    puts "ERROR- role: ".red + "#{rol_db.errors.to_json}" if !rol_db.errors.empty?
  end

  rol[:permisos_acciones].each do | permiso_accion |

    permiso_db = Permiso.find_by_descripcion(permiso_accion[:permiso_descripcion])

    permiso_accion[:acciones].each do |accion|
      accion_db = Accion.find_by_descripcion(accion)

      permiso_accion_db = PermisoAccion.where({permiso_id: permiso_db.id, accion_id: accion_db.id})

      permiso_accion_db = PermisoAccion.create({permiso_id: permiso_db.id, accion_id: accion_db.id}) if permiso_accion_db.empty?

      permiso_accion_db = permiso_accion_db.first if permiso_accion_db.kind_of?(Array)

      rol_permiso_accion       = RolPermisoAccion.where({role_id: rol_db.id , permiso_accion_id: permiso_accion_db.id})

      if rol_permiso_accion.empty?
        rol_permiso_accion     = RolPermisoAccion.create({role_id: rol_db.id , permiso_accion_id: permiso_accion_db.id})

        puts " "
        puts "------".magenta * 7
        puts "CREANDO ROL_PERMISO_ACCION"
        puts "------".magenta * 7
        puts " "
        puts "ERROR- role: ".red + "#{rol_permiso_accion.errors.to_json}" if !rol_permiso_accion.errors.empty?
      end
    end
  end
end



['ADMIN','novac'].each do | username |

  usuario_admin           = User.find_by_usuario(username)

  unless usuario_admin.nil?
    roles_usuario         = usuario_admin.roles
    if roles_usuario.empty?
      puts " "
      puts "------".cyan * 7
      puts "AGREGANDO ROLE ADMINISTRADOR AL USUARIO: #{usuario_admin.nombre}"
      puts "------".cyan * 7
      usuario_admin.roles = Role.where({key: "admin"})
      puts 'usuario_admin --> '.cyan + " #{usuario_admin.to_json}"
      usuario_admin.save!
      puts " " if !usuario_admin.errors.empty?
      puts "ERROR- agregando role admin: ".red + "#{usuario_admin.errors.to_json}" if !usuario_admin.errors.empty?
    end
  end

end

vendedor_default           = User.find_by_usuario('adm01')

unless vendedor_default.nil?
  roles_usuario         = vendedor_default.roles
  if roles_usuario.empty?
    puts " "
    puts "------".cyan * 7
    puts "AGREGANDO ROLE VENDEDOR AL USUARIO TIENDA"
    puts "------".cyan * 7
    vendedor_default.roles = Role.where({key: "vendedor"})
    vendedor_default.save!
    puts " " if !vendedor_default.errors.empty?
    puts "ERROR- agregando role admin: ".red + "#{vendedor_default.errors.to_json}" if !vendedor_default.errors.empty?
  end
end


G_CONFIG_ARTICULOS.each do | config |

  configuracion_articulo_db =  ConfigArticulo.find_by_id(1)


  if configuracion_articulo_db.nil?
    configuracion_articulo_db = ConfigArticulo.create(config)
    puts " "
    puts "------".cyan * 7
    puts "CREANDO CONFIGURACION ARTICULO"
    puts "------".cyan * 7
    puts " "
    puts "ERROR- ConfigArticulo: ".red + "#{configuracion_articulo_db.errors.to_json}" if !configuracion_articulo_db.errors.empty?
  end

end

G_CONFIG_ENTIDAD_CUENTA.each do | config |
  configuracion_entidad_db     = ConfiguracionEntidadCuenta.find_by_descripcion(config[:descripcion])


  if configuracion_entidad_db.nil?
    cuenta_contable_db              = CuentaContable.find_by_descripcion(config[:cuenta_contable_descripcion])
    if cuenta_contable_db.nil?
      puts " "
      puts "------".red * 7
      puts "NO EXISTE LA CUENTA CONTABLE DE: #{config[:cuenta_contable_descripcion]}"
      puts "------".red * 7
      puts " "
    else

      config_molde                  = { cuenta_contable_id: cuenta_contable_db.id, **config }.with_indifferent_access

      resultado                     = ConfiguracionEntidadCuenta.create_update_configuracion_entidad_cuenta(config_molde, nil, true)
      configuracion_entidad_db = resultado.get_data
      puts " "
      puts "------".cyan * 8
      puts "CREANDO CONFIGURACION ENTIDAD CUENTA"
      puts "------".cyan * 8
      puts " "
      puts "ERROR- ConfiguracionEntidadCuenta: ".red + "#{resultado.get_msgs.to_json}" if !resultado.status_valid
    end
  end
end


G_DIVISA_DEFAULT.each do | divisa |
	divisa_db              = Divisa.find_by({nombre: divisa[:nombre], estado: true})
	if divisa_db.nil?
		divisa['action'] = 'create'
		resultado = Divisa.create_update_divisa(divisa.with_indifferent_access, true)
		divisa_db = resultado.get_data
		puts " "
		puts "------".cyan * 8
		puts "CREANDO DIVISA"
		puts "------".cyan * 8
		puts " "
		puts "ERROR- divisa_db: ".red + "#{resultado.get_msgs.to_json}" if !resultado.status_valid
	end
end



def primer_y_ultimo_dia_del_anio_actual
  year = Date.today.year
  fecha_inicio = Date.new(year, 1, 1)
  fecha_cierre = Date.new(year, 12, 31)
  return fecha_inicio, fecha_cierre
end

if ( G_HAS_CONTABILIDAD )
	fecha_inicio, fecha_cierre = primer_y_ultimo_dia_del_anio_actual()

	periodo_fiscal_db   = PeriodoFiscal.find_by({fecha_inicio: fecha_inicio, fecha_cierre: fecha_cierre})

	if periodo_fiscal_db.nil?
		resultado = PeriodoFiscal.create_periodo_fiscal({fecha_inicio: fecha_inicio, fecha_cierre: fecha_cierre}.with_indifferent_access, true)
		periodo_fiscal_db = resultado.get_data
		puts " "
		puts "------".cyan * 8
		puts "CREANDO PERIODO FISCAL"
		puts "------".cyan * 8
		puts " "
		puts "ERROR- periodo_fiscal_db: ".red + "#{resultado.get_msgs.to_json}" if !resultado.status_valid
	end
end