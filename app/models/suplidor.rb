class Suplidor < ApplicationRecord
  has_many :documentos_de_identidad, :as => :origen, dependent: :destroy, class_name: "DocumentoDeIdentidad"

  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  
  def self.get_nombres_suplidores
    return my_query("SELECT s.id, s.nombre from suplidores s")
  end

end
