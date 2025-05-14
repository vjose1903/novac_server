class CommertialApprovalReceptionSerializer < ActiveModel::Serializer
  attributes :id, :eNCF, :rnc_emisor, :rnc_comprador, :monto_total, :estado, :detalleMotivoRechazo
  has_one :cabecera_factura
end
