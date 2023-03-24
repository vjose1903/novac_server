class BancoSerializer < ActiveModel::Serializer

  attribute :id,                                  if: Proc.new { self.get_param('id')                           || self.get_param('all') }
  attribute :nombre,                              if: Proc.new { self.get_param('nombre')                       || self.get_param('all') }
  attribute :rnc,                                 if: Proc.new { self.get_param('rnc')                          || self.get_param('all') }
  attribute :comentario,                          if: Proc.new { self.get_param('comentario')                   || self.get_param('all') }
  attribute :telefono,                            if: Proc.new { self.get_param('telefono')                     || self.get_param('all') }
  attribute :direccion,                           if: Proc.new { self.get_param('direccion')                    || self.get_param('all') }
  attribute :ejecutivo_cuenta,                    if: Proc.new { self.get_param('ejecutivo_cuenta')             || self.get_param('all') }
  attribute :telefono_ejecutivo_cuenta,           if: Proc.new { self.get_param('telefono_ejecutivo_cuenta')    || self.get_param('all') }
  attribute :estado,                              if: Proc.new { self.get_param('estado')                       || self.get_param('all') }

  attribute :cuentas_bancarias,                   if: Proc.new { self.get_param('cuentas_bancarias')            || self.get_param('all') }

  def cuentas_bancarias
    serialize_parser(object.cuentas_bancarias, { all: true })
  end

  def get_param(col)
    return @instance_options[:"#{col}"]
  end
end
