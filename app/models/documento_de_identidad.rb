class DocumentoDeIdentidad < ApplicationRecord
  self.table_name = "documentos_de_identidad"
  belongs_to :user, optional: true
  belongs_to :cliente, optional: true
  belongs_to :suplidor, optional: true

  belongs_to :origen, polymorphic: true

  validates :documento, uniqueness: { :allow_blank => true, scope: :origen_type, case_sensitive: false, :message => "Documento de identidad ya está registrado" }, :if => :documento


  def self.crear_actualizar_documento(params, padre, is_save=false)
    res = Response.new
    documento                = DocumentoDeIdentidad.where(:id => params[:id]).first_or_create

    documento.descripcion    = params[:descripcion]
    documento.documento      = params[:documento]
    documento.principal      = params[:principal]
    documento.origen         = padre

    documento.valid?

    if documento.errors.empty? && (!is_save || (is_save && documento.save!))
      res.set_data(documento)
    else
      res.add_msgs(documento.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  def self.validar_e_inicializar(items, padre, save)
    res_valid = Response.new
    array_valid=[]

    items.each do |item|
    unless item[:documento].blank?
        res_temp = self.crear_actualizar_documento(item, padre, save)

        if res_temp.status_valid
          array_valid.push(res_temp.get_data)
        else
          return res_temp
        end

      end
    end

    res_valid.set_data array_valid
    return res_valid
  end

end
