class CierreCuentaSerializer < ActiveModel::Serializer
end

class CierreCuentaSerializer
  extend FastSerializer
  extend ActiveModelSerializerFastAdapter

  def self.default_fields
    [:id, :enero, :enero_debito, :enero_credito, :febrero, :febrero_debito, :febrero_credito, :marzo, :marzo_debito, :marzo_credito, :abril, :abril_debito, :abril_credito, :mayo, :mayo_debito, :mayo_credito, :junio, :junio_debito, :junio_credito, :julio, :julio_debito, :julio_credito, :agosto, :agosto_debito, :agosto_credito, :septiembre, :septiembre_debito, :septiembre_credito, :octubre, :octubre_debito, :octubre_credito, :noviembre, :noviembre_debito, :noviembre_credito, :diciembre, :diciembre_debito, :diciembre_credito, :total_anual, :periodo_fiscal, :cuenta_contable]
  end

  def periodo_fiscal
    PeriodoFiscalSerializer.to_hash(object.periodo_fiscal, { all: true })
  end

  def cuenta_contable
    CuentaContableSerializer.to_hash(object.cuenta_contable, { all: true })
  end
end
