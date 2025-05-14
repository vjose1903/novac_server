class CommertialApprovalReception < ApplicationRecord
  belongs_to :cabecera_factura, optional: true

  validates :eNCF,            presence: { :message => 'Debe de especificar la secuencia del comprobante electrónico.' }, length: { is: 13, message: "el Ecf debe de tener 13 caracteres" }
  validates :rnc_comprador,   presence: { :message => "Debe de especificar el RNC del comprador" }
  validates :rnc_emisor,      presence: { :message => "Debe de especificar el RNC del emisor" }
  validates :monto_total,     presence: { :message => 'Debe de especificar el monto total' }
  validates :fecha_emision,   presence: { :message => 'Debe de especificar la fecha de emisión' }

  def self.create_new(params, is_save=false)
    res = Response.new
    commertial_approval                       = CommertialApprovalReception.new

    commertial_approval.eNCF                  = params[:eNCF]                  if params.obj_has?(:eNCF)
    commertial_approval.rnc_emisor            = params[:rnc_emisor]            if params.obj_has?(:rnc_emisor)
    commertial_approval.rnc_comprador         = params[:rnc_comprador]         if params.obj_has?(:rnc_comprador)
    commertial_approval.monto_total           = params[:monto_total]           if params.obj_has?(:monto_total)
    commertial_approval.fecha_emision         = params[:fecha_emision]         if params.obj_has?(:fecha_emision)
    commertial_approval.detalleMotivoRechazo  = params[:detalleMotivoRechazo]  if params.obj_has?(:detalleMotivoRechazo)
    commertial_approval.estado                = params[:estado]                if params.obj_has?(:estado)
    commertial_approval.xml_file_name         = "#{params[:rnc_comprador]}#{params[:eNCF]}.xml"

    if commertial_approval.eNCF.present?
      cabecera_factura    = CabeceraFactura.where("numero_comprobante='#{commertial_approval.eNCF}' AND tipo='venta'").first
      commertial_approval.cabecera_factura = cabecera_factura if cabecera_factura.present?
    end

    commertial_approval.valid?
    commertial_approval.errors.delete(:cabecera_factura) unless is_save
    
    if commertial_approval.errors.empty? && (!is_save || (is_save && commertial_approval.save!))
      res.set_data(commertial_approval)
    else
      res.add_msgs(commertial_approval.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end
end
