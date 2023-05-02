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


	# TODO: tener en cuenta los meses si estan todos en FALSE se puede abrir el mes previo de diciembre si estan todos en NULL no se pueden abrir ningun mes anterior
	def prev_month_open

    prev_month_open_obj          = nil
    actual_open_month            = object.get_actual_open_month
    actual_open_month_number     = Mes::Number.byLabel(actual_open_month)

    if ( !actual_open_month.nil? && ( actual_open_month_number >= 2 && actual_open_month_number <= 12 ) ) || ( actual_open_month.nil? && !object.cierre_cuenta.nil? )

      if actual_open_month.nil? && !object.cierre_cuenta.nil?
        actual_open_month_number = 13
      end

      prev_month_open_obj        = { label: Mes::Label.byNumber( actual_open_month_number - 1 ), number: (actual_open_month_number - 1) }
    end

    return prev_month_open_obj
  end

  def actual_month_open

    actual_month_open_obj    = nil
    actual_open_month        = object.get_actual_open_month
    actual_open_month_number = Mes::Number.byLabel(actual_open_month)

    if ( !actual_open_month.nil? && ( actual_open_month_number >= 1 && actual_open_month_number <= 12 ) )

      actual_month_open_obj  = { label: Mes::Label.byNumber( actual_open_month_number ), number: actual_open_month_number }
    end

    return actual_month_open_obj
  end

	# TODO: tener en cuenta los meses si estan todos en NULL se puede abrir el mes siguiente de enero si estan todos en FALSE no se pueden abrir ningun mes siguiente
	def next_month_open
    next_month_open_obj          = nil
    actual_open_month            = object.get_actual_open_month
    actual_open_month_number     = Mes::Number.byLabel(actual_open_month)

    if ( !actual_open_month.nil? && ( actual_open_month_number >= 1 && actual_open_month_number <= 11 ) ) || ( actual_open_month.nil? && object.cierre_cuenta.nil? )

      if actual_open_month.nil? && object.cierre_cuenta.nil?
        actual_open_month_number = 0
      end

      next_month_open_obj        = { label: Mes::Label.byNumber(actual_open_month_number + 1), number: (actual_open_month_number + 1) }
    end

    return next_month_open_obj
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
