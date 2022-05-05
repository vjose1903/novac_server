# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

usuarios =
  [
    {
      "nombre": "ADM",
      "usuario": "adm01",
      "uid": "adm01",
      "apellido": "01",
      "sexo": "i",
      "telefono": "(809) 573-0060",
      "email": "admagroindustrialsrl@gmail.com",
      "fecha_nacimiento": "2020-01-01",
      "role": "V",
      "password": "1234567",
      "password_confirmation": "1234567",
      "estado": true,
      "imagen_id": nil,
    },
    {
      "nombre": "Mari",
      "usuario": "ADM",
      "uid": "ADM",
      "apellido": "Santos",
      "sexo": "f",
      "telefono": "(829) 292-8772",
      "email": "mari_santos0515@hotmail.com",
      "fecha_nacimiento": "1968-10-17",
      "role": "A",
      "password": "1234567",
      "password_confirmation": "1234567",
      "estado": true,
      "imagen_id": nil,
    },
  ]

usuarios.each do |user|
  puts " "
  puts "===================================".blue
  puts "a crear el ususario #{user["ususario"]}"
  puts "===================================".blue

  if User.find_by_usuario(user[:usuario]).nil?
    usuario_creado = User.create(user)
		puts "ERROR- Usuario: ".red + "#{usuario_creado.errors.to_json}"
    puts "Usuario: #{usuario_creado.to_json}".magenta
  end
end


clientes = [

	{
    "imagen_id": nil,
    "nombre": "Cliente contado",
    "apellido": ".",
    "telefono": "(---) --------",
    "direccion": "Autopista duarte KM 0 el Higuero",
    "sexo": "i",
    "limite_credito": 0,
    "maximo_credito": 0,
		"vendedor_id":1
  },
]

clientes.each do |client|
  if Cliente.find_by_nombre(client[:nombre]).nil?
    cliente_ = Cliente.create(client)
    puts " "
		puts "ERROR - Cliente: ".red + "#{cliente_.errors.to_json}"
  end
end

documentos_de_identidad = [
  {
		"origen_type": "User",
		"origen_id": 2,
    "descripcion": "cedula",
    "documento": "402-1463928-4",
    "principal": "true",
  },
  {
		"origen_type": "Cliente",
		"origen_id": 1,
    "descripcion": "cedula",
    "documento": " ",
    "principal": true,
  },

]

documentos_de_identidad.each do |doc|
  if DocumentoDeIdentidad.find_by_documento(doc[:documento]).nil?
    documento = DocumentoDeIdentidad.create(doc)
		puts " "
		puts "ERROR -  documento_identidad: ".red + "#{documento.errors.to_json}"
  end
end

tipos_articulo = [
  {
    "descripcion": "Veterinaria",
  },
  {
    "descripcion": "Materia prima",
  },
  {
    "descripcion": "Producto terminado",
  },
  {
    "descripcion": "Otros",
  },
]

tipos_articulo.each do |tipo|
  if TipoArticulo.find_by_descripcion(tipo[:descripcion]).nil?
    tipo_articulo =TipoArticulo.create(tipo)
		puts " "
		puts "ERROR - tipo_articulo: ".red + "#{tipo_articulo.errors.to_json}"
  end
end

tipos_factura = [
  {
    "referencia": "00",
    "descripcion": "Factura sin comprobante",
  },
  {
    "referencia": "01",
    "descripcion": "Factura con valor fiscal",
  },
  {
    "referencia": "02",
    "descripcion": "Factura de consumo",
  },
  {
    "referencia": "03",
    "descripcion": "Nota de debito",
  },
  {
    "referencia": "04",
    "descripcion": "Nota de credito",
  },
  {
		"referencia": "11",
    "descripcion": "Comprobante de compras",
  },
  {
    "referencia": "12",
    "descripcion": "Registro de unico ingreso",
  },
  {
    "referencia": "13",
    "descripcion": "Comprobante para gastos menores",
  },
  {
    "referencia": "14",
    "descripcion": "Comprobante de regimen especiales",
  },
  {
    "referencia": "15",
    "descripcion": "Comprobante gubernamental",
  },
  {
    "referencia": "16",
    "descripcion": "Comprobante para exportaciones",
  },
  {
    "referencia": "17",
    "descripcion": "Comprobantes para pago al exterior",
  },
  {
    "referencia": nil,
    "descripcion": "Venta Contado",
  },
  {
    "referencia": nil,
    "descripcion": "Compra",
  },
  {
		"referencia": nil,
    "descripcion": "Conduce",
  },
  {
    "referencia": nil,
    "descripcion": "Produccion",
  },
  {
    "referencia": nil,
    "descripcion": "Recibo_ingreso",
  },
  {
    "referencia": nil,
    "descripcion": "Venta Credito",
  },
]

tipos_factura.each do |tipo_fac|

  if (TipoFactura.find_by_descripcion(tipo_fac[:descripcion])).nil?
    tipo = TipoFactura.create(tipo_fac)
		puts " "
		puts "ERROR- tipo_factura: ".red + "#{tipo.errors.to_json}"

    secuencia = SecuenciaFactura.create( { "tipo_factura_id": tipo.id, "secuencia": 0, } )
		puts " "
		puts "ERROR - secuencia_factura: ".red + "#{secuencia.errors.to_json}"
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
		puts "ERROR- secuencia_comprobante: ".red + "#{secu.errors.to_json}"
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
		puts "ERROR- marca: ".red + "#{marca_.errors.to_json}"
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
		puts "ERROR- modelo: ".red + "#{modelo_.errors.to_json}"
  end
end

PROVINCIAS_MUNICIPIOS.each do |provincia_seed|

  provincia_db = Provincia.find_by_nombre(provincia_seed[:nombre])

  provincia_db = Provincia.create({nombre: provincia_seed[:nombre]}) if provincia_db.nil?
	puts " "
	puts "ERROR- provincia: ".red + "#{provincia_db.errors.to_json}"

  provincia_seed[:municipios].each do |municipio_seed|
    if Municipio.find_by_nombre(municipio_seed).nil?
      muni = Municipio.create({nombre: municipio_seed, provincia_id: provincia_db[:id]})
			puts " "
			puts "ERROR- municipio: ".red + "#{muni.errors.to_json}"
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
		puts " "
		puts "ERROR- permiso: ".red + "#{permiso_backend.errors.to_json}"
  end

  puts " "
  puts "permiso_backend ".red + "#{permiso_backend.to_json}"
  puts " "

  permiso[:acciones].each do | accion |
    accion_backend = Accion.find_by_descripcion(accion[:descripcion])

    if accion_backend.nil?
      puts " "
      puts "------".yellow * 7
      puts "CREANDO ACCION #{accion[:descripcion]}"
      puts "------".yellow * 7
      accion_backend = Accion.create({descripcion: accion[:descripcion], nombre: accion[:nombre], metodo: accion[:metodo]})
			puts " "
			puts "ERROR- accion: ".red + "#{accion_backend.errors.to_json}"
    end
    puts "accion_backend ".red + "#{accion_backend.to_json}"

    permiso_accion = PermisoAccion.where({permiso_id: permiso_backend.id, accion_id: accion_backend.id})

    if permiso_accion.empty?
      perm_action = PermisoAccion.create({permiso_id: permiso_backend.id, accion_id: accion_backend.id})
      puts " "
      puts "------".magenta * 7
      puts "CREANDO PERMISO_ACCION"
      puts "------".magenta * 7
			puts " "
			puts "ERROR- permiso_accion: ".red + "#{perm_action.errors.to_json}"
    end
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
