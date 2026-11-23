class GrupoCuentaSerializer < ActiveModel::Serializer
  attribute :id,                           if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :descripcion,                  if: Proc.new { self.get_param('descripcion') || self.get_param('all') }
  attribute :grupo,                        if: Proc.new { self.get_param('grupo') || self.get_param('all') }
  attribute :origen,                       if: Proc.new { self.get_param('origen') || self.get_param('all') }
  attribute :tipo,                         if: Proc.new { self.get_param('tipo') || self.get_param('all') }
  attribute :estado,                       if: Proc.new { self.get_param('estado') || self.get_param('all') }
  attribute :cuentas_contables,            if: Proc.new { self.get_param('cuentas_contables') || self.get_param('all') }

  def origen
    OrigenGrupo.get_label(object.origen)
  end

  def tipo
    TipoGrupo.get_label(object.tipo)
  end

  def cuentas_contables
    serialize_parser(object.cuentas_contables, {all: true})
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
