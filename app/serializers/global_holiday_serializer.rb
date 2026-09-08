class GlobalHolidaySerializer < ActiveModel::Serializer
  extend FastSerializer


  ALL_OR_FIELD_FIELDS = [
    :id, :country_code, :holiday_key, :name, :date, :observed_date, :effective_date,
    :is_working_day, :year, :source, :metadata
  ].freeze

  DATE_FIELDS = [:date, :observed_date, :effective_date].freeze



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
