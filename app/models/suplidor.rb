class Suplidor < ApplicationRecord
  has_one :documento_de_identidad, dependent: :destroy
  attribute :documento_de_identidad
  accepts_nested_attributes_for :documento_de_identidad, :allow_destroy => true

  def self.get_nombres_suplidores
    return my_query("SELECT s.id, s.nombre from suplidores s")
  end

  #   ==============================================================================================================

  def self.filtrarSuplidores(arg)
    select_ = "SELECT s.*, doc.documento as doc_documento, doc.descripcion as doc_descripcion, doc.id as doc_id"
    from_ = "FROM suplidores s "
    joins_ = "inner join documentos_de_identidad doc on s.id = doc.suplidor_id "
    where_ = "where lower(s.nombre || ' ' || s.direccion || ' ' || s.email || ' ' || doc.documento ) like lower('%#{arg}%')"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.parsearSuplidoresFiltro(suplidores)
    suplidores.each do |supli|
      supli["documento_de_identidad"] = { id: supli["doc_id"], descripcion: supli["doc_descripcion"], documento: supli["doc_documento"], suplidor_id: supli["id"] }

      supli.delete("doc_descripcion")
      supli.delete("doc_id")
      supli.delete("doc_documento")
    end
    return suplidores
  end
end
