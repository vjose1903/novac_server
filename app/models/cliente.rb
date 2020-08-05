class Cliente < ApplicationRecord
  belongs_to :imagen, optional: true
  # belongs_to :documento_de_identidad, optional: true

  has_many :documentos_de_identidad, dependent: :destroy

  attribute :documentos_de_identidad

  accepts_nested_attributes_for :imagen
  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  # =========================================================================================================================================================

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

  # =========================================================================================================================================================

  def self.filtrarCliente(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT c.*, doc.documento as doc_documento, doc.descripcion as doc_descripcion, doc.id as doc_id "
    from_ = "FROM clientes c"
    joins_ = "inner join documentos_de_identidad doc on c.id = doc.cliente_id "
    where_ = "where lower(c.nombre || ' ' || c.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%') AND estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end
  # =========================================================================================================================================================

  def self.CalculateBalanceCLiente(id, totalFactura, operacion)
    cliente = Cliente.find_by_id(id)
    balance = cliente["balance"]

    if operacion == "+"
      sumatoria = balance + totalFactura.to_f
    else
      if totalFactura.to_f > balance
        return { :error => true, :msg => "El monto ingresado es mayor al balance del cliente", :status => 400 }
      else
        sumatoria = balance - totalFactura.to_f
      end
    end
    sumatoria = sumatoria.to_d.truncate(2).to_f

    unless cliente.update({ balance: sumatoria })
      return { :error => true, :msg => "Error actualizanco el balance del cliente", :status => 400 }
    else
      return { :error => false, :balance => sumatoria }
    end
  end

  # ===================================================================================================================================================
  def self.get_cliente_by_name(nombre)
    select_ = "SELECT id, imagen_id, nombre, apellido, telefono, direccion, sexo, created_at, updated_at, limite_credito, estado, maximo_credito, vendedor_id, balance"
    from_ = "FROM clientes"
    where_ = " WHERE lower(nombre) like lower('#{nombre}%') AND estado = true"
    query = "#{select_} #{from_} #{where_}"
    return my_query(query)
  end
end
