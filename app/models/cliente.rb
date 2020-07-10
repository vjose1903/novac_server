class Cliente < ApplicationRecord
  belongs_to :imagen, optional: true
  # belongs_to :documento_de_identidad, optional: true

  has_many :documentos_de_identidad, dependent: :destroy

  attribute :documentos_de_identidad

  accepts_nested_attributes_for :imagen
  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  # =========================================================================================================================================================

  #
  #
  # ;

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
    return ActiveRecord::Base.connection.exec_query(query)
  end
end
