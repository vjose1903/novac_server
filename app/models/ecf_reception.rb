class EcfReception < ApplicationRecord
    belongs_to :suplidor, optional: true

    validates :eNCF,            presence: { :message => 'Debe de especificar la secuencia del comprobante electrónico.' }, length: { is: 13, message: "el Ecf debe de tener 13 caracteres" }
    validates :rnc_comprador,   presence: { :message => "Debe de especificar el RNC del comprador" }
    validates :rnc_emisor,      presence: { :message => "Debe de especificar el RNC del emisor" }
    validates :monto_total,     presence: { :message => 'Debe de especificar el monto total' }
    validates :fecha_emision,   presence: { :message => 'Debe de especificar la fecha de emisión' }

  def self.create_new(params, is_save=false)
    res = Response.new

    ecf_reception                = EcfReception.where(:id => params[:id]).first_or_initialize

    ecf_reception.eNCF           = params[:eNCF]           if params.obj_has?(:eNCF)
    ecf_reception.rnc_emisor     = params[:rnc_emisor]     if params.obj_has?(:rnc_emisor)
    ecf_reception.rnc_comprador  = params[:rnc_comprador]  if params.obj_has?(:rnc_comprador)
    ecf_reception.monto_total    = params[:monto_total]    if params.obj_has?(:monto_total)
    ecf_reception.fecha_emision  = params[:fecha_emision]  if params.obj_has?(:fecha_emision)
    ecf_reception.xml_file_name  = "#{params[:rnc_comprador]}#{params[:eNCF]}.xml"

    if ecf_reception.rnc_emisor.present?
      documento_identidad    = DocumentoDeIdentidad.where("REPLACE(documento, '-', '') = '#{ecf_reception.rnc_emisor}' AND suplidor_id IS NOT NULL").first
      ecf_reception.suplidor = documento_identidad.suplidor if documento_identidad.present?
    end

    ecf_reception.valid?
    ecf_reception.errors.delete(:suplidor) unless is_save
    
    if ecf_reception.errors.empty? && (!is_save || (is_save && ecf_reception.save!))
      res.set_data(ecf_reception)
    else
      res.add_msgs(ecf_reception.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
