class DetallePeriodoFiscalSerializer < ActiveModel::Serializer

end

class DetallePeriodoFiscalSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :enero, :febrero, :marzo, :abril, :mayo, :junio, :julio, :agosto, :septiembre, :octubre, :noviembre, :diciembre]
  end
end
