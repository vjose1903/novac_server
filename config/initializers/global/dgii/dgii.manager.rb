module DGII_MANAGER

  @certification_params = nil
  def self.send(document, certification_params = nil)
    @certification_params = certification_params
    puts "certification_params ".light_green + " #{certification_params}"
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
    process           = document.attributes

    process[:cliente] = parse_cliente(document)


    model_name = document.model_name.element
    return parse_factura(process, document) if model_name == 'cabecera_factura'
    return parse_nota(process, document)    if model_name == 'nota'
  end

  def self.parse_factura(process, document)
    process[:document_type] = DocumentType.factura
    process[:TipoeCF]       = document.tipo_factura.referencia


    unless @certification_params == nil
      process[:TipoeCF]                  = @certification_params[:TipoeCF]
      process[:numero_comprobante]       = @certification_params[:numero_comprobante]

    end

    process.with_indifferent_access
  end

  def self.parse_nota(process, document)
    process[:document_type] = DocumentType.nota
    process[:TipoeCF]       = document.tipo_factura.referencia

    unless @certification_params == nil
      process[:TipoeCF]                  = @certification_params[:TipoeCF]
      process[:numero_comprobante]       = @certification_params[:numero_comprobante]

    end

    process.with_indifferent_access
  end


  def self.parse_cliente(document)
    cliente            = document.cliente || nil

    if cliente.nil?
      cliente_attributes          = {}
      cliente_attributes[:nombre] = document.NoCliente_nombre
    else
      cliente_attributes                           = cliente.attributes
      cliente_attributes[:documentos_de_identidad] = cliente.documentos_de_identidad

      cliente_attributes[:municipio]               = cliente.municipio
      cliente_attributes[:provincia]               = cliente.provincia
    end

    return cliente_attributes
  end
end