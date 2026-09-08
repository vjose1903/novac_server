module Calendar
  LinkableRegistry = {
    'Cliente' => {
      model: Cliente,
      label_method: :nombre_completo,
      subtitle_method: nil,
      search_sql: "immutable_unaccent(clientes.nombre) ILIKE immutable_unaccent(:q) OR immutable_unaccent(clientes.apellido) ILIKE immutable_unaccent(:q) OR immutable_unaccent(documentos_de_identidad.documento) ILIKE immutable_unaccent(:q)",
      relation: -> {
        Cliente
          .where(estado: true)
          .joins("LEFT JOIN documentos_de_identidad ON clientes.id = documentos_de_identidad.origen_id AND documentos_de_identidad.origen_type = 'Cliente' AND documentos_de_identidad.principal = true")
          .distinct
      }
    },
    'User' => {
      model: User,
      label_method: :nombre_completo,
      subtitle_method: :email,
      search_sql: "immutable_unaccent(users.nombre) ILIKE immutable_unaccent(:q) OR immutable_unaccent(users.apellido) ILIKE immutable_unaccent(:q) OR immutable_unaccent(users.email) ILIKE immutable_unaccent(:q)",
      relation: -> { User.where(estado: true) }
    },
    'Suplidor' => {
      model: Suplidor,
      label_method: :nombre_completo,
      subtitle_method: :telefono,
      search_sql: "immutable_unaccent(suplidores.nombre) ILIKE immutable_unaccent(:q) OR immutable_unaccent(suplidores.direccion) ILIKE immutable_unaccent(:q) OR immutable_unaccent(suplidores.email) ILIKE immutable_unaccent(:q)",
      relation: -> { Suplidor.where(estado: true) }
    },
    'Vehiculo' => {
      model: Vehiculo,
      label_method: :info_vehiculo,
      subtitle_method: :marca_modelo_anio,
      search_sql: "immutable_unaccent(vehiculos.marca) ILIKE immutable_unaccent(:q) OR immutable_unaccent(vehiculos.modelo) ILIKE immutable_unaccent(:q) OR immutable_unaccent(vehiculos.anio) ILIKE immutable_unaccent(:q)",
      relation: -> { Vehiculo.where(estado: true) }
    }
  }.freeze
end
