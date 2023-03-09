class PeriodoFiscal < ApplicationRecord
  has_many :detalles_periodos_fiscales

  validates :fecha_inicio, presence: { :message => "Debe de especificar una fecha de inicio para el periodo fiscal." }
  validates :fecha_cierre, presence: { :message => "Debe de especificar una fecha de cierre para el periodo fiscal." }

  # ============================================================================================================================================

  def self.create_update_periodo_fiscal(params, is_save=false)
    res                                = Response.new
    PeriodoFiscal.transaction do

      periodo_fiscal                   = PeriodoFiscal.where(:id => params["id"]).first_or_create

      periodo_fiscal.fecha_inicio      = params[:fecha_inicio]
      periodo_fiscal.fecha_cierre      = params[:fecha_cierre]

      periodo_fiscal.valid?

      if periodo_fiscal.errors.empty?

        res = periodo_fiscal.add_detalles(params)

        if res.status_valid && periodo_fiscal.save!
          res.set_data(serialize_parser(periodo_fiscal, {all:true}))

          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Periodo Fiscal #{action} correctamente.")
        end
      end

      unless periodo_fiscal.errors.empty?
        res.add_msgs(periodo_fiscal.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !periodo_fiscal.errors.empty? || !res.status_valid
    end

    return res
  end

  # ============================================================================================================================================

  def add_detalles(params)

    PeriodoFiscal.create_first_detalle_periodo(params, self) if self.id.nil?

    dependencias = [{modelo: DetallePeriodoFiscal, key_object: "detalles_periodos_fiscales", padre: self }]

    res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
      self.detalles_periodos_fiscales = dependencia_data if key_object == 'detalles_periodos_fiscales'
    }

    return res
  end

  # ============================================================================================================================================

  def self.create_first_detalle_periodo(params, periodo_fiscal)

    detalle                                                     = {}

    Mes.labels.keys.each do | month_number |
      current_month_number                                      = month_number.to_s.gsub("_", "").strip
      detalle[:"#{Mes::Label.byNumber(current_month_number)}"]  = current_month_number.to_i == periodo_fiscal.fecha_inicio.month
    end

    params["detalles_periodos_fiscales"]                        = [ detalle ]
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
        new_periodo_fiscal.estado           = true
        res                                 = new_periodo_fiscal.add_detalles(params)

        last_periodo_fiscal.estado          = false

        if res.status_valid && ((new_periodo_fiscal.errors.empty? && new_periodo_fiscal.save!) && (last_periodo_fiscal.errors.empty? && last_periodo_fiscal.save!))
          res.set_data(serialize_parser(new_periodo_fiscal, {all:true}))
          res.add_msg("Periodo Fiscal: #{formatearFecha(new_periodo_fiscal.fecha_inicio.to_s, TipoFecha.sin_hora)} - #{formatearFecha(new_periodo_fiscal.fecha_cierre.to_s, TipoFecha.sin_hora)} abierto correctamente.")
        else
          res.add_msgs(last_periodo_fiscal.errors.to_a)
          res.add_msgs(new_periodo_fiscal.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        raise ActiveRecord::Rollback if (!new_periodo_fiscal.errors.empty? || !last_periodo_fiscal.errors.empty?) || !res.status_valid

      else
        res.add_msg("Para abrir un nuevo periodo fiscal primero debe de registrar el primer periodo")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

end


