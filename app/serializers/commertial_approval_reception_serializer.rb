class CommertialApprovalReceptionSerializer < ActiveModel::Serializer
  attribute :id,                      if: Proc.new { has_to_show(self.get_param('id'))                     || self.get_param('all') }
  attribute :eNCF,                    if: Proc.new { has_to_show(self.get_param('eNCF'))                   || self.get_param('all') }
  attribute :rnc_emisor,              if: Proc.new { has_to_show(self.get_param('rnc_emisor'))             || self.get_param('all') }
  attribute :rnc_comprador,           if: Proc.new { has_to_show(self.get_param('rnc_comprador'))          || self.get_param('all') }
  attribute :monto_total,             if: Proc.new { has_to_show(self.get_param('monto_total'))            || self.get_param('all') }
  attribute :estado,                  if: Proc.new { has_to_show(self.get_param('estado'))                 || self.get_param('all') }
  attribute :detalleMotivoRechazo,    if: Proc.new { has_to_show(self.get_param('detalleMotivoRechazo'))   || self.get_param('all') }
  attribute :cabecera_factura_id,     if: Proc.new { has_to_show(self.get_param('cabecera_factura_id'))    || self.get_param('all') }
  attribute :cabecera_factura,        if: Proc.new { has_to_show(self.get_param('cabecera_factura')) }
  attribute :suplidor_id,             if: Proc.new { has_to_show(self.get_param('suplidor_id'))            || self.get_param('all') }
  attribute :suplidor,                if: Proc.new { has_to_show(self.get_param('suplidor')) }

  def rnc_emisor
    format_rnc(object.rnc_emisor)
  end

  def rnc_comprador
    format_rnc(object.rnc_comprador)
  end

  def cabecera_factura
    optional_params = parse_serialize_optional_params(self.get_param('cabecera_factura'), { all: false, id: true, numero_comprobante: true  })
    serialize_parser(object.cabecera_factura, optional_params)
  end

  def suplidor
    optional_params = parse_serialize_optional_params(self.get_param('suplidor'), { all: false, id: true, nombre: true  })
    serialize_parser(object.suplidor, optional_params)
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
