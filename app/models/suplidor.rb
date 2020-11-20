class Suplidor < ApplicationRecord
  has_many :documentos_de_identidad, dependent: :destroy
  attribute :documentos_de_identidad
  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  def self.get_nombres_suplidores
    return my_query("SELECT s.id, s.nombre from suplidores s")
  end

  #   ==============================================================================================================

  def self.filtrarSuplidores(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT s.*"
    from_ = "FROM suplidores s "
    where_ = "where lower(s.nombre || ' ' || s.direccion || ' ' || coalesce(s.email, '') ) like lower('%#{arg}%') AND estado = true"
    order_ = "ORDER BY s.id ASC"

    query = "#{select_} #{from_} #{where_} #{order_}"

    my_query(query)
  end

  #   ==============================================================================================================

  def self.parsearSuplidores(suplidores)
    suplidores.each do |supli|
      supli["nombre"] = supli["nombre"].capitalize
    end

    return suplidores
  end
end
