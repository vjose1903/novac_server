class CabezaAsientoContableSerializer < ActiveModel::Serializer

  attribute :id,                             if: Proc.new { self.get_param('id')                             || self.get_param('all') }
  attribute :comentario,                     if: Proc.new { self.get_param('comentario')                     || self.get_param('all') }
  attribute :tipo,                           if: Proc.new { self.get_param('tipo')                           || self.get_param('all') }
  attribute :fecha_equivalente,              if: Proc.new { self.get_param('fecha_equivalente')              || self.get_param('all') }
  attribute :fecha_anulacion,                if: Proc.new { self.get_param('fecha_anulacion')                || self.get_param('all') }
  attribute :estado,                         if: Proc.new { self.get_param('estado')                         || self.get_param('all') }

  attribute :usuario_creador,                if: Proc.new { self.get_param('usuario_creador')                || self.get_param('all') }
  attribute :usuario_anulador,               if: Proc.new { self.get_param('usuario_anulador')               || self.get_param('all') }
  attribute :periodo_fiscal,                 if: Proc.new { self.get_param('periodo_fiscal')                 || self.get_param('all') }
  attribute :detalles_asientos_contables,    if: Proc.new { self.get_param('detalles_asientos_contables')    || self.get_param('all') }

  def usuario_creador
    serialize_parser(object.usuario_creador, { id: true, nombre_completo: true })
  end

  def usuario_anulador
    serialize_parser(object.usuario_anulador, { id: true, nombre_completo: true })
  end

  def periodo_fiscal
    serialize_parser(object.periodo_fiscal, { fecha_inicio: true, fecha_cierre: true })
  end

  def detalles_asientos_contables
    serialize_parser(object.detalles_asientos_contables, { all: true })
  end


  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
