class RecibosIngreso < ApplicationRecord
  belongs_to :tipo_factura
  belongs_to :user
  belongs_to :cliente
  belongs_to :vehiculo, optional: true

  has_many :detalle_recibos, dependent: :destroy
  attribute :detalle_recibos
  accepts_nested_attributes_for :detalle_recibos, :allow_destroy => true

  attribute :vehiculo
  attribute :user
  attribute :cliente
  attribute :tipo_factura
  attribute :detalle_recibos
  # ===================================================================================================================================================
  def self.get_last_recibo_of_cabecera_factura(id_cabecera)
    select_ = "SELECT dr.id, is_ultimo, recibos_ingreso_id, ri.cliente_id as cliente_id"
    from_ = "FROM detalle_recibos dr"
    joins_ = "inner join recibos_ingresos ri on ri.id = dr.recibos_ingreso_id"
    where_ = "WHERE cabecera_factura_id=#{id_cabecera}"
    order_ = "ORDER BY dr.created_at DESC"
    limit_ = "LIMIT 1"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_} #{limit_}"
    return my_query(query)
  end

  # ===================================================================================================================================================
  def self.find_secuencia
    actual_secuencia_recibo = SecuenciaFactura.find_by_tipo_factura_id(17)

    if actual_secuencia_recibo == [] || actual_secuencia_recibo == nil
      next_secuencia_recibo = 1
    else
      next_secuencia_recibo = actual_secuencia_recibo["secuencia"] + 1
    end

    numero_secuencia = ("%05d" % next_secuencia_recibo)

    return numero_secuencia
  end
  # ========================================================================================================================

  def self.parsearData(data)
    begin
      obj = data.attributes
      obj["detalle_recibos"] = data.detalle_recibos.to_a
      obj["cliente"] = data.cliente
      obj["user"] = data.user
    rescue
      obj = data
    end

    detalles = []
    obj["detalle_recibos"].each do |detalle|
      objD = detalle.attributes
      factura = CabeceraFactura.find_by_id(detalle["cabecera_factura_id"])

      objD["total_factura"] = factura["total_factura"]
      detalles.push(objD)
    end

    if data.chofer
      chofer_ = User.find_by_id(data.chofer)
    end

    obj["chofer"] = chofer_
    obj["detalle_recibos"] = detalles

    return obj
  end
end
