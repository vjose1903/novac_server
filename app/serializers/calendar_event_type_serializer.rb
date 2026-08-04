class CalendarEventTypeSerializer < ActiveModel::Serializer
  attribute :id, if: Proc.new { get_param('all') || get_param('id') }
  attribute :name, if: Proc.new { get_param('all') || get_param('name') }
  attribute :slug, if: Proc.new { get_param('all') || get_param('slug') }
  attribute :color, if: Proc.new { get_param('all') || get_param('color') }
  attribute :is_system, if: Proc.new { get_param('all') || get_param('is_system') }
  attribute :active, if: Proc.new { get_param('all') || get_param('active') }
  attribute :sort_order, if: Proc.new { get_param('all') || get_param('sort_order') }

  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
