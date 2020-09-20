# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(
  {
    "nombre": "alvaro",
    "usuario": "admin",
    "apellido": "",
    "sexo": "m",
    "telefono": "(809)277-0729",
    "email": "prueba@hotmail.com",
    "fecha_nacimiento": "",
    "role": "A",
    "password": "1234567",
    "password_confirmation": "1234567",
  }
)
# ------------------- TEMPORAL -------------------
suplidor = Suplidor.create(
  [{

    "direccion": "Casi en frente de pick and send",
    "email": "lavegaTech@hotmail.com",
    "estado": true,
    "nombre": "La vega tech",
    "telefono": "(986) 986-9869",

  }]
)
# ------------------------------------------------
cliente = Cliente.create(
  [{
    "nombre": "Cliente contado",
    "apellido": nil,
    "telefono": nil,
    "direccion": "C/Padre adolfo Esq. Manuel Ubaldo Gómez No.28",
    "email": "prueba1@hotmail.com",
    "estado": true,
  },
   # ------------------- TEMPORAL -------------------
   {
    "apellido": "Saches",
    "direccion": "Calle sanchez casa #3 calle #5",
    "telefono": "(986) 986-9459",
    "email": "marta@hotmail.com",
    "estado": true,
    "nombre": "Marta",
  }]
  # ------------------------------------------------
)

documentos_de_identidad = DocumentoDeIdentidad.create(
  [
    {
      "user_id": 1,
      "descripcion": "cedula",
      "documento": "402-1447836-4",
    },
    # ------------------- TEMPORAL -------------------
    {
      "suplidor_id": 1,
      "descripcion": "rnc",
      "documento": "124-12424-1",
    },
  # ------------------------------------------------
  ]
)

tipo_articulo = TipoArticulo.create(
  [
    {
      "descripcion": "Celular",
    },
    {
      "descripcion": "Accesorio",
    },
  ]
)
marca = Marca.create(
  [
    {
      "descripcion": "Iphone",
    },
    {
      "descripcion": "Samsung",
    },
  ]
)

modelo = Modelo.create(
  [
    {
      "marca_id": 1,
      "descripcion": "6S",
    },
    {
      "marca_id": 1,
      "descripcion": "X",
    },
    {
      "marca_id": 1,
      "descripcion": "11",
    },
    {
      "marca_id": 2,
      "descripcion": "Galaxy S9 plus",
    },
    {
      "marca_id": 2,
      "descripcion": "Galaxy S10",
    },
    {
      "marca_id": 2,
      "descripcion": "Galaxy A20",
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
    {
      "referencia": nil,
      "descripcion": "Pago trabajo",
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
    {
      "tipo_factura_id": 16,
      "secuencia": 0,
    },

  ]
)

