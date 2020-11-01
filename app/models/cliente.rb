class Cliente < ApplicationRecord
  belongs_to :imagen, optional: true
  # belongs_to :documento_de_identidad, optional: true

  has_many :documentos_de_identidad, dependent: :destroy

  attribute :documentos_de_identidad

  accepts_nested_attributes_for :imagen
  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  def init
    self.balance = 0 unless self.balance
  end

  # =========================================================================================================================================================

  def self.filtrarCliente(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT c.* , v.nombre as vendedor_nombre, v.apellido as vendedor_apellido"
    from_ = "FROM clientes c"
    joins_ = "left join users v on c.vendedor_id = v.id"
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
      cliente["vendedor"] = { nombre: "#{cliente["vendedor_nombre"].capitalize if cliente["vendedor_nombre"]} #{cliente["vendedor_apellido"].capitalize if cliente["vendedor_apellido"]}", id: cliente["vendedor_id"] }

      cliente.delete("vendedor_nombre")
      cliente.delete("vendedor_apellido")
    end

    return clientes
  end
  # =========================================================================================================================================================

  def self.CalculateBalanceCLiente(id, totalFactura, operacion)
    cliente = Cliente.find_by_id(id)

    balance = 0
    if !cliente["balance"].nil?
      balance = cliente["balance"]
    end

    sumatoria = 0
    if operacion == "+"
      sumatoria = balance + totalFactura.to_f
    else
      # if totalFactura.to_f > balance
      #   return { :error => true, :msg => "El monto ingresado es mayor al balance del cliente", :status => 400 }
      # else
      sumatoria = balance - totalFactura.to_f
      # end
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
