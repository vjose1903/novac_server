class Modelo < ApplicationRecord
  belongs_to :marca
  attribute :marca

  def self.filtrarModelo(arg)
    arg = arg === " " ? "" : arg
    includes(:marca)
      .joins(:marca)
      .select("modelos.*, marcas.descripcion AS marca_descripcion")
      .where("LOWER(marcas.descripcion || ' ' || modelos.descripcion) LIKE LOWER(?)", "%#{arg}%")
  end

  # =====================================================================================================================

  def self.parsearModelosFiltro(modelos)

    modelos.each do |model|
      model["marca"] = { id: model["marca_id"], descripcion: model["marca_descripcion"] }
      model.delete("marca_descripcion")
    end

    return modelos
  end

end
