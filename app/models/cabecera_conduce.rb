class CabeceraConduce < ApplicationRecord
  belongs_to :user
  belongs_to :cliente

  attribute :user
  attribute :cliente

  has_many :detalle_conduces, dependent: :destroy
  attribute :detalle_conduces
  accepts_nested_attributes_for :detalle_conduces, :allow_destroy => true

  # ========================================================================================================================
  def self.parsearData(objeto)
    puts "--------------- inicio parsearData ---------------"

    begin
      obj = objeto.attributes
      obj["cliente"] = objeto.cliente
      obj["user"] = objeto.user
      obj["numero_conduce"] = objeto.numero_conduce
    rescue
      obj = objeto
    end

    @tipoFactura = TipoFactura.find_by_id(obj["tipo_factura_id"])

    arrayDetalle = DetalleConduce.where({ cabecera_conduce_id: obj["id"] })
    detalleConduce = []

    arrayDetalle.each do |detalle_conduce|
      objD = {}

      articuloSelect = Articulo.find_by_id(detalle_conduce["articulo_id"])

      unidad = detalle_conduce["unidad"].split(" ")

      if unidad.length > 1
        objD["descripcion"] = "#{articuloSelect["nombre"]} (#{unidad[2]} LBS)"
        objD["unidad"] = "#{unidad[0]}"
        objD["peso_saco"] = unidad[2]
      else
        objD["descripcion"] = "#{articuloSelect["nombre"]}"
        objD["unidad"] = detalle_conduce["unidad"]
      end

      objD["detalle_Factura_id"] = detalle_conduce["detalle_Factura_id"]
      objD["cabecera_conduce_id"] = detalle_conduce["cabecera_conduce_id"]
      objD["articulo"] = articuloSelect["nombre"]
      objD["articulo_id"] = articuloSelect["id"]
      objD["cantidad"] = detalle_conduce["cantidad"]
      objD["cantidad_en_unidades"] = detalle_conduce["cantidad_en_unidades"]
      objD["id"] = detalle_conduce["id"]

      detalleConduce.push(objD)
    end

    obj["detalle_conduces"] = []
    obj["detalle_conduces"] = detalleConduce

    puts "--------------- fin parsearData ---------------"
    puts ""
    puts ""
    return obj
  end

  # ========================================================================================================================

end
