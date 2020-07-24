class Marca < ApplicationRecord
  def self.filtrarMarca(arg)
    select_ = "SELECT m.*  "
    from_ = "FROM marcas m"
    where_ = "where lower(m.descripcion) like lower('%a%')"

    query = "#{select_} #{from_} #{where_}"

    my_query(query)
  end
end
