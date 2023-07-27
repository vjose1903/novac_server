class TipoArticuloCuentaContableSerializer < ActiveModel::Serializer

  attribute :id,                       if: Proc.new {   self.get_param('id')                      || self.get_param('all')  }
  attribute :key,                      if: Proc.new {   self.get_param('key')                     || self.get_param('all')  }
  attribute :origen_tipo_id,           if: Proc.new {   self.get_param('origen_tipo_id')          || self.get_param('all')  }
  attribute :descripcion_control,      if: Proc.new { ( self.get_param('descripcion_control')     || self.get_param('all') ) && !object.cuenta_contable_control.nil? }
  attribute :codigo_control,           if: Proc.new { ( self.get_param('codigo_control')          || self.get_param('all') ) && !object.cuenta_contable_control.nil? }
  attribute :is_control_control,       if: Proc.new { ( self.get_param('is_control_control')      || self.get_param('all') ) && !object.cuenta_contable_control.nil? }
  attribute :label_control,            if: Proc.new { ( self.get_param('label_control')           || self.get_param('all') ) && !object.cuenta_contable_control.nil? }

  attribute :descripcion_auxiliar,     if: Proc.new { ( self.get_param('descripcion_auxiliar')    || self.get_param('all') ) && !object.cuenta_contable_auxiliar.nil? }
  attribute :codigo_auxiliar,          if: Proc.new { ( self.get_param('codigo_auxiliar')         || self.get_param('all') ) && !object.cuenta_contable_auxiliar.nil? }
  attribute :is_control_auxiliar,      if: Proc.new { ( self.get_param('is_control_auxiliar')     || self.get_param('all') ) && !object.cuenta_contable_auxiliar.nil? }
  attribute :label_auxiliar,           if: Proc.new { ( self.get_param('label_auxiliar')          || self.get_param('all') ) && !object.cuenta_contable_auxiliar.nil? }


  def descripcion_control
    object.cuenta_contable_control.descripcion
  end

  def codigo_control
    object.cuenta_contable_control.codigo
  end

  def label_control
    object.cuenta_contable_control.label
  end

  def is_control_control
    object.cuenta_contable_control.is_control
  end

  def descripcion_auxiliar
    object.cuenta_contable_auxiliar.descripcion
  end

  def codigo_auxiliar
    object.cuenta_contable_auxiliar.codigo
  end

  def label_auxiliar
    object.cuenta_contable_auxiliar.label
  end

  def is_control_auxiliar
    object.cuenta_contable_auxiliar.is_control
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end

end
