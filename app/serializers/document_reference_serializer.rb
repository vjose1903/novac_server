class DocumentReferenceSerializer < ActiveModel::Serializer
  attribute :id,                    if: Proc.new { self.get_param('all') || has_to_show(self.get_param('id')) }
  attribute :document_origin,       if: Proc.new { self.get_param('all') || has_to_show(self.get_param('document_origin')) }
  attribute :document_referenced,   if: Proc.new { self.get_param('all') || has_to_show(self.get_param('document_referenced')) }
  attribute :referenced_by,         if: Proc.new { self.get_param('all') || has_to_show(self.get_param('referenced_by')) }
  attribute :referenced_at,         if: Proc.new { self.get_param('all') || has_to_show(self.get_param('referenced_at')) }


  def document_origin
    optional_params = parse_serialize_optional_params(self.get_param('document_origin'), { all: false, id: true, numero_comprobante: true })
    serialize_parser(object.document_origin, optional_params)
  end

  def document_referenced
    optional_params = parse_serialize_optional_params(self.get_param('document_referenced'), { all: false, id: true, numero_comprobante: true })
    serialize_parser(object.document_referenced, optional_params)
  end

  def referenced_by
    optional_params = parse_serialize_optional_params(self.get_param('referenced_by'), { all: false, id: true, nombre_completo: true })
    serialize_parser(object.referenced_by, optional_params)
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
