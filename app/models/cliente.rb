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
end
