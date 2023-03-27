class TasaCambio < ApplicationRecord
  belongs_to :divisa


  # ============================================================================================================================================

  def self.create_tasa_cambio(params, divisa, is_save)
    res      = Response.new

    TasaCambio.transaction do
      divisa = Divisa.find_by_id( params[:divisa_id] ) if divisa.nil?

      unless divisa.nil?
        tasa_cambio                    = TasaCambio.where(:id => params[:id]).first_or_create


        tasa_cambio.valor              = params[:valor]              unless params[:valor].nil?
        tasa_cambio.divisa_id          = params[:divisa_id]          unless params[:divisa_id].nil?
        tasa_cambio.fecha_equivalente  = params[:fecha_equivalente]  unless params[:fecha_equivalente].nil?
        tasa_cambio.user_id            = get_current_user[:id]

        tasa_cambio.valor              = 1 if tasa_cambio.divisa.is_principal

        tasa_cambio.valid?

        if tasa_cambio.errors.empty? && (!is_save || (is_save && tasa_cambio.save!))

          res.set_data(tasa_cambio)
          action = params[:id] ? 'actualizada' : 'creada'
          res.add_msg("Tasa de Cambio #{action} correctamente.")

        end

        unless tasa_cambio.errors.empty?
          res.add_msgs(tasa_cambio.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

        transaction_rollback if !tasa_cambio.errors.empty? || !res.status_valid
      else
        res.add_msg("Para crear una tasa de cambio debe de seleccionar la divisa correspondiente.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

    end
    return res
  end

  # ============================================================================================================================================

  def self.update_tasa_cambio(params)
    res             = Response.new

    if Date.parse(params[:fecha_equivalente]).beginning_of_day > Date.today.beginning_of_day
      res.add_msg('No puede modificar la tasa de cambio de una divisa, en un día posterior al día actual.')
      res.set_status(HTTP_STATUS_CODE[:conflict])
      return res
    end

    TasaCambio.transaction do
      tasas                 = []

      start_date            = Date.new(Date.parse(params[:fecha_equivalente]).year, 1, 1)
      end_date              = Date.new(Date.parse(params[:fecha_equivalente]).year, 12, 31)

      is_today_change       = Date.parse(params[:fecha_equivalente]) == Date.today

      all_tasas             = TasaCambio.where("fecha_equivalente between '#{start_date}' AND '#{end_date}'").order("id ASC")
      is_the_first_change   = all_tasas.all? { | tasa | tasa.valor == 0 }

      tasa_en_turno         = TasaCambio.where({ fecha_equivalente: Date.parse(params[:fecha_equivalente]).beginning_of_day..Date.parse(params[:fecha_equivalente]).end_of_day}).first unless is_today_change

      where_clause          = is_today_change || is_the_first_change ? "fecha_equivalente >= '#{params[:fecha_equivalente]}'" : "secuencia = #{tasa_en_turno.secuencia}"
      tasas                 = TasaCambio.where("#{where_clause} AND (fecha_equivalente between '#{start_date}' AND '#{end_date}')").order("id ASC")


      tasas.each do | tasa |
        tasa.valor             = params[:valor]
        tasa.last_user_update  = get_current_user[:id]
        tasa.secuencia         = (tasa.secuencia + 1) if is_today_change || is_the_first_change
        tasa.save!
      end


      res.add_msg('Tasa de Cambio modificada correctamente.')
    end
    return res
  end

  # ============================================================================================================================================

  def self.create_year_tasa_cambio(divisa)

    res_valid   = Response.new
    array_valid = []

    start_date  = Date.new(Date.today.year, 1, 1)
    end_date    = Date.new(Date.today.year, 12, 31)

    (start_date..end_date).each do | date |
      new_tasa_cambio = { divisa_id: divisa.id, valor: 0, fecha_equivalente: formatearFecha(date.to_s, TipoFecha.sin_hora) }.with_indifferent_access
      resultado       = TasaCambio.create_tasa_cambio(new_tasa_cambio, divisa, true)

      if resultado.status_valid
        array_valid.push(resultado.get_data)
      else
        return resultado
      end

    end
    res_valid.set_data array_valid
    return res_valid

  end

  # ============================================================================================================================================

  def self.get_history_changes(params)
    res             = Response.new

    desde           = Date.parse(params[:desde])
    hasta           = Date.parse(params[:hasta])

    ids             = TasaCambio.select('MIN(id) as id').where("divisa_id = #{params[:divisa_id]} AND valor > 0 AND (fecha_equivalente between '#{desde}' AND '#{hasta}')").group('secuencia').to_a
    tasas_de_cambio = TasaCambio.where({id: ids}).order('secuencia ASC')

    res.set_data(serialize_parser(tasas_de_cambio, {all: true}))

    return res
  end
end
