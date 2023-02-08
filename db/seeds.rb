# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


G_usuarios.each do |user|
  puts " "

  if User.find_by_usuario(user[:usuario]).nil?
    puts "===================================".blue
    puts "a crear el ususario #{user["ususario"]}"
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
  if DocumentoDeIdentidad.find_by_documento(doc[:documento]).nil?
    documento = DocumentoDeIdentidad.create(doc)
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
  # 1
  {
    "referencia": "00",
    "descripcion": "Factura sin comprobante",
  },
  # 2
  {
    "referencia": "01",
    "descripcion": "Factura con valor fiscal",
  },
  # 3
  {
    "referencia": "02",
    "descripcion": "Factura de consumo",
  },
  # 4
  {
    "referencia": "03",
    "descripcion": "Nota de debito",
  },
  # 5
  {
    "referencia": "04",
    "descripcion": "Nota de credito",
  },
  # 6
  {
    "referencia": "11",
    "descripcion": "Comprobante de compras",
  },
  # 7
  {
    "referencia": "12",
    "descripcion": "Registro de unico ingreso",
  },
  # 8
  {
    "referencia": "13",
    "descripcion": "Comprobante para gastos menores",
  },
  # 9
  {
    "referencia": "14",
    "descripcion": "Comprobante de regimen especiales",
  },
  # 10
  {
    "referencia": "15",
    "descripcion": "Comprobante gubernamental",
  },
  # 11
  {
    "referencia": "16",
    "descripcion": "Comprobante para exportaciones",
  },
  # 12
  {
    "referencia": "17",
    "descripcion": "Comprobantes para pago al exterior",
  },
  # 13
  {
    "referencia": nil,
    "descripcion": "Venta Contado",
  },
  # 14
  {
    "referencia": nil,
    "descripcion": "Compra",
  },
  # 15
  {
    "referencia": nil,
    "descripcion": "Conduce",
  },
  # 16
  {
    "referencia": nil,
    "descripcion": "Produccion",
  },
  # 17
  {
    "referencia": nil,
    "descripcion": "Recibo_ingreso",
  },
  # 18
  {
    "referencia": nil,
    "descripcion": "Venta Credito",
  },
  # 19
  {
    "referencia": nil,
    "descripcion": "pre_venta",
  },
  # 20
  {
    "referencia": nil,
    "descripcion": "cotizacion",
  },
]

tipos_factura.each do |tipo_fac|

  if (TipoFactura.find_by_descripcion(tipo_fac[:descripcion])).nil?
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

marcas = [
  {
    "descripcion": "Daihatsu"
  },
]

marcas.each do |marca|
  if Marca.find_by_descripcion(marca[:descripcion]).nil?
    marca_ = Marca.create(marca)
    puts " "
    puts "ERROR- marca: ".red + "#{marca_.errors.to_json}" if !marca_.errors.empty?
  end
end

modelos = [
  {
    "marca_id": 1,
    "descripcion": "Delta"
  },
]

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

  permiso_backend = Permiso.find_by_descripcion(permiso[:descripcion])

  if permiso_backend.nil?
    puts "------".red * 7
    puts "CREANDO PERMISO: #{permiso[:descripcion]}"
    puts "------".red * 7
    permiso_backend = Permiso.create({descripcion: permiso[:descripcion], nombre: permiso[:nombre], controlador: permiso[:controlador], mostrar_front: permiso[:mostrar_front]})
    puts " " if !permiso_backend.errors.empty?
    puts "ERROR- permiso: ".red + "#{permiso_backend.errors.to_json}" if !permiso_backend.errors.empty?
  end

  permiso[:acciones].each do | accion |
    accion_backend = Accion.find_by_descripcion(accion[:descripcion])

    if accion_backend.nil?
      puts " "
      puts "------".yellow * 7
      puts "CREANDO ACCION #{accion[:descripcion]}"
      puts "------".yellow * 7
      accion_backend = Accion.create({descripcion: accion[:descripcion], nombre: accion[:nombre], metodo: accion[:metodo], mostrar_front: accion[:mostrar_front]})
      puts " " if !accion_backend.errors.empty?
      puts "ERROR- accion: ".red + "#{accion_backend.errors.to_json}" if !accion_backend.errors.empty?
    end


    permiso_accion = PermisoAccion.where({permiso_id: permiso_backend.id, accion_id: accion_backend.id})

    if permiso_accion.empty?
      perm_action = PermisoAccion.create({permiso_id: permiso_backend.id, accion_id: accion_backend.id})
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

