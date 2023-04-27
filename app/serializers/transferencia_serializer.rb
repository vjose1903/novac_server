class TransferenciaSerializer < ActiveModel::Serializer

	attribute :id,                       if: Proc.new { self.get_param('id')                        || self.get_param('all') }
  attribute :tasa,                     if: Proc.new { self.get_param('tasa')                      || self.get_param('all') }
  attribute :monto,                    if: Proc.new { self.get_param('monto')                     || self.get_param('all') }
  attribute :monto_local,              if: Proc.new { self.get_param('monto_local')               || self.get_param('all') }
  attribute :comentario,               if: Proc.new { self.get_param('comentario')                || self.get_param('all') }
  attribute :numero_referencia,        if: Proc.new { self.get_param('numero_referencia')         || self.get_param('all') }
  attribute :fecha_equivalente,        if: Proc.new { self.get_param('fecha_equivalente')         || self.get_param('all') }
  attribute :fecha_anulacion,          if: Proc.new { self.get_param('fecha_anulacion')           || self.get_param('all') }
  attribute :nombre_banco_tercero,     if: Proc.new { self.get_param('nombre_banco_tercero')      || self.get_param('all') }
  attribute :cuenta_bancaria_tercero,  if: Proc.new { self.get_param('cuenta_bancaria_tercero')   || self.get_param('all') }
  attribute :estado,                   if: Proc.new { self.get_param('estado')                    || self.get_param('all') }

  attribute :cuenta_bancaria_origen,   if: Proc.new { self.get_param('cuenta_bancaria_origen')       || self.get_param('all') }
  attribute :cuenta_bancaria_destino,  if: Proc.new { self.get_param('cuenta_bancaria_destino')       || self.get_param('all') }
  attribute :divisa,                   if: Proc.new { self.get_param('divisa')                || self.get_param('all') }
  attribute :user_creador,             if: Proc.new { self.get_param('user_creador')          || self.get_param('all') }
  attribute :last_user_update,         if: Proc.new { self.get_param('last_user_update')      || self.get_param('all') }
  attribute :user_anulador,            if: Proc.new { self.get_param('user_anulador')         || self.get_param('all') }

  def cuenta_bancaria_origen
    serialize_parser(object.cuenta_bancaria_origen, { id: true, descripcion: true })
  end

  def cuenta_bancaria_destino
    serialize_parser(object.cuenta_bancaria_destino, { id: true, descripcion: true })
  end

  def divisa
    serialize_parser(object.divisa, { id: true, nombre: true })
  end

  def user_creador
    serialize_parser(object.user_creador, { id: true, nombre_completo: true })
  end

  def last_user_update
      serialize_parser(object.last_user_update, { id: true, nombre_completo: true })
  end

  def user_anulador
    serialize_parser(object.user_anulador, { id: true, nombre_completo: true })
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
