def has_to_show(parameters)
	return parameters if [true, false].include?(parameters)

	validate_inner_value(parameters)
end

# ---------------------------------------------------------------------------------------------------------

def validate_inner_value(parameters)
	parameters.is_a?(Hash) && ( parameters['all'].present? && parameters['all'] || parameters.values.any? { | item | item == true || ( item.is_a?(Hash) && validate_inner_value(item)) } )
end

# ---------------------------------------------------------------------------------------------------------

def parse_serialize_optional_params(selected_params, default_params)
	
	if selected_params == true || selected_params == false
		parameters = selected_params ? default_params : { all: false }
	else
		parameters = selected_params ? {**default_params, **selected_params} : default_params
	end

	parameters
end

# ---------------------------------------------------------------------------------------------------------

def serialize_parser(modelo, params={ all: true })
  fast_serialize_parser(modelo, params)
end

def fast_serialize_parser(modelo, params={ all: true })
  return nil if modelo.nil?

  active_record_collection = (defined?(ActiveRecord::Relation) && modelo.is_a?(ActiveRecord::Relation)) ||
    (defined?(ActiveRecord::Associations::CollectionProxy) && modelo.is_a?(ActiveRecord::Associations::CollectionProxy))
  model_class = if active_record_collection
    modelo.klass
  elsif modelo.is_a?(Array)
    modelo.first&.class
  else
    modelo.class
  end
  serializer = "#{model_class}Serializer".safe_constantize if model_class
  return serializer.collection_to_hash(modelo, params) if serializer&.respond_to?(:collection_to_hash) && (modelo.is_a?(Array) || active_record_collection)
  return serializer.to_hash(modelo, params) if serializer&.respond_to?(:to_hash)

  ActiveModelSerializers::SerializableResource.new(modelo, params)
end
