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
  { "referencia": '00', "serie": 'normal',      key: 'factura_sin_comprobante',        "descripcion": 'Factura sin comprobante' },
  { "referencia": '01', "serie": 'normal',      key: 'factura_de_credito_fiscal',      "descripcion": 'Factura con valor fiscal' },
  { "referencia": '02', "serie": 'normal',      key: 'factura_de_consumo',             "descripcion": 'Factura de consumo' },
  { "referencia": '03', "serie": 'normal',      key: 'nota_de_debito',                 "descripcion": 'Nota de debito' },
  { "referencia": '04', "serie": 'normal',      key: 'nota_de_credito',                "descripcion": 'Nota de credito' },
  { "referencia": '11', "serie": 'normal',      key: 'comprobante_compras',            "descripcion": 'Comprobante de compras' },
  { "referencia": '12', "serie": 'normal',      key: 'registro_unico_ingreso',         "descripcion": 'Registro de unico ingreso' },
  { "referencia": '13', "serie": 'normal',      key: 'gastos_menores',                 "descripcion": 'Comprobante para gastos menores' },
  { "referencia": '14', "serie": 'normal',      key: 'regimenes_especiales',           "descripcion": 'Comprobante de regimen especiales' },
  { "referencia": '15', "serie": 'normal',      key: 'gubernamental',                  "descripcion": 'Comprobante gubernamental' },
  { "referencia": '16', "serie": 'normal',      key: 'comprobante_de_exportaciones',   "descripcion": 'Comprobante para exportaciones' },
  { "referencia": '17', "serie": 'normal',      key: 'comprobante_pagos_al_exterior',  "descripcion": 'Comprobantes para pago al exterior' },
  { "referencia": nil,  "serie": 'normal',      key: 'venta_contado',                  "descripcion": 'Venta Contado' },
  { "referencia": nil,  "serie": 'normal',      key: 'compra',                         "descripcion": 'Compra' },
  { "referencia": nil,  "serie": 'normal',      key: 'conduce',                        "descripcion": 'Conduce' },
  { "referencia": nil,  "serie": 'normal',      key: 'produccion',                     "descripcion": 'Produccion' },
  { "referencia": nil,  "serie": 'normal',      key: 'recibo_ingreso',                 "descripcion": 'Recibo_ingreso' },
  { "referencia": nil,  "serie": 'normal',      key: 'venta_credito',                  "descripcion": 'Venta Credito' },
  { "referencia": nil,  "serie": 'normal',      key: 'pre_venta',                      "descripcion": 'pre_venta' },
  { "referencia": nil,  "serie": 'normal',      key: 'cotizacion',                     "descripcion": 'cotizacion' },

  { "referencia": '31', "serie": 'electronica', key: 'factura_de_credito_fiscal',      "descripcion": 'Factura de Crédito Fiscal Electrónica ' },
  { "referencia": '32', "serie": 'electronica', key: 'factura_de_consumo',             "descripcion": 'Factura de Consumo Electrónica' },
  { "referencia": '33', "serie": 'electronica', key: 'nota_de_debito',                 "descripcion": 'Nota de Débito Electrónica' },
  { "referencia": '34', "serie": 'electronica', key: 'nota_de_credito',                "descripcion": 'Nota de Crédito Electrónica' },
  { "referencia": '41', "serie": 'electronica', key: 'comprobante_compras',            "descripcion": 'Compras Electrónico' },
  { "referencia": '43', "serie": 'electronica', key: 'gastos_menores',                 "descripcion": 'Gastos Menores Electrónico' },
  { "referencia": '44', "serie": 'electronica', key: 'regimenes_especiales',           "descripcion": 'Regímenes Especiales Electrónico' },
  { "referencia": '45', "serie": 'electronica', key: 'gubernamental',                  "descripcion": 'Gubernamental Electrónico' },
  { "referencia": '46', "serie": 'electronica', key: 'comprobante_de_exportaciones',   "descripcion": 'Comprobante de Exportaciones Electrónico ' },
  { "referencia": '47', "serie": 'electronica', key: 'comprobante_pagos_al_exterior',  "descripcion": 'Comprobante para Pagos al Exterior Electrónico' },
  { "referencia": nil,  "serie": 'electronica', key: 'venta_contado',                  "descripcion": 'Venta Contado' },
  { "referencia": nil,  "serie": 'electronica', key: 'compra',                         "descripcion": 'Compra' },
  { "referencia": nil,  "serie": 'electronica', key: 'venta_credito',                  "descripcion": 'Venta Credito' },
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

  if provincia_db.nil?
    provincia_db = Provincia.create({nombre: provincia_seed[:nombre], codigo: provincia_seed[:codigo]})
  else
    provincia_db.codigo = provincia_seed[:codigo]
    provincia_db.save!
  end


  puts " "
  puts "ERROR- provincia: ".red + "#{provincia_db.errors.to_json}" if !provincia_db.errors.empty?


  provincia_seed[:municipios].each do |municipio_seed|
    municipio_db = Municipio.find_by(:nombre => municipio_seed[:nombre], :provincia_id => provincia_db[:id])


    if municipio_db.nil?
      municipio_db = Municipio.create({nombre: municipio_seed[:nombre], provincia_id: provincia_db[:id], codigo: municipio_seed[:codigo]})
    else
      municipio_db.codigo = municipio_seed[:codigo]
      municipio_db.save!
    end

    puts " "
    puts "ERROR- municipio: ".red + "#{municipio_db.errors.to_json}" if !municipio_db.errors.empty?

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


G_CONFIG_ARTICULOS.each do |config|

  configuracion_articulo_backend =  ConfigArticulo.find_by_id(1)


  if configuracion_articulo_backend.nil?
    configuracion_articulo_backend = ConfigArticulo.create(config)
    puts " "
    puts "------".cyan * 7
    puts "CREANDO CONFIGURACION ARTICULO"
    puts "------".cyan * 7
    puts " "
    puts "ERROR- ConfigArticulo: ".red + "#{configuracion_articulo_backend.errors.to_json}" if !configuracion_articulo_backend.errors.empty?
  end

end

G_DIVISA_DEFAULT.each do |divisa|
  divisa_db = Divisa.find_by(nombre: divisa[:nombre], estado: true)
  if divisa_db.nil?
    divisa['action'] = 'create'
    resultado = Divisa.create_update_divisa(divisa.with_indifferent_access, true)
    divisa_db = resultado.get_data
    puts " "
    puts "------".cyan * 8
    puts "CREANDO DIVISA"
    puts "------".cyan * 8
    puts " "
    puts "ERROR- divisa_db: ".red + "#{resultado.get_msgs.to_json}" unless resultado.status_valid
  end
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
