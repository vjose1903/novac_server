class ContenidoArticulo < ApplicationRecord
  belongs_to :articulo
  
  
  # before_validation :otras_validaciones
  validates :costo, presence: { :message => "El costo del contenido no puede estar vacio." }
  validates :precio, presence: { :message => "El precio del contenido no puede estar vacio." } 
  validates :cantidad, presence: { :message => "La cantidad del contenido no puede estar vacio." } 
  validates :medida, presence: { :message => "La medida del contenido no puede estar vacio." }, uniqueness: { scope: [:articulo_id, :condicion], case_sensitive: false, :message => "El articulo ya tiene registrado esta medida << %{value} >>" }
  validates :condicion, presence: { :message => "La condicion del contenido no puede estar vacio." }
  

  def self.get_contenido_articulo_by_id(id)
    return my_query("SELECT * FROM contenido_articulos WHERE articulo_id = #{id}")
  end
end
