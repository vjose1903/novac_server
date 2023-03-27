class CabezaAsientoContable < ApplicationRecord
  belongs_to :usuario_creador,  class_name: 'User'
  belongs_to :usuario_anulador, class_name: 'User', optional: true
  belongs_to :periodo_fiscal

  validates :fecha_equivalente, presence: { :message => "Debe de especificar una fecha valida para la entrada de diario." }
  has_many  :detalles_asientos_contables, dependent: :destroy

  def self.validate_params(params)

    begin
      res               = Response.new
      current_periodo   = PeriodoFiscal.get_open_period
      fecha_equivalente = Date.parse(params[:fecha_equivalente])

      unless current_periodo.nil?
        is_open_month   = PeriodoFiscal.is_open_month(params[:fecha_equivalente])

        unless is_open_month
          action = params[:id] ? 'actualizar' : 'realizar'
          res.add_msg("El mes: #{Mes::Label.byNumber(fecha_equivalente.month)}, está cerrado, para #{action} esta entrada de diario debe de abrirlo.")
        end

      else
        res.add_msg("Para realizar una entrada de diario, debe de existir un periodo fiscal abierto")
      end

    rescue
      res.add_msg("La fecha introducida, no es valida.")
    end

    res.set_status(HTTP_STATUS_CODE[:conflict]) unless res.get_msgs.empty?

    return res
  end

  def self.create_update_asiento_contable(params)
    res = Response.new
    CabezaAsientoContable.transaction do

      resultado_can_make        = CabezaAsientoContable.validate_params(params)

      if resultado_can_make.status_valid
        cabeza_asiento_contable = CabezaAsientoContable.where(id: params[:id]).first_or_create

        cabeza_asiento_contable.usuario_creador_id     = get_current_user[:id]
        cabeza_asiento_contable.periodo_fiscal_id      = params[:periodo_fiscal_id]
        cabeza_asiento_contable.comentario             = params[:comentario]
        cabeza_asiento_contable.tipo                   = AsientoContable.manual
        cabeza_asiento_contable.fecha_equivalente      = params[:fecha_equivalente]

        cabeza_asiento_contable.valid?

        if cabeza_asiento_contable.errors.empty?

          dependencias = [{modelo: DetalleAsientoContable, key_object: "detalles_asientos_contables", padre: cabeza_asiento_contable }]

          res = crear_actualizar_dependencias(dependencias, params, true) { | key_object, dependencia_data |
            cabeza_asiento_contable.detalles_asientos_contables = dependencia_data if key_object == 'detalles_asientos_contables'
          }

          if res.status_valid && cabeza_asiento_contable.save!
            res.set_data(cabeza_asiento_contable)

            action = params[:id] ? 'actualizado' : 'creado'
            res.add_msg("Asiento Contable #{action} correctamente.")
          end

        else
          res.add_msgs(cabeza_asiento_contable.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res = resultado_can_make
      end

    end
    return res
  end

end
