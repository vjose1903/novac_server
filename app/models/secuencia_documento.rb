class SecuenciaDocumento < ApplicationRecord
  belongs_to :origen_secuencia, polymorphic: true


  def next_secuencia
    object = self.dup
    object.secuencia += 1
  end
  # =========================================================================================================================================================

  def self.manage_secuencia(params, origin, is_save = false)
    res       = Response.new
    SecuenciaDocumento.transaction do
      secuencia_documento                           = SecuenciaDocumento.find_or_create_by(id: params[:id])

      secuencia_documento.secuencia                  = params[:secuencia]                 if params.obj_has?(:secuencia)
      secuencia_documento.origen_secuencia           = origin                             unless is_empty?(origin)

      secuencia_documento.valid?

      if secuencia_documento.errors.empty? && (!is_save || (is_save && secuencia_documento.save!))
        res.set_data(secuencia_documento)
      end

      res.manage_error_transaction(secuencia_documento)
    end

    return res
  end

  # =========================================================================================================================================================

  def aumentar_secuencia
    res               = Response.new

    SecuenciaDocumento.transaction do
      self.secuencia = self.next_secuencia
      self.valid?

      res.manage_error_transaction(self)
    end

    return res
  end

  # =========================================================================================================================================================

  def self.models_includes
    includes = [:origin_identity]
    return includes
  end

  # =========================================================================================================================================================
  def self.validar_e_inicializar(items, origin)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
      res_temp = self.manage_secuencia(item, origin, !item[:id].nil?)
      if res_temp.status_valid
        array_valid.push(res_temp.get_data)
      else
        return res_temp
      end
      res_valid.set_data array_valid
    end
    return res_valid
  end
end
