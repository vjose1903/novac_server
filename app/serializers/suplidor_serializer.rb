class SuplidorSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                            if: Proc.new { has_to_show(self.get_param('all') || self.get_param('id')) }
  attribute :nombre,                        if: Proc.new { has_to_show(self.get_param('all') || self.get_param('nombre')) }
  attribute :telefono,                      if: Proc.new { has_to_show(self.get_param('all') || self.get_param('telefono')) }
  attribute :direccion,                     if: Proc.new { has_to_show(self.get_param('all') || self.get_param('direccion')) }
  attribute :email,                         if: Proc.new { has_to_show(self.get_param('all') || self.get_param('email')) }
  attribute :estado,                        if: Proc.new { has_to_show(self.get_param('all') || self.get_param('estado')) }
  attribute :documentos_de_identidad,       if: Proc.new { has_to_show(self.get_param('all') || self.get_param('documentos_de_identidad')) }
  attribute :nombre_completo,               if: Proc.new { has_to_show(self.get_param('all') || self.get_param('nombre_completo')) }

  def documentos_de_identidad
    SuplidorSerializer.documentos_de_identidad_to_hash(object, self.get_param('documentos_de_identidad'), self.get_param('all'))
  end

  def nombre_completo
		vendedor = object.nombre_completo
	end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end

  def self.to_hash(object, params={})
    data = serialize_record(object, default_fields.select { |field| show_serialized_field?(params, field) })
    data[:documentos_de_identidad] = documentos_de_identidad_to_hash(object, params[:documentos_de_identidad], params[:all]) if show_serialized_field?(params, :documentos_de_identidad)
    data[:nombre_completo] = object.nombre_completo if show_serialized_field?(params, :nombre_completo)
    data
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :nombre, :telefono, :direccion, :email, :estado]
  end

  def self.documentos_de_identidad_to_hash(object, param=true, include_all=false)
    object.documentos_de_identidad.map do |documento|
      serialize_selected_record(documento, [:id, :descripcion, :documento, :principal], param: param, include_all: include_all)
    end
  end
end
