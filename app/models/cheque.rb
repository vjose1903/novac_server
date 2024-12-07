class Cheque < ApplicationRecord
  belongs_to :cuenta_bancaria
  belongs_to :divisa

  has_many   :detalle_cheques

  belongs_to :user_creador,       class_name: 'User', optional: false
  belongs_to :last_user_update,   class_name: 'User', optional: true
  belongs_to :user_anulador,      class_name: 'User', optional: true

  validates :monto,             presence: { :message => "El monto del cheque no puede estar vacio." }, numericality: { greater_than: 0, :message => "La cantidad del monto del cheque debe de ser mayor a 0." }
  validates :fecha_equivalente, presence: { :message => "Debe de especificar una fecha para el cheque." }

  def self.models_includes
    includes = [
      :user_creador,
      :last_user_update,
      :user_anulador,
      { cuenta_bancaria: CuentaBancaria.models_includes },
    ]
    return includes
  end


  def self.manage_cheque( params )
    res                 = Response.new
    Cheque.transaction do

      cuenta_bancaria   = CuentaBancaria.find_by_id(params[:cuenta_bancaria_id])

      unless cuenta_bancaria.nil? || !cuenta_bancaria.estado

        cheque                          = Cheque.find_or_create_by(id: params[:id])

        cheque.user_creador_id          = get_current_user[:id]                          if (params[:id].nil?  || !params.has_key?(:id)) && cheque.id.nil?
        cheque.last_user_update_id      = get_current_user[:id]                          if (!params[:id].nil? || params.has_key?(:id)) && !cheque.id.nil?
        cheque.fecha_update             = DateTime.now                                   if (!params[:id].nil? || params.has_key?(:id)) && !cheque.id.nil? && !cheque.last_user_update_id.nil?
        cheque.cuenta_bancaria_id       = params[:cuenta_bancaria_id]                    if params.obj_has?(:cuenta_bancaria_id)
        cheque.divisa_id                = params[:divisa_id]                             if params.obj_has?(:divisa_id)
        cheque.monto                    = params[:monto]                                 if params.obj_has?(:monto)
        # TODO: ver que se hara para el balance desde el front
        cheque.balance                  = params[:balance]                               if params.obj_has?(:balance)
        cheque.comentario               = params[:comentario]                            if params.obj_has?(:comentario)
        cheque.fecha_equivalente        = params[:fecha_equivalente]                     if params.obj_has?(:fecha_equivalente)
        cheque.secuencia                = cuenta_bancaria.secuencia_documento.secuencia  if params[:id].nil? && cheque.id.nil?
        result_tasa                     = cheque.calculate_and_set_tasa

        cheque.valid?


        if result_tasa.status_valid && cheque.errors.empty?

          dependencies = [
            { modelo: DetalleCheque,         key_object: "detalle_cheques",           origin: cheque }
          ]

          res = crear_actualizar_dependencias(dependencies, params) { | key_object, dependency_data |
            cheque.detalle_cheques      = dependency_data if key_object == 'detalle_cheques'
          }

          if res.status_valid && cheque.save!

            result_procesos                        = cheque.procesos

            if result_procesos.status_valid
              res.set_data( cheque )
              action = params[:id] ? 'actualizado' : 'creado'
              res.add_msg("Cheque #{action} correctamente.")
            else
              res.add_msgs(result_procesos.get_msgs.to_a)
              res.set_status(HTTP_STATUS.conflict)
            end
          end
        end

        unless result_tasa.status_valid
          res.add_msgs(result_tasa.get_msgs.to_a)
          res.set_status(HTTP_STATUS.conflict)
        end

        res.manage_error_transaction(cheque)
      else

        res.add_msg("La cuenta bancaria que seleccionó para crear este depósito, no existe")          if cuenta_bancaria.nil?
        res.add_msg("La cuenta bancaria que seleccionó para crear este depósito, está deshabilitada.") if !cuenta_bancaria.nil? && !cuenta_bancaria.estado

        res.set_status(HTTP_STATUS.conflict)
      end

    end

    return res
  end

  # =========================================================================================================================================================

  def procesos
    res = self.cuenta_bancaria.secuencia_documento.aumentar_secuencia

    return res
  end

  # =========================================================================================================================================================

  def self.filtrarCheques(params, pagination_params)
    res    = Response.new(pagination_params)
    arg    = params[:arg]

    cheques = Cheque.joins('inner join cuentas_bancarias on cheques.cuenta_bancaria_id = cuentas_bancarias.id')
                    .where("lower( CONCAT(cheques.monto, ' ', cheques.comentario, ' ', cuentas_bancarias.numero_cuenta, ' ', cuentas_bancarias.descripcion) ) like lower('%#{arg}%') AND cheques.estado = '#{STATUS.active}'").order('cheques.id ASC').to_a

    if cheques.length > 0
      res.set_data(cheques, { all: true })
    else
      res.set_data([])
      cantidad_registros = Cheque.where({ estado: true }).count
      res.add_msg(cantidad_registros == 0 ? 'No existen cheques registrados.' : 'No existen cheques con las especificaciones introducidas')
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # =========================================================================================================================================================

  def calculate_and_set_tasa
    res                 = Response.new

    current_tasa        = self.divisa.getMontoTasa(self.fecha_equivalente)

    self.tasa           = current_tasa.valor
    self.monto_local    = self.monto.to_f * current_tasa.valor

    if ( self.tasa.nil? || !self.tasa.present? ) || ( self.monto_local.nil? || !self.monto_local.present? )
      res.add_msg("Error agregando la tasa de cambio de la divisa para este cheque, Por favor comunicarse con el soporte de Novac System.")
      res.set_status(HTTP_STATUS.conflict)
    end

    return res
  end

end
