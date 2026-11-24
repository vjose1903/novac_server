class PeriodoFiscalSerializer < ActiveModel::Serializer



  def detalle_periodo_fiscal
    fast_serialize_parser(object.detalle_periodo_fiscal, {all: true})
  end


  def prev_month_open
    return object.prev_month_open
  end

  def actual_month_open
    return object.actual_month_open
  end

  def next_month_open
    return object.next_month_open
  end

end

class PeriodoFiscalSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :fecha_inicio, :fecha_cierre, :estado, :is_open, :detalle_periodo_fiscal, :prev_month_open, :actual_month_open, :next_month_open]
  end
end
