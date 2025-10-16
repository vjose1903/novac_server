class DocumentoDeIdentidadSerializer < ActiveModel::Serializer

  attribute :id,              if: Proc.new { has_to_show(self.get_param('id'))            || self.get_param('all') }
  attribute :descripcion,     if: Proc.new { has_to_show(self.get_param('descripcion'))   || self.get_param('all') }
  attribute :documento,       if: Proc.new { has_to_show(self.get_param('documento'))     || self.get_param('all') }
  attribute :principal,       if: Proc.new { has_to_show(self.get_param('principal'))     || self.get_param('all') }

  attribute :persona,         if: Proc.new { self.get_param('persona')  }
  attribute :persona_is,      if: Proc.new { self.get_param('persona')  }

  def persona_is
    object.origen_type
	end

  def persona
    serialize_parser(object.origen, { all:true, documentos_de_identidad: true })
	end

  def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
