class PeriodoFiscal < ApplicationRecord
  belongs_to :usuario_cerrador,     dependent: :destroy, class_name: 'User', optional: true
  has_one    :detalle_periodo_fiscal
  has_one    :cierre_cuenta

  validates :fecha_inicio, presence: { :message => "Debe de especificar una fecha de inicio para el periodo fiscal." }
  validates :fecha_cierre, presence: { :message => "Debe de especificar una fecha de cierre para el periodo fiscal." }

  # ============================================================================================================================================

  def self.models_includes
    includes = [ :detalle_periodo_fiscal, :usuario_cerrador ]
    return includes
  end

  # ============================================================================================================================================

  def self.create_periodo_fiscal(params, is_save=false)
    res                                = Response.new
    PeriodoFiscal.transaction do

      periodo_fiscal                   = PeriodoFiscal.new

      periodo_fiscal.fecha_inicio      = params[:fecha_inicio]
      periodo_fiscal.fecha_cierre      = params[:fecha_cierre]

      periodo_fiscal.valid?

      if periodo_fiscal.errors.empty?

        res = periodo_fiscal.add_detalle(params) if params[:id].nil?

        if res.status_valid && periodo_fiscal.save!
          res.set_data(periodo_fiscal)

          action = params[:id] ? 'actualizado' : 'creado'
          res.add_msg("Periodo Fiscal #{action} correctamente.")
        end
      end

      unless periodo_fiscal.errors.empty?
        res.add_msgs(periodo_fiscal.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      transaction_rollback if !periodo_fiscal.errors.empty? || !res.status_valid
    end

    return res
  end

  # ============================================================================================================================================

  def add_detalle(params)
    detalle                                                     = {}

    Mes.labels.keys.each do | month_number |
      current_month_number                                      = month_number.to_s.gsub("_", "").strip
      detalle[:"#{Mes::Label.byNumber(current_month_number)}"]  = nil
    end

    resultado = DetallePeriodoFiscal.create_update_detalle(detalle, self, false)

    self.detalle_periodo_fiscal = resultado.get_data

    return resultado
  end

  # ============================================================================================================================================

  def self.open_new_periodo
    res = Response.new
    PeriodoFiscal.transaction do

      lastest_periodo_fiscal                = PeriodoFiscal.all.order("id DESC").limit(1)
      params                                = {}

      unless lastest_periodo_fiscal.empty?
        last_periodo_fiscal                 = lastest_periodo_fiscal.first

        new_periodo_fiscal                  = PeriodoFiscal.new(last_periodo_fiscal.attributes.except("id", "created_at", "updated_at"))

        new_periodo_fiscal.fecha_inicio     = new_periodo_fiscal.fecha_inicio.advance(years: 1)
        new_periodo_fiscal.fecha_cierre     = new_periodo_fiscal.fecha_cierre.advance(years: 1)
        res                                 = new_periodo_fiscal.add_detalle(params)


        if res.status_valid && ((new_periodo_fiscal.errors.empty? && new_periodo_fiscal.save!))
          res.set_data(serialize_parser(new_periodo_fiscal, {all:true}))
          res.add_msg("Periodo Fiscal: #{formatearFecha(new_periodo_fiscal.fecha_inicio.to_s, TipoFecha.sin_hora)} - #{formatearFecha(new_periodo_fiscal.fecha_cierre.to_s, TipoFecha.sin_hora)} abierto correctamente.")
        else
          res.add_msgs(last_periodo_fiscal.errors.to_a)
          res.add_msgs(new_periodo_fiscal.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        transaction_rollback if !new_periodo_fiscal.errors.empty? || !res.status_valid

      else
        res.add_msg("Para abrir un nuevo periodo fiscal primero debe de registrar el primer periodo")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

  # ============================================================================================================================================

  def self.get_open_period
    return PeriodoFiscal.find_by({ estado: true, is_open: true })
  end

  # ============================================================================================================================================

  def self.is_open_month(fecha)
    fecha_equivalente         = Date.parse(fecha)
    current_periodo_fiscal    = PeriodoFiscal.get_open_period
    monthToEvaluate           = current_periodo_fiscal.detalle_periodo_fiscal[:"#{Mes::Label.byNumber(fecha_equivalente.month)}"]

    is_open = ( fecha_equivalente.year == current_periodo_fiscal.fecha_inicio.year ) && (monthToEvaluate != nil && monthToEvaluate == true)

    return is_open
  end

  # =========================================================================================================================================================

  def get_first_null_month
    actual_open_month = nil

    self.detalle_periodo_fiscal.as_json.each do | key, value |
      actual_open_month = key if value.nil?
      break if value.nil?
    end

    return actual_open_month
  end

  # =========================================================================================================================================================

  def get_actual_open_month
    actual_open_month = nil

    self.detalle_periodo_fiscal.as_json.each do | key, value |
      actual_open_month = key if "#{value}" == "true"
    end

    return actual_open_month
  end


  # =========================================================================================================================================================

  def self.filtrar(filter_target, params)
    res = Response.new(params)

    periodos_fiscales = PeriodoFiscal
    .where("( (periodos_fiscales.fecha_inicio between '#{(Date.parse filter_target).beginning_of_day}' AND '#{(Date.parse filter_target).end_of_day}' ) OR (periodos_fiscales.fecha_cierre between '#{(Date.parse filter_target).beginning_of_day}' AND '#{(Date.parse filter_target).end_of_day}' ) ) AND periodos_fiscales.estado = true")
    .order('periodos_fiscales.id ASC')
    .includes(PeriodoFiscal.models_includes)

    if periodos_fiscales.length > 0
      res.set_data(periodos_fiscales, { all: true }, PeriodoFiscal.models_includes)
    else
      res.set_data([])
      cantidad_registros = PeriodoFiscal.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen periodos fiscales registrados.' : 'No existen periodos fiscales con las especificaciones introducidas.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================

  def get_next_prev_actual_month(params, type)

    especificMonthObj            = nil
    actual_open_month            = self.get_actual_open_month
    actual_open_month_number     = Mes::Number.byLabel(actual_open_month)
    months_labels_array          = Mes::NUMBERS.keys

    first_null_month             = self.get_first_null_month

    only_months                  = self.detalle_periodo_fiscal.as_json.slice(*months_labels_array)
    are_all_month_equal          = only_months.values.uniq.length == 1 && only_months.values.uniq.first == params[:uniq_check_target]
    some_month_open              = only_months.values.select { | month | month == true }
    all_month_same               = only_months.values.uniq.length == 1

    if ( type == 'next' && some_month_open.empty? && !all_month_same ) || ( type != 'next' && !actual_open_month.nil? && ( actual_open_month_number >= params[:init_index] && actual_open_month_number <= params[:last_index] ) ) || ( params[:check_actual_null] && actual_open_month.nil? && are_all_month_equal ) || ( type != 'actual' && actual_open_month.nil? && !all_month_same )

      if params[:check_actual_null] && actual_open_month.nil? && are_all_month_equal
        actual_open_month_number = params[:uniq_check_index]
      end

      if !first_null_month.nil? && actual_open_month.nil? && !are_all_month_equal && ( type == 'next' || type == 'prev' )

        actual_open_month_number = ( Mes::Number.byLabel(first_null_month))
        actual_open_month_number -= 1 if type == 'next'
      end

      especificMonthObj          = { label: Mes::Label.byNumber( eval("#{actual_open_month_number} #{params[:operador]} #{params[:value_to_eval]}") ), number: ( eval("#{actual_open_month_number} #{params[:operador]} #{params[:value_to_eval]}") ) }
    end

    return especificMonthObj

  end
  # =========================================================================================================================================================

  def prev_month_open
    params = { :uniq_check_target =>  false, :init_index => 2, :last_index =>  12, :check_actual_null =>  true, :uniq_check_index =>  13, :operador =>  "-", :value_to_eval => 1 }
    return self.get_next_prev_actual_month(params, 'prev')
  end

  def actual_month_open
    params = { :uniq_check_target =>  false, :init_index => 1, :last_index =>  12, :check_actual_null =>  false, :uniq_check_index =>  0, :operador =>  "+", :value_to_eval => 0 }
    return self.get_next_prev_actual_month(params, 'actual')
  end

  def next_month_open
    params = { :uniq_check_target =>  nil, :init_index => 1, :last_index =>  11, :check_actual_null =>  true, :uniq_check_index =>  0, :operador =>  "+", :value_to_eval => 1 }
    return self.get_next_prev_actual_month(params, 'next')
  end

end


