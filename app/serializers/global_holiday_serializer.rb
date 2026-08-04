class GlobalHolidaySerializer < ActiveModel::Serializer
  attribute :id, if: Proc.new { get_param('all') || get_param('id') }
  attribute :country_code, if: Proc.new { get_param('all') || get_param('country_code') }
  attribute :holiday_key, if: Proc.new { get_param('all') || get_param('holiday_key') }
  attribute :name, if: Proc.new { get_param('all') || get_param('name') }
  attribute :date, if: Proc.new { get_param('all') || get_param('date') }
  attribute :observed_date, if: Proc.new { get_param('all') || get_param('observed_date') }
  attribute :effective_date, if: Proc.new { get_param('all') || get_param('effective_date') }
  attribute :is_working_day, if: Proc.new { get_param('all') || get_param('is_working_day') }
  attribute :year, if: Proc.new { get_param('all') || get_param('year') }
  attribute :source, if: Proc.new { get_param('all') || get_param('source') }
  attribute :metadata, if: Proc.new { get_param('all') || get_param('metadata') }

  def effective_date
    object.effective_date
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end
end
