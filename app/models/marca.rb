class Marca < ApplicationRecord

  def self.filtrarMarcas(arg)
    arg = arg === " " ? "" : arg

    where("LOWER(descripcion) LIKE LOWER(?)", "%#{arg}%")
  end





end
