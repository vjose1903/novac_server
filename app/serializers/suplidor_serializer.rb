class SuplidorSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { has_to_show(self.get_param('all') || self.get_param('id')) }
  attribute :nombre,                        if: Proc.new { has_to_show(self.get_param('all') || self.get_param('nombre')) }
  attribute :telefono,                      if: Proc.new { has_to_show(self.get_param('all') || self.get_param('telefono')) }
  attribute :direccion,                     if: Proc.new { has_to_show(self.get_param('all') || self.get_param('direccion')) }
  attribute :email,                         if: Proc.new { has_to_show(self.get_param('all') || self.get_param('email')) }
  attribute :estado,                        if: Proc.new { has_to_show(self.get_param('all') || self.get_param('estado')) }

  attribute :nombre_completo,               if: Proc.new { has_to_show(self.get_param('all') || self.get_param('nombre_completo')) }
  attribute :documentos_de_identidad,       if: Proc.new { has_to_show(self.get_param('all') || self.get_param('documentos_de_identidad')) }
  attribute :cuentas_contables,             if: Proc.new { self.get_param('cuentas_contables')           || self.get_param('all') }
	attribute :divisa,                        if: Proc.new { self.get_param('divisa')                      || self.get_param('all') }

  def nombre_completo
    object.nombre_completo
  end

  def documentos_de_identidad
    optional_params = parse_serialize_optional_params(self.get_param('documentos_de_identidad'), { all: false, id: true, descripcion: true, documento: true, principal: true  })
    serialize_parser(object.documentos_de_identidad, optional_params)
  end

  def cuentas_contables
		serialize_parser(object.entidad_cuentas_contables, { id: true, key: true, tipo_agrupacion_contable: true, cuenta_contable: true, is_comun: true, origen_categoria: true, configuracion_entidad_cuenta_id: true })
  end

	def divisa
    serialize_parser(object.divisa, { id: true, nombre: true, imagen: true })
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
