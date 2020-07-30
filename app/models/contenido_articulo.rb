class ContenidoArticulo < ApplicationRecord
  belongs_to :articulo
  # validates :articulo_id, presence: { :message => "Articulo id no esta llegando" }
end
