class Produccion < ApplicationRecord
  belongs_to :user

  attribute :user

  has_many :detalles_produccion, dependent: :destroy
  attribute :detalles_produccion
  accepts_nested_attributes_for :detalles_produccion, :allow_destroy => true

  # =========================================================================================================
  def parsearData(objeto)
    begin
      att = objeto.attributes
      att["detalles_produccion"] = objeto.detalles_produccion.to_a
    rescue
      att = objeto
    end

    articuloSelect = Articulo.find_by_id(objeto["articulo_id"])
    responsableProd = User.find_by_id(objeto["user_id"])

    att["articulo"] = "#{articuloSelect["nombre"]}"
    att["usuario"] = "#{responsableProd["nombre"]} #{responsableProd["apellido"]}"
    return att
  end
end
