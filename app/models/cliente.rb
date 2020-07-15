class Cliente < ApplicationRecord
  has_one :documento_de_identidad, dependent: :destroy
  attribute :documento_de_identidad
  accepts_nested_attributes_for :documento_de_identidad, :allow_destroy => true

  # ===================================================================================================================================================
  def self.get_cliente_by_name(nombre)
    select_ = "SELECT id, imagen_id, nombre, apellido, telefono, direccion, sexo, created_at, updated_at, limite_credito, estado, maximo_credito, vendedor_id, balance"
    from_ = "FROM clientes"
    where_ = " WHERE lower(nombre) like lower('#{nombre}%') AND estado = true"
    query = "#{select_} #{from_} #{where_}"
    return ActiveRecord::Base.connection.exec_query(query)
  end
end
