module FastSerializer
  def serialize_record(record, fields, readers: {})
    fields.each_with_object({}) do |field, data|
      data[field] = readers.key?(field) ? readers[field].call(record) : read_serialized_value(record, field)
    end
  end

  def serialize_collection(collection, fields, readers: {})
    collection.map { |record| serialize_record(record, fields, readers: readers) }
  end

  def show_serialized_field?(params, field)
    params[:all] || params[field]
  end

  def selected_serialized_fields(param, default_fields, include_all: false)
    return default_fields if include_all || param == true || param.nil?
    return [] if param == false
    return default_fields unless param.respond_to?(:to_h)

    options = default_fields.each_with_object({}) { |field, memo| memo[field] = true }
    options.merge!(param.to_h.transform_keys(&:to_sym))
    options.each_with_object([]) do |(field, value), fields|
      fields << field if value.to_s.to_boolean
    end
  end

  def serialize_selected_record(record, default_fields, param: nil, include_all: false, readers: {})
    serialize_record(record, selected_serialized_fields(param, default_fields, include_all: include_all), readers: readers)
  end

  def read_serialized_value(record, field)
    if record.is_a?(Hash)
      return record[field.to_s] if record.key?(field.to_s)
      return record[field] if record.key?(field)
    end

    return record.public_send(field) if record.respond_to?(field)

    nil
  end
end
