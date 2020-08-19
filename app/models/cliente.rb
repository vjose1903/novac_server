class Cliente < ApplicationRecord
  has_one :documento_de_identidad, dependent: :destroy
  attribute :documento_de_identidad
  accepts_nested_attributes_for :documento_de_identidad, :allow_destroy => true

  # ===================================================================================================================================================
  def self.get_cliente_by_name(nombre)
    select_ = "SELECT *"
    from_ = "FROM clientes"
    where_ = " WHERE lower(nombre) like lower('#{nombre}%') AND estado = true"
    query = "#{select_} #{from_} #{where_}"
    return my_query(query)
  end
  # =====================================================================================================================

  #

  def self.filtrarCliente(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT c.*, doc.documento as doc_documento, doc.descripcion as doc_descripcion, doc.id as doc_id "
    from_ = "FROM clientes c"
    joins_ = "left join documentos_de_identidad doc on c.id = doc.cliente_id "
    where_ = "where lower(c.nombre || ' ' || c.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%') AND estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

<<<<<<< HEAD
    my_query(query)
  end
=======
  def self.filtrarCliente(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT c.* , v.nombre as vendedor_nombre, v.apellido as vendedor_apellido"
    from_ = "FROM clientes c"
    joins_ = "inner join users v on c.vendedor_id = v.id"
    where_ = "where lower(c.nombre || ' ' || c.apellido ) like lower('%#{arg}%') AND c.estado = true"
    order_ = "ORDER BY c.id ASC"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end
  #   ==============================================================================================================

  def self.parsearClientes(clientes)
    clientes.each do |cliente|
      cliente["nombre"] = cliente["nombre"].capitalize
      cliente["apellido"] = cliente["apellido"].capitalize
      cliente["vendedor"] = { nombre: "#{cliente["vendedor_nombre"].capitalize} #{cliente["vendedor_apellido"].capitalize}", id: cliente["vendedor_id"] }

      cliente.delete("vendedor_nombre")
      cliente.delete("vendedor_apellido")
    end

    return clientes
  end
  # =========================================================================================================================================================
>>>>>>> prueba

  # =====================================================================================================================

  def self.parsearClientesFiltro(clientes)
    clientes.each do |cli|
      if cli["doc_id"]
        cli["documento_de_identidad"] = { id: cli["doc_id"], descripcion: cli["doc_descripcion"], documento: cli["doc_documento"], user_id: cli["id"] }
      else
        cli["documento_de_identidad"] = {}
      end

      cli.delete("doc_descripcion")
      cli.delete("doc_id")
      cli.delete("doc_documento")
    end
<<<<<<< HEAD
    return clientes
=======
  end

  # ===================================================================================================================================================
  def self.get_cliente_by_name(nombre)
    select_ = "SELECT id, imagen_id, nombre, apellido, telefono, direccion, sexo, created_at, updated_at, limite_credito, estado, maximo_credito, vendedor_id, balance"
    from_ = "FROM clientes"
    where_ = " WHERE lower(nombre) like lower('#{nombre}%') AND estado = true"
    query = "#{select_} #{from_} #{where_}"
    return my_query(query)
>>>>>>> prueba
  end
end
