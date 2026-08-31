class GlobalHolidaySerializer < ActiveModel::Serializer
  extend FastSerializer

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

  ALL_OR_FIELD_FIELDS = [
    :id, :country_code, :holiday_key, :name, :date, :observed_date, :effective_date,
    :is_working_day, :year, :source, :metadata
  ].freeze

  DATE_FIELDS = [:date, :observed_date, :effective_date].freeze

  def effective_date
    object.effective_date
  end

  def get_param(col)
    @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    serialize_record(object, default_fields.select { |field| show_field?(field, params) }, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    ALL_OR_FIELD_FIELDS
  end

  def self.show_field?(field, params)
    params[:all] || has_to_show(params[field])
  end

  def self.readers
    return @readers if defined?(@readers)
    @readers = {}
    DATE_FIELDS.each do |field|
      @readers[field] = ->(record) { record.public_send(field)&.as_json }
    end
    @readers
  end
end
