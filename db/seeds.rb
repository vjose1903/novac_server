# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users =
  [
    {
      "nombre": "Mari",
      "usuario": "ADM",
      "apellido": "Santos",
      "sexo": "f",
      "telefono": "(829)292-8772",
      "email": "mari_santos0515@hotmail.com",
      "fecha_nacimiento": "1968-17-10",
      "role": "A",
      "password": "1234567",
      "password_confirmation": "1234567",
      "estado": true,
      "imagen_id": nil,
    },
    {
      "nombre": "ADM",
      "usuario": "adm01",
      "apellido": " ",
      "sexo": "m",
      "telefono": "(809) 573-0060",
      "email": "admagroindustrialsrl@gmail.com",
      "fecha_nacimiento": "2020-01-01",
      "role": "V",
      "password": "1234567",
      "password_confirmation": "1234567",
      "estado": true,
      "imagen_id": nil,
    },
  ]

users.each do |user|
  if User.find_by_usuario(user["usuario"]).nil?
    User.create(user)
  end
end

clientes = [

  {
    "imagen_id": nil,
    "nombre": "Cliente contado",
    "apellido": nil,
    "telefono": nil,
    "direccion": "Autopista duarte KM 0 el Higuero",
    "sexo": nil,
    "limite_credito": nil,
  },
  { "nombre": "Juan", "estado": true, "apellido": "Perez", "limite_credito": 30, "telefono": "(131) 351-5134", "direccion": "Por ahi en las carolinas", "sexo": "M", "maximo_credito": 20000, "vendedor_id": 2 },
]

clientes.each do |client|
  if Cliente.find_by_nombre(client["nombre"]).nil?
    Cliente.create(client)
  end
end

documentos_de_identidad = [
  {
    "user_id": 1,
    "descripcion": "cedula",
    "documento": "402-1463928-4",
    "principal": "true",
  },
  {
    "descripcion": "cedula",
    "documento": " ",
    "principal": true,
    "cliente_id": 1,
  },

]

documentos_de_identidad.each do |doc|
  if DocumentoDeIdentidad.find_by_documento(doc["documento"]).nil?
    DocumentoDeIdentidad.create(doc)
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

tipos_articulo.each do |supli|
  if TipoArticulo.find_by_descripcion(supli["descripcion"]).nil?
    TipoArticulo.create(supli)
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
    "descripcion": "Venta",
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
]

tipos_factura.each do |tipo_fac|
  if TipoFactura.find_by_descripcion(tipo_fac["descripcion"]).nil?
    tipo = TipoFactura.create(tipo_fac)

    SecuenciaFactura.create(
      {
        "tipo_factura_id": tipo.id,
        "secuencia": 0,
      }
    )
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
  if SecuenciaComprobante.find_by_tipo_factura_id(secuencia["tipo_factura_id"]).nil?
    SecuenciaComprobante.create(secuencia)
  end
end
