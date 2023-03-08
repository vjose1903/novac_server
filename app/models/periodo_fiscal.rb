class PeriodoFiscal < ApplicationRecord
  has_many :detalles_periodos_fiscales, dependent: :destro

	validates :fecha_inicio, presence: { :message => "Debe de especificar una fecha de inicio para el periodo fiscal." }
	validates :fecha_cierre, presence: { :message => "Debe de especificar una fecha de cierre para el periodo fiscal." }

  # ============================================================================================================================================

  def self.create_update_suplidor(params , is_save=false)
    res                          = Response.new
    PeriodoFiscal.transaction do

      periodo_fiscal                   = PeriodoFiscal.where(:id => params["id"]).first_or_create

      periodo_fiscal.fecha_inicio      = params["fecha_inicio"]
      periodo_fiscal.fecha_cierre      = params["fecha_cierre"]


      if periodo_fiscal.errors.empty?
        dependencias = [{modelo: DocumentoDeIdentidad, key_object: "detalles_periodos_fiscales", padre: periodo_fiscal }]

        res = crear_actualizar_dependencias(dependencias, params, true) { |key_object, dependencia_data|
          periodo_fiscal.detalles_periodos_fiscales = dependencia_data if key_object == 'detalles_periodos_fiscales'
        }

        if res.status_valid && periodo_fiscal.save!
          res.set_data(serialize_parser(periodo_fiscal,{all:true}))

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
	def self.create_detalle_periodo
	end
  # ============================================================================================================================================
end
