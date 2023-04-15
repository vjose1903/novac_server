class ClienteSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('id')                        || self.get_param('all') }
  attribute :nombre,                             if: Proc.new { self.get_param('nombre')                    || self.get_param('all') }
  attribute :estado,                             if: Proc.new { self.get_param('estado')                    || self.get_param('all') }
  attribute :apellido,                           if: Proc.new { self.get_param('apellido')                  || self.get_param('all') }
  attribute :limite_credito,                     if: Proc.new { self.get_param('limite_credito')            || self.get_param('all') }
  attribute :telefono,                           if: Proc.new { self.get_param('telefono')                  || self.get_param('all') }
  attribute :direccion,                          if: Proc.new { self.get_param('direccion')                 || self.get_param('all') }
  attribute :sexo,                               if: Proc.new { self.get_param('sexo')                      || self.get_param('all') }
  attribute :maximo_credito,                     if: Proc.new { self.get_param('maximo_credito')            || self.get_param('all') }
  attribute :vendedor_id,                        if: Proc.new { self.get_param('vendedor_id')               || self.get_param('all') }
  attribute :balance,                            if: Proc.new { self.get_param('balance')                   || self.get_param('all') }
  attribute :vendedor,                           if: Proc.new { self.get_param('vendedor')                  || self.get_param('all') }
  attribute :nombre_completo

  attribute :documentos_de_identidad,            if: Proc.new { self.get_param('documentos_de_identidad')   || self.get_param('all') }
  attribute :cuentas_contables,                  if: Proc.new { self.get_param('cuentas_contables')         || self.get_param('all') }

  def vendedor
    vendedor = User.find_by_id(object.vendedor_id)
    serialize_parser(vendedor, {nombre: true, apellido: true, vendedor_id: true })
  end

  def nombre_completo
    vendedor = object.nombre_completo
  end

  def documentos_de_identidad
    serialize_parser(object.documentos_de_identidad, { all: true })
  end

  def cuentas_contables
    serialize_parser(object.entidad_cuentas_contables, { id: true, key: true, tipo_agrupacion_contable: true, cuenta_contable: true, origen_categoria: true })
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
