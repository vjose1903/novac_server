class Suplidor < ApplicationRecord
  has_many :documentos_de_identidad, dependent: :destroy
  attribute :documentos_de_identidad
  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  
  def self.get_nombres_suplidores
    return my_query("SELECT s.id, s.nombre from suplidores s")
  end

  # =========================================================================================================================================================

  def self.mudar_info(param)
    res = {"correcto" => true}
    Suplidor.all.each do |suplidor|
      documentos = DocumentoDeIdentidad.where({ suplidor_id: suplidor["id"] })
      
      principal = "cedula"
      documentos.each do |doc|
        suplidor['cedula']  = doc["documento"]  if doc["descripcion"].downcase == "cedula"
        suplidor['rnc']     = doc["documento"]  if doc["descripcion"].downcase == "rnc"
        
        principal = "rnc" if doc["descripcion"].downcase == "rnc" && doc["principal"]
      end
      suplidor['principal'] = principal
      # suplidor['cedula'] =nil 

      unless suplidor.save!
        res = {"correcto" => false}
        break
      end
      
    end
    return res
  end

end
