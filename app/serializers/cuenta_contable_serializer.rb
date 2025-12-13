class CuentaContableSerializer < ActiveModel::Serializer

  attribute :id,                     if: Proc.new {  self.get_param('id')                      || self.get_param('all') }
  attribute :descripcion,            if: Proc.new {  self.get_param('descripcion')             || self.get_param('all') }
  attribute :cuenta_control_id,      if: Proc.new {  self.get_param('cuenta_control_id')       || self.get_param('all') }
  attribute :codigo,                 if: Proc.new {  self.get_param('codigo')                  || self.get_param('all') }
  attribute :grupo_cuenta_id,        if: Proc.new {  self.get_param('grupo_cuenta_id')         || self.get_param('all') }
  attribute :nivel,                  if: Proc.new {  self.get_param('nivel')                   || self.get_param('all') }
  attribute :origen,                 if: Proc.new {  self.get_param('origen')                  || self.get_param('all') }
  attribute :is_control,             if: Proc.new {  self.get_param('is_control')              || self.get_param('all') }
  attribute :estado,                 if: Proc.new {  self.get_param('estado')                  || self.get_param('all') }
  attribute :tipo,                   if: Proc.new {  self.get_param('tipo')                    || self.get_param('all') }
  attribute :cuenta_control_id,      if: Proc.new {  self.get_param('cuenta_control_id')       || self.get_param('all') }
  attribute :is_auto_created,        if: Proc.new {  self.get_param('is_auto_created')         || self.get_param('all') }

  attribute :cuentas_contables,      if: Proc.new {  self.get_param('cuentas_contables')}
  attribute :cuenta_control,         if: Proc.new {  self.get_param('cuenta_control')                                     && !object.cuenta_control.nil? }
  attribute :label,                  if: Proc.new {  self.get_param('label') }

  def origen
    OrigenGrupo.get_label(object.origen)
  end

  def tipo
    TipoGrupo.get_label(object.tipo)
  end

  def cuenta_control
    serialize_parser(object.cuenta_control, {id: true, descripcion: true, codigo: true, tipo: true, origen: true })
  end

  def label
    object.label
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
