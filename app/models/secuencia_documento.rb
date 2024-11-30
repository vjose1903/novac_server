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
      secuencia_documento.errors.delete(:origen_secuencia) if !is_save

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

      unless self.save!
        res.manage_error_transaction(self)
      end

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
    item = items[0]
    res  = manage_secuencia(item, origin, !item[:id].nil?)
    return res
  end
end
