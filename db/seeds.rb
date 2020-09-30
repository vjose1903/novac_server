# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(
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
    # borrar -----------------------------------------
    {
      "nombre": "Alberto",
      "usuario": "alberto",
      "apellido": "santos",
      "sexo": "m",
      "telefono": "(131) 351-5131",
      "email": "alberto@hotmail.com",
      "fecha_nacimiento": "1990-02-02T04:00:00.000Z",
      "password": "1234567",
      "password_confirmation": "1234567",
      "role": "V",
      "imagen_id": nil,
      "estado": true,
    },
  # ------------------------------------------------
  ]
)

cliente = Cliente.create([

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
])

# "vendedor_id": 2,
# borrar -----------------------------------------
suplidor = Suplidor.create(
  {
    "nombre": "animal Farm",
    "telefono": "(834) 614-5613",
    "direccion": "Por ahi en santo domingo",
    "email": "animal@hotmail.com",
    "estado": true,
  }
)
# ------------------------------------------------
documento_de_identidad = DocumentoDeIdentidad.create(
  [
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
    # borrar -----------------------------------------
    {
      "user_id": 2,
      "descripcion": "cedula",
      "documento": "531-3138481-3",
      "principal": true,
    },
    {
      "cliente_id": 2,
      "descripcion": "cedula",
      "documento": "531-3138481-2",
      "principal": true,
    },
    {
      "descripcion": "rnc",
      "suplidor_id": 1,
      "documento": "047-65135-1",
      "principal": true,
    },
  # ------------------------------------------------
  ]
)

tipo_articulo = TipoArticulo.create(
  [
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
)

tipo_factura = TipoFactura.create(
  [
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
  ]
)
tipo_recibo = TipoRecibo.create(
  [
    {
      "descripcion": "compra_adelantada",
    },
    {
      "descripcion": "Pago factura",
    },
  ]
)
secuencia_ingresos = SecuenciaIngreso.create(
  [
    {
      "tipo_recibo_id": 1,
      "secuencia": 0,
    },
  ]
)

secuencia_factura = SecuenciaFactura.create(
  [
    {
      "tipo_factura_id": 1,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 2,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 3,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 4,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 5,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 6,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 7,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 8,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 9,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 10,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 11,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 12,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 13,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 14,
      "secuencia": 0,
    },
    {
      "tipo_factura_id": 15,
      "secuencia": 0,
    },

  ]
)

secuencia = SecuenciaComprobante.create([

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
])
