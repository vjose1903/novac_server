class Suplidor < ApplicationRecord
  has_one :documento_de_identidad, dependent: :destroy
  attribute :documento_de_identidad
  accepts_nested_attributes_for :documento_de_identidad, :allow_destroy => true

  def self.get_nombres_suplidores
    return my_query("SELECT s.id, s.nombre from suplidores s")
  end

  #   ==============================================================================================================

  def self.filtrarModelo(arg)
    select_ = "SELECT m.*, ma.descripcion as marca_descripcion, ma.id as marca_id"
    from_ = "FROM modelos m "
    joins_ = "inner join marcas ma on m.marca_id = ma.id"
    where_ = "where  lower(ma.descripcion|| ' '|| m.descripcion) like lower('%#{arg}%')"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.parsearModelosFiltro(modelos)
    puts "------".red * 20
    puts modelos.to_json
    puts "------".red * 20

    modelos.each do |model|
      model["marca"] = { id: model["marca_id"], descripcion: model["marca_descripcion"] }
      model.delete("marca_descripcion")
      model.delete("marca_id")
    end

    puts "------".yellow * 20
    puts modelos.to_json
    puts "------".yellow * 20
    return modelos
  end
end
