class Suplidor < ApplicationRecord
  has_many :documentos_de_identidad, dependent: :destroy
  attribute :documentos_de_identidad
  accepts_nested_attributes_for :documentos_de_identidad, :allow_destroy => true

  def self.get_nombres_suplidores
    return ActiveRecord::Base.connection.exec_query("SELECT s.id, s.nombre from suplidores s")
  end
end
