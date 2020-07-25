class TipoArticulo < ApplicationRecord

  #   ==============================================================================================================

  def self.filtrarTipoArticulo(arg)
    arg = arg === " " ? "" : arg

    select_ = "SELECT ta.*"
    from_ = "FROM tipo_articulos ta"
    where_ = "where lower(ta.descripcion) like lower('%#{arg}%')"

    query = "#{select_} #{from_} #{where_}"

    my_query(query)
  end

  # =====================================================================================================================

end
