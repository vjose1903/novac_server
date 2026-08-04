class CalendarEventLinkSerializer < ActiveModel::Serializer
  attribute :id, if: Proc.new { get_param('all') || get_param('id') }
  attribute :calendar_event_id, if: Proc.new { get_param('all') || get_param('calendar_event_id') }
  attribute :linkable_type, if: Proc.new { get_param('all') || get_param('linkable_type') }
  attribute :linkable_id, if: Proc.new { get_param('all') || get_param('linkable_id') }
  attribute :label, if: Proc.new { get_param('all') || get_param('label') }
  attribute :metadata, if: Proc.new { get_param('all') || get_param('metadata') }

  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
