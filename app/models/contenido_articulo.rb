class ContenidoArticulo < ApplicationRecord
  belongs_to :articulo
  # validates :articulo_id, presence: { :message => "Articulo id no esta llegando" }
<<<<<<< HEAD
=======
  def self.get_condicion_contenido
    return my_query("SELECT id, articulo_id, cantidad, costo, precio,  CASE WHEN referencia IS NULL THEN 'padre' ELSE 'hijo' end as condicion FROM contenido_articulos ORDER BY articulo_id ASC")
  end

  def self.get_condicion_contenido_by_id(id)
    return my_query("SELECT id, articulo_id, cantidad, costo, precio, medida,  CASE WHEN referencia IS NULL THEN 'padre' ELSE 'hijo' end as condicion FROM contenido_articulos WHERE articulo_id = #{id} ORDER BY articulo_id ASC")
  end

  def self.get_contenido_articulo_by_id(id)
    return my_query("SELECT * FROM contenido_articulos WHERE articulo_id = #{id}")
  end
>>>>>>> prueba
end
