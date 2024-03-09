class CuentaBancariaSerializer < ActiveModel::Serializer
  attribute :id,                            if: Proc.new { self.get_param('id')                           || self.get_param('all') }
  attribute :numero_cuenta,                 if: Proc.new { self.get_param('numero_cuenta')                || self.get_param('all') }
  attribute :comentario,                    if: Proc.new { self.get_param('comentario')                   || self.get_param('all') }
  attribute :descripcion,                   if: Proc.new { self.get_param('descripcion')                  || self.get_param('all') }
  attribute :fecha_apertura,                if: Proc.new { self.get_param('fecha_apertura')               || self.get_param('all') }
  attribute :estado,                        if: Proc.new { self.get_param('estado')                       || self.get_param('all') }
  attribute :balance_inicial_libro,         if: Proc.new { self.get_param('balance_inicial_libro')        || self.get_param('all') }
  attribute :balance_inicial_banco,         if: Proc.new { self.get_param('balance_inicial_banco')        || self.get_param('all') }
  attribute :fecha_primera_conciliacion,    if: Proc.new { self.get_param('fecha_primera_conciliacion')   || self.get_param('all') }
  attribute :banco_id,                      if: Proc.new { self.get_param('banco_id')                     || self.get_param('all') }
  attribute :divisa_id,                     if: Proc.new { self.get_param('divisa_id')                    || self.get_param('all') }
  attribute :tipo_cuenta_bancaria_id,       if: Proc.new { self.get_param('tipo_cuenta_bancaria_id')      || self.get_param('all') }

  attribute :cuenta_contable,               if: Proc.new {  self.get_param('cuenta_contable')             || self.get_param('all') }
  attribute :cuenta_contable_prima,         if: Proc.new { (self.get_param('cuenta_contable_prima')       || self.get_param('all')) && !object.cuenta_contable_prima.nil? }
  attribute :divisa,                        if: Proc.new { (self.get_param('divisa')                      || self.get_param('all')) }
  attribute :banco,                         if: Proc.new { (self.get_param('banco')                      || self.get_param('all')) }
  attribute :tipo_cuenta_bancaria,          if: Proc.new { (self.get_param('tipo_cuenta_bancaria')        || self.get_param('all')) }

  def cuenta_contable
    serialize_parser(object.cuenta_contable, {id: true, descripcion: true, codigo: true})
  end

  def cuenta_contable_prima
    serialize_parser(object.cuenta_contable_prima, {id: true, descripcion: true, codigo: true})
  end

  def divisa
    serialize_parser(object.divisa, { id: true, nombre: true, imagen: true })

  end
  def banco
    serialize_parser(object.banco, { id: true, nombre: true, comentario: true, estado: true })
  end

  def tipo_cuenta_bancaria
    object.tipo_cuenta_bancaria.descripcion
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