all_permisos_aciones.each do | permiso_accion_backend |

  if permiso_accion_backend.permiso.mostrar_front && permiso_accion_backend.accion.mostrar_front
    rol_permiso_accion_molde = {role_id: role_administrador.id , permiso_accion_id: permiso_accion_backend.id}
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

usuario_admin           = User.find_by_usuario("ADMIN")

unless usuario_admin.nil?
  roles_usuario         = usuario_admin.roles
  if roles_usuario.empty?
    puts " "
    puts "------".cyan * 7
    puts "AGREGANDO ROLE ADMINISTRADOR AL USUARIO ADMIN"
    puts "------".cyan * 7
    usuario_admin.roles = Role.where({nombre: "Administrador"})
    usuario_admin.save!
    puts " " if !usuario_admin.errors.empty?
    puts "ERROR- agregando role admin: ".red + "#{usuario_admin.errors.to_json}" if !usuario_admin.errors.empty?
  end
end


G_ROLES_CUSTOM.each do | rol |
  rol_backend = Role.find_by_key(rol[:key])

  if rol_backend.nil?
    rol_backend = Role.create({ nombre: rol[:nombre], key: rol[:key], descripcion: rol[:descripcion], ruta_defecto: rol[:ruta_defecto], estado: true})
    puts " "
    puts "------".yellow * 7
    puts "CREANDO ROLE <<#{rol_backend.nombre}>> "
    puts "------".yellow * 7
    puts " "
    puts "ERROR- role: ".red + "#{rol_backend.errors.to_json}" if !rol_backend.errors.empty?
  end

  rol[:permisos_acciones].each do | permiso_accion |

    permiso_backend = Permiso.find_by_descripcion(permiso_accion[:permiso_descripcion])

    permiso_accion[:acciones].each do |accion|
      accion_backend = Accion.find_by_descripcion(accion)

      permiso_accion_backend = PermisoAccion.where({permiso_id: permiso_backend.id, accion_id: accion_backend.id})

      permiso_accion_backend = PermisoAccion.create({permiso_id: permiso_backend.id, accion_id: accion_backend.id}) if permiso_accion_backend.empty?

			permiso_accion_backend = permiso_accion_backend.first if permiso_accion_backend.kind_of?(Array)

      rol_permiso_accion       = RolPermisoAccion.where({role_id: rol_backend.id , permiso_accion_id: permiso_accion_backend.id})

      if rol_permiso_accion.empty?
        rol_permiso_accion     = RolPermisoAccion.create({role_id: rol_backend.id , permiso_accion_id: permiso_accion_backend.id})

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


configuracion_articulo_backend =  ConfigArticulo.find_by_id(1)

if configuracion_articulo_backend.nil?
	configuracion_articulo_backend = ConfigArticulo.create({ porciento_ganancia: 15})
	puts " "
	puts "------".cyan * 7
	puts "CREANDO CONFIGURACION ARTICULO"
	puts "------".cyan * 7
	puts " "
	puts "ERROR- ConfigArticulo: ".red + "#{configuracion_articulo_backend.errors.to_json}" if !configuracion_articulo_backend.errors.empty?
end
# G_OTROS_COSTOS.each do | otro_costo |
# 	otro_costo_backend = OtroCosto.find_by_key(otro_costo[:key])
#
# 	if otro_costo_backend.nil?
# 		puts "------".red * 7
# 		puts "CREANDO OTRO COSTO: #{otro_costo[:key]}"
# 		puts "------".red * 7
# 		otro_costo_backend = OtroCosto.create({descripcion: otro_costo[:descripcion], key: otro_costo[:key], precio: otro_costo[:precio], costo: otro_costo[:costo], estado: true})
# 	end
# end
