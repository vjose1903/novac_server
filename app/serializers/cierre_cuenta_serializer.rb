class CierreCuentaSerializer < ActiveModel::Serializer
  attributes :id, :enero, :enero_debito, :enero_credito, :febrero, :febrero_debito, :febrero_credito, :marzo, :marzo_debito, :marzo_credito, :abril, :abril_debito, :abril_credito, :mayo, :mayo_debito, :mayo_credito, :junio, :junio_debito, :junio_credito, :julio, :julio_debito, :julio_credito, :agosto, :agosto_debito, :agosto_credito, :septiembre, :septiembre_debito, :septiembre_credito, :octubre, :octubre_debito, :octubre_credito, :noviembre, :noviembre_debito, :noviembre_credito, :diciembre, :diciembre_debito, :diciembre_credito, :total_anual
  has_one :periodo_fiscal
  has_one :cuenta_contable
end
