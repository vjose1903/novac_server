class CabezaAsientoContable < ApplicationRecord
  belongs_to :usuario_creador,  class_name: 'User'
  belongs_to :usuario_anulador, class_name: 'User', optional: true
  belongs_to :periodo_fiscal

  validates :fecha_equivalente, presence: { :message => "Debe de especificar una fecha valida para la entrada de diario." }
  has_many  :detalles_asientos_contables, dependent: :destroy

  # ============================================================================================================================================
  def self.validate_params(params)

    begin
      res               = Response.new
      current_periodo   = PeriodoFiscal.get_open_period
      fecha_equivalente = Date.parse(params[:fecha_equivalente])

      unless current_periodo.nil?
        is_open_month   = PeriodoFiscal.is_open_month(params[:fecha_equivalente])

        if is_open_month
          res.set_data(current_periodo)
        else
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

  # ===================================================================================================================================================

  def self.models_includes
    user_includes   = [:documentos_de_identidad ]
    includes = [
                 { usuario_creador: user_includes },
                 { usuario_anulador: user_includes },
                 { detalles_asientos_contables: DetalleAsientoContable.models_includes },
                 { periodo_fiscal: PeriodoFiscal.models_includes },
    ]
    return includes
  end

  # ============================================================================================================================================
  def self.create_update_asiento_contable(params)
    res = Response.new
    CabezaAsientoContable.transaction do

      resultado_can_make        = CabezaAsientoContable.validate_params(params)
      current_periodo_fiscal    = resultado_can_make.get_data

      if resultado_can_make.status_valid
        cabeza_asiento_contable = CabezaAsientoContable.where(id: params[:id]).first_or_create

        cabeza_asiento_contable.usuario_creador_id     = get_current_user[:id]
        cabeza_asiento_contable.periodo_fiscal_id      = current_periodo_fiscal.id
        cabeza_asiento_contable.comentario             = params[:comentario]
        cabeza_asiento_contable.tipo                   = params.has_key?(:tipo) && !params[:tipo].nil? ? params[:tipo] : AsientoContable.manual
        cabeza_asiento_contable.fecha_equivalente      = params[:fecha_equivalente]
        cabeza_asiento_contable.get_sequence

        cabeza_asiento_contable.valid?

        if cabeza_asiento_contable.errors.empty?

          dependencias = [{modelo: DetalleAsientoContable, key_object: "detalles_asientos_contables", padre: cabeza_asiento_contable }]

          res = crear_actualizar_dependencias(dependencias, params) { | key_object, dependencia_data |
            cabeza_asiento_contable.detalles_asientos_contables = dependencia_data if key_object == 'detalles_asientos_contables'
          }

          cabeza_asiento_contable.validate_detalles_amount


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

  # ============================================================================================================================================
  def get_sequence
    fecha_equivalente = self.fecha_equivalente
    start_date = fecha_equivalente.beginning_of_month
    end_date   = fecha_equivalente.end_of_month

    next_secuence = CabezaAsientoContable.where(fecha_equivalente: start_date..end_date).count + 1

    year          = self.fecha_equivalente.year
    month         = self.fecha_equivalente.month



    self.codigo = "ED-#{year}-#{"%02d" % month}-#{"%03d" % next_secuence}"
  end

  # ============================================================================================================================================
  def validate_detalles_amount
    detalles_debito  = self.detalles_asientos_contables.filter { | detalle | detalle.valor_credito.nil? && detalle.valor_debito.is_number? }
    detalles_credito = self.detalles_asientos_contables.filter { | detalle | detalle.valor_debito.nil? && detalle.valor_credito.is_number? }

    total_debito     = detalles_debito.reduce(0) { | acu, item |  item.valor_debito + acu }
    total_credito    = detalles_credito.reduce(0) { | acu, item |  item.valor_credito + acu }


    self.is_validated = total_credito == total_debito
  end

  # ============================================================================================================================================

  def self.filtrarAsientos(params, pagination_params)
    res = Response.new(pagination_params)
    query         = {}
    is_validated  = params[:is_validated]
    arg           = params[:arg]
    desde         = params[:desde]
    hasta         = params[:hasta].nil? ? params[:desde] : params[:hasta]

    query['fecha_equivalente'] = (Date.parse desde).beginning_of_day..(Date.parse hasta).end_of_day
    query['is_validated'] = is_validated.to_boolean unless is_validated.nil?

    asientos = CabezaAsientoContable
                 .where(query)
                 .where("lower(cabezas_asientos_contables.comentario || ' ' || cabezas_asientos_contables.codigo) like lower('%#{arg}%')  AND cabezas_asientos_contables.estado = true")
                 .order('cabezas_asientos_contables.id ASC').to_a

    if asientos.length > 0
      res.set_data(asientos, {all: true})
    else
      res.set_data([])
      cantidad_registros = CabezaAsientoContable.where({estado: true}).count
      res.add_msg(cantidad_registros == 0 ? 'No existen entradas de diario registradas.' : 'No existe entrada de diario con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
