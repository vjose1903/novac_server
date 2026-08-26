class ClienteSerializer < ActiveModel::Serializer
  attribute :id,                                 if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('id'))}
  attribute :imagen_id,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('imagen_id'))}
  attribute :nombre,                             if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('nombre'))}
  attribute :estado,                             if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('estado'))}
  attribute :apellido,                           if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('apellido'))}
  attribute :limite_credito,                     if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('limite_credito'))}
  attribute :telefono,                           if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('telefono'))}
  attribute :direccion,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('direccion'))}
  attribute :sexo,                               if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('sexo'))}
  attribute :maximo_credito,                     if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('maximo_credito'))}
  attribute :vendedor_id,                        if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('vendedor_id'))}
  attribute :balance,                            if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('balance'))}
  attribute :municipio_id,                       if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('municipio_id'))}

  attribute :vendedor,                           if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('vendedor'))}
  attribute :nombre_completo
  attribute :documentos_de_identidad,            if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('documentos_de_identidad'))}
  attribute :provincia_id,                       if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('provincia_id'))}
  attribute :provincia,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('provincia'))}
  attribute :municipio,                          if: Proc.new { self.get_param('all') ||  has_to_show(self.get_param('municipio'))}


  def vendedor
    vendedor = object.vendedor
    return nil unless vendedor

    {
      nombre: vendedor.nombre.capitalize,
      apellido: vendedor.apellido.capitalize,
      vendedor_id: vendedor.id,
      nombre_completo: vendedor.nombre_completo
    }
  end

  def nombre_completo
    vendedor = object.nombre_completo
  end

  def documentos_de_identidad
    object.documentos_de_identidad.map do |documento|
      select_cliente_fields({
        id: documento.id,
        descripcion: documento.descripcion,
        documento: documento.documento,
        principal: documento.principal
      }, self.get_param('documentos_de_identidad'), { id: true, descripcion: true, documento: true, principal: true })
    end
  end

  def provincia_id
    object.provincia&.id
  end

  def provincia
    provincia = object.provincia
    return nil unless provincia

    select_cliente_fields({
      id: provincia.id,
      nombre: provincia.nombre,
      codigo: provincia.codigo
    }, self.get_param('provincia'), { id: true, nombre: true, codigo: true })
  end

  def municipio
    municipio = object.municipio
    return nil unless municipio

    select_cliente_fields({
      id: municipio.id,
      nombre: municipio.nombre,
      codigo: municipio.codigo
    }, self.get_param('municipio'), { id: true, nombre: true, codigo: true })
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  private

  def select_cliente_fields(data, param, default_params)
    keys = serialized_keys(param, default_params)
    data.slice(*keys)
  end

  def serialized_keys(param, default_params)
    return default_params.keys if self.get_param('all') || param == true || param.nil?
    return [] if param == false
    return default_params.keys unless param.respond_to?(:to_h)

    params = default_params.merge(param.to_h.transform_keys(&:to_sym))
    params.each_with_object([]) do |(key, value), fields|
      fields << key if value.to_s.to_boolean
    end
  end
end
