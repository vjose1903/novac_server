
G_usuarios =
[
  {
    "nombre": "Panaderia Brendy",
    "usuario": "adm01",
    "uid": "adm01",
    "apellido": "01",
    "sexo": "i",
    "telefono": "(809) 573-0060",
    "email": "panaderia_brendy@gmail.com",
    "fecha_nacimiento": "2022-01-01",
    "role": "V",
    "password": "1234567",
    "password_confirmation": "1234567",
    "estado": true,
    "imagen_id": nil,
  },
  {
    "nombre": "Administrador",
    "usuario": "ADMIN",
    "uid": "ADMIN",
    "apellido": "sistema",
    "sexo": "f",
    "telefono": "(829) 292-8772",
    "email": "admin@hotmail.com",
    "fecha_nacimiento": "2022-01-01",
    "role": "A",
    "password": "1234567",
    "password_confirmation": "1234567",
    "estado": true,
    "imagen_id": nil,
  },
]


G_clientes = [
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

G_documentos_de_identidad = [
  {
    "origen_type": "User",
    "origen_id": 2,
    "descripcion": "cedula",
    "documento": "000-0000000-0",
    "principal": true,
  },
  {
    "origen_type": "Cliente",
    "origen_id": 1,
    "descripcion": "cedula",
    "documento": " ",
    "principal": true,
  },
]


G_tipos_articulo = [
  { "descripcion": "Dulces" },
  { "descripcion": "Veterinaria" },
  { "descripcion": "Producto terminado" },
  { "descripcion": "Otros" },
]
