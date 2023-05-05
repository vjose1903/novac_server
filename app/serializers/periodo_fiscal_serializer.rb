class PeriodoFiscalSerializer < ActiveModel::Serializer
  attribute :id,                        if: Proc.new { self.get_param('id')                       || self.get_param('all') }
  attribute :fecha_inicio,              if: Proc.new { self.get_param('fecha_inicio')             || self.get_param('all') }
  attribute :fecha_cierre,              if: Proc.new { self.get_param('fecha_cierre')             || self.get_param('all') }
  attribute :estado,                    if: Proc.new { self.get_param('estado')                   || self.get_param('all') }
  attribute :is_open,                   if: Proc.new { self.get_param('is_open')                  || self.get_param('all') }
  attribute :detalle_periodo_fiscal,    if: Proc.new { self.get_param('detalle_periodo_fiscal')   || self.get_param('all') }

  attribute :prev_month_open,           if: Proc.new { self.get_param('prev_month_open')          || self.get_param('all') }
  attribute :actual_month_open,         if: Proc.new { self.get_param('actual_month_open')        || self.get_param('all') }
  attribute :next_month_open,           if: Proc.new { self.get_param('next_month_open')          || self.get_param('all') }


  def detalle_periodo_fiscal
    serialize_parser(object.detalle_periodo_fiscal, {all: true})
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


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
