class Marca < ApplicationRecord

  def self.filtrarMarcas(arg)
    arg = arg === " " ? "" : arg

    select_ = "SELECT m.*  "
    from_ = "FROM marcas m"
    where_ = "where lower(m.descripcion) like lower('%#{arg}%')"

    query = "#{select_} #{from_} #{where_}"

    my_query(query)
  end





end
