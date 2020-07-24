class Modelo < ApplicationRecord
  belongs_to :marca
  attribute :marca

  def self.filtrarModelo(arg)
    select_ = "SELECT m.*, ma.descripcion as marca_descripcion, ma.id as marca_id"
    from_ = "FROM modelos m "
    joins_ = "inner join marcas ma on m.marca_id = ma.id"
    where_ = "where  lower(ma.descripcion|| ' '|| m.descripcion) like lower('%#{arg}%')"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end
end
