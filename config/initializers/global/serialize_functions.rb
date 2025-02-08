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
	ActiveModelSerializers::SerializableResource.new(modelo, params)
end