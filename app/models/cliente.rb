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
    joins_ = "inner join documentos_de_identidad doc on c.id = doc.cliente_id "
    where_ = "where lower(c.nombre || ' ' || c.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%') AND estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end

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
    return clientes
  end
end
