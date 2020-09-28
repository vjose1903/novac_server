class ContenidoArticulo < ApplicationRecord
  belongs_to :articulo
  # validates :articulo_id, presence: { :message => "Articulo id no esta llegando" }

  def self.get_contenido_articulo_by_id(id)
    return my_query("SELECT * FROM contenido_articulos WHERE articulo_id = #{id}")
  end
end
