class ChequeSerializer < ActiveModel::Serializer

  attribute :id,                      if: Proc.new { self.get_param('id')                      || self.get_param('all') }
  attribute :tasa,                    if: Proc.new { self.get_param('tasa')                    || self.get_param('all') }
  attribute :monto,                   if: Proc.new { self.get_param('monto')                   || self.get_param('all') }
  attribute :monto_local,             if: Proc.new { self.get_param('monto_local')             || self.get_param('all') }
  attribute :balance,                 if: Proc.new { self.get_param('balance')                 || self.get_param('all') }
  attribute :comentario,              if: Proc.new { self.get_param('comentario')              || self.get_param('all') }
  attribute :fecha_equivalente,       if: Proc.new { self.get_param('fecha_equivalente')       || self.get_param('all') }
  attribute :fecha_update,            if: Proc.new { self.get_param('fecha_update')            || self.get_param('all') }
  attribute :fecha_anulacion,         if: Proc.new { self.get_param('fecha_anulacion')         || self.get_param('all') }
  attribute :secuencia,               if: Proc.new { self.get_param('secuencia')               || self.get_param('all') }
  attribute :estado,                  if: Proc.new { self.get_param('estado')                  || self.get_param('all') }
  attribute :divisa,                  if: Proc.new { self.get_param('divisa')                  || self.get_param('all') }
  attribute :cuenta_bancaria,         if: Proc.new { self.get_param('cuenta_bancaria')         || self.get_param('all') }
  attribute :user_creador,            if: Proc.new { self.get_param('user_creador')            || self.get_param('all') }
  attribute :last_user_update,        if: Proc.new { self.get_param('last_user_update')        || self.get_param('all') }
  attribute :user_anulador,           if: Proc.new { self.get_param('user_anulador')           || self.get_param('all') }
  attribute :banco_obj,               if: Proc.new { self.get_param('banco_obj')               || self.get_param('all') }

  def divisa
    serialize_parser(object.divisa, { id: true, nombre: true })
  end

  def cuenta_bancaria
    serialize_parser(object.cuenta_bancaria, { id: true, descripcion: true, numero_cuenta: true, info_completa: true })
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

  def banco_obj
    banco = { nombre: '', id: nil }

    banco[:nombre] = object.cuenta_bancaria.banco.nombre
    banco[:id]     = object.cuenta_bancaria.banco.id
    banco
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
