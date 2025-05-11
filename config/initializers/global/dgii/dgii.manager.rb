module DGII_MANAGER
  @certification_params = nil
  @is_nota    = false
  @is_factura = false

  # ========================================================================================================
  # ENVIAR FACTURAS Y NOTAS A DGII
  # ========================================================================================================  

  def self.send(document, certification_params = nil)
    DGII_MANAGER.determinate_document(document)

    res = Response.new

    @certification_params = certification_params

    document_parsed       = DGII_MANAGER.parse(document)

    client   = BaseRequest::Client.new('novac-dgii')

    response = client.create_one(document_parsed)

    data_response = response.with_indifferent_access[:data]

    estado = data_response[:estado].present? ? data_response[:estado] : nil

    document.is_aceptada          = estado.nil? ? false : estado.downcase != 'rechazado'
    document.dgii_message         = response[:message]
    document.estado               = false  unless document.is_aceptada

    if data_response[:secuenciaUtilizada] && ((estado && estado.downcase != 'rechazado') || !data_response[:estado].present?)
      document.fecha_hora_firma   = data_response[:fecha_hora_firma]
      document.trackId            = data_response[:trackId]
      document.security_code      = data_response[:security_code]
      document.xml_file_name      = data_response[:xml_file_name]
      document.qr_url_dgii        = data_response[:qr_url_dgii]
      document.razon              = data_response[:razon] if @is_nota &&  data_response[:razon].present?

      document.save!
    end


    res.set_data(data_response.with_indifferent_access)
    res.add_msg(response[:message])

    if data_response[:estado].downcase == 'rechazado'
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    # TODO: SI GET_DATA DEL RES TIENE LA PROPIEDAD 'secuenciaUtilizada' independientemente del estado tengo que sumar la secuencia
    return res
  end

  def self.determinate_document(document)
    model_name = document.model_name.element

    @is_nota    = model_name == 'nota'
    @is_factura = model_name == 'cabecera_factura'
  end

  def self.parse(document)
    process                     = document.attributes

    process[:cliente]           = parse_cliente(document)
    process[:fecha_vencimiento] = validate_fecha_vencimiento(document)

    return parse_factura(process, document) if @is_factura
    return parse_nota(process, document)    if @is_nota
  end

  # ========================================================================================================
  # FACTURAS
  # ========================================================================================================

  def self.parse_factura(process, document)
    process[:document_type]          = DocumentType.factura
    process[:TipoeCF]                = document.tipo_factura.referencia

    process[:detalle_facturas]       = parse_detalles(document)

    unless @certification_params == nil
      process[:TipoeCF]              = @certification_params[:TipoeCF]
      process[:numero_comprobante]   = @certification_params[:numero_comprobante]
    end

    process.with_indifferent_access
  end

  def self.parse_detalles(document)
    detalles = document.detalle_facturas.map do | detalle |
      detalle_parsed = detalle.attributes

      articulo       = detalle.articulo
      add_articulo(detalle_parsed, articulo)

      detalle_parsed[:codigo]      = articulo.codigo
      detalle_parsed[:descripcion] = articulo.nombre.strip

      detalle_parsed.with_indifferent_access
    end

    detalles
  end


  # ========================================================================================================
  # NOTAS
  # ========================================================================================================

  def self.parse_nota(process, document)
    process[:document_type]            = DocumentType.nota
    process[:TipoeCF]                  = document.tipo_factura.referencia

    process[:facturas_aplicadas]       = parse_detalles_notas(document)


    unless @certification_params == nil
      process[:TipoeCF]                = @certification_params[:TipoeCF]
      process[:numero_comprobante]     = @certification_params[:numero_comprobante]
    end

    process.with_indifferent_access
  end

  def self.parse_detalles_notas(document)
    detalles_nota = document.facturas_aplicadas.map do | detalle |
      detalle_nota_parsed           = detalle.attributes

      # TODO: hacer un metodo que me convierta el comprobante de la factura a tipo electronico si hay certification_params
      factura                       = detalle.cabecera_factura
      detalle_nota_parsed[:factura] = factura.attributes

      unless @certification_params == nil
      detalle_nota_parsed[:factura][:fecha_vencimiento] = validate_fecha_vencimiento(factura.attributes.with_indifferent_access)

      end

      detalle_nota_parsed[:detalles_facturas_notas] = detalle.detalles_facturas_notas.map do | detalle_factura_nota |
        detalle_factura_nota_parsed = detalle_factura_nota.attributes

        articulo                    = detalle_factura_nota.articulo
        add_articulo(detalle_factura_nota_parsed, articulo)

        detalle_factura_nota_parsed[:codigo]      = articulo.codigo
        detalle_factura_nota_parsed[:descripcion] = articulo.nombre.strip

        detalle_factura_nota_parsed.with_indifferent_access
      end

      detalle_nota_parsed.with_indifferent_access
    end

    return detalles_nota
  end


  # ========================================================================================================
  # SHARED
  # ========================================================================================================

  def self.parse_cliente(document)
    cliente            = document.cliente || nil

    if cliente.nil?
      cliente_attributes          = {}
      cliente_attributes[:nombre] = document.NoCliente_nombre
    else
      cliente_attributes                           = cliente.attributes
      cliente_attributes[:documentos_de_identidad] = cliente.documentos_de_identidad

      cliente_attributes[:limite_credito]          = cliente.limite_credito
      cliente_attributes[:municipio]               = cliente.municipio
      cliente_attributes[:provincia]               = cliente.provincia
    end

    return cliente_attributes
  end

  def self.add_articulo(detalle_parsed, articulo)
    detalle_parsed[:articulo] = { **articulo.attributes, tipo_articulo: articulo.tipo_articulo.attributes }
  end

  def self.validate_fecha_vencimiento(document)
    fecha_vencimiento = document[:fecha_vencimiento]
    puts " "
    puts " "
    puts " "
    puts "document          ".green + " #{document}"
    puts "fecha_vencimiento ".green + " #{fecha_vencimiento}"
    puts " "
    puts " "
    puts " "

    if fecha_vencimiento.nil?
      return nil
    end

    unless @certification_params == nil
      cliente = document[:cliente]
      dias_credito = 30 # valor por defecto

      # Si existe cliente y tiene limite_credito, usamos ese valor
      if cliente && cliente[:limite_credito].present?
        dias_credito = cliente[:limite_credito]
      end

      # Calcular fecha base (fecha actual + días de crédito)
      fecha_base = Date.today + dias_credito.days

      # Crear DateTime con hora específica (7:59 AM)
      fecha_con_hora = DateTime.new(fecha_base.year, fecha_base.month, fecha_base.day, 7, 59, 0)
      # Convertir a formato ISO 8601 con milisegundos
      return fecha_con_hora.utc.iso8601(3)
    end

    return fecha_vencimiento

  end


  # ========================================================================================================
  # RECEPCION DE FACTURAS 
  # ========================================================================================================  

  def self.reception(params)
    res      = Response.new
    client   = BaseRequest::Client.new('novac-dgii-reception')
    

    response      = client.create_one(params)

    data_response = response.with_indifferent_access[:data]

    res.set_data({xml: data_response}.with_indifferent_access)

    return res
  end


  # ========================================================================================================
  # VALIDATE COMMERCIAL APPROVAL
  # ========================================================================================================  

  def self.validate_commercial_approval(params)
    res      = Response.new
    client   = BaseRequest::Client.new('novac-dgii-validate-commercial-approval')
    

    response      = client.create_one(params)

    data_response = response.with_indifferent_access[:data]
    puts "data_response:".magenta + " #{data_response.to_json}"
    res.set_data(data_response.with_indifferent_access)

    return res
  end
end