module DGII_MANAGER
  def self.send(document, certification_params)
    # TODO: hacer que si se pasan parametros de certificacion tome esos parametros y no los reales
    puts " "
    puts " "
    puts " "
    puts "model_name --> ".red + "#{document.model_name.element}"
    # cabecera_factura
    # nota
    puts "document --> ".yellow + "#{document.to_json}"
    document_parsed = DGII_MANAGER.parse(document)
    puts "document_parsed --> ".magenta + "#{document_parsed}"

    puts " "
    puts " "
    puts " "

    # TipoeCF
    return document_parsed
  end

  def self.parse(document)
    model_name = document.model_name.element

    return parse_factura(document) if model_name == 'cabecera_factura'
    return parse_nota(document)   if model_name == 'nota'
  end

  def self.parse_factura(document)
    process = document.attributes
    process[:document_type] = DocumentType.factura
    # process[:TipoeCF]       = document.tipo_factura.referencia #TODO: real

    process.with_indifferent_access
  end

  def self.parse_nota(document)
    process = document.attributes
    process[:document_type] = DocumentType.nota
    # process[:TipoeCF]       = document.tipo_factura.referencia #TODO: real

    process.with_indifferent_access
  end

end