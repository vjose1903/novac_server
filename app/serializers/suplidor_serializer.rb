class SuplidorSerializer < ActiveModel::Serializer

  attribute :id,                            if: Proc.new { self.get_param('id')                          || self.get_param('all') }
  attribute :nombre,                        if: Proc.new { self.get_param('nombre')                      || self.get_param('all') }
  attribute :telefono,                      if: Proc.new { self.get_param('telefono')                    || self.get_param('all') }
  attribute :direccion,                     if: Proc.new { self.get_param('direccion')                   || self.get_param('all') }
  attribute :email,                         if: Proc.new { self.get_param('email')                       || self.get_param('all') }
  attribute :estado,                        if: Proc.new { self.get_param('estado')                      || self.get_param('all') }
  attribute :nombre_completo

  attribute :documentos_de_identidad,       if: Proc.new { self.get_param('documentos_de_identidad')     || self.get_param('all') }
  attribute :cuentas_contables,             if: Proc.new { self.get_param('cuentas_contables')           || self.get_param('all') }


  def nombre_completo
    vendedor = object.nombre_completo
  end

  def documentos_de_identidad
    serialize_parser(object.documentos_de_identidad, { descripcion: true, documento: true, principal: true })
  end

  def cuentas_contables
		serialize_parser(object.entidad_cuentas_contables, { id: true, key: true, tipo_agrupacion_contable: true, cuenta_contable: true, is_comun: true, origen_categoria: true, configuracion_entidad_cuenta_id: true })
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
