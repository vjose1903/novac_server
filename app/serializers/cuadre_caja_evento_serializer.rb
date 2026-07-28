class CuadreCajaEventoSerializer < ActiveModel::Serializer
  attribute :id, if: Proc.new { get_param('id') || get_param('all') }
  attribute :event_type, if: Proc.new { get_param('event_type') || get_param('all') }
  attribute :from_status, if: Proc.new { get_param('from_status') || get_param('all') }
  attribute :to_status, if: Proc.new { get_param('to_status') || get_param('all') }
  attribute :reason, if: Proc.new { get_param('reason') || get_param('all') }
  attribute :metadata, if: Proc.new { get_param('metadata') || get_param('all') }
  attribute :created_at, if: Proc.new { get_param('created_at') || get_param('all') }
  attribute :user, if: Proc.new { get_param('user') || get_param('all') }

  def user
    serialize_parser(object.user, { id: true, nombre: true, apellido: true, nombre_completo: true })
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
