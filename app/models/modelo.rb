class Modelo < ApplicationRecord
  belongs_to :marca
  attribute :marca

  def filtrarModelo(arg)
    select_ = "SELECT * "
    from_ = "FROM celulares c"
    where_ = "where  lower(marca|| ' '|| modelo|| ' ' ||nombre ) like lower('%#{arg}%') AND estado = true"
    query = "#{select_} #{from_} #{where_}"

    my_query(query)
  end
end
