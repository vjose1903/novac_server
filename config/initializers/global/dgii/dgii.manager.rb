module DGII_MANAGER
  @certification_params = nil
  
  def self.send(document, certification_params = nil)
    @certification_params = certification_params

    document_parsed = DGII_MANAGER.parse(document)

    return document_parsed
  end

  def self.parse(document)
    process           = document.attributes

    process[:cliente] = parse_cliente(document)


    model_name = document.model_name.element
    return parse_factura(process, document) if model_name == 'cabecera_factura'
    return parse_nota(process, document)    if model_name == 'nota'
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

    return process.with_indifferent_access
  end

  def self.parse_detalles(document)
    detalles = document.detalle_facturas.map do | detalle |
      detalle_parsed = detalle.attributes
      articulo       = detalle.articulo

      detalle_parsed[:articulo] = { **detalle.articulo.attributes, tipo_articulo: articulo.tipo_articulo.attributes }

      return detalle_parsed
    end

    return detalles.with_indifferent_access
  end


  # ========================================================================================================
  # NOTAS
  # ========================================================================================================

  def self.parse_nota(process, document)
    process[:document_type] = DocumentType.nota
    process[:TipoeCF]       = document.tipo_factura.referencia

    unless @certification_params == nil
      process[:TipoeCF]                  = @certification_params[:TipoeCF]
      process[:numero_comprobante]       = @certification_params[:numero_comprobante]

    end

    process.with_indifferent_access
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

      cliente_attributes[:municipio]               = cliente.municipio
      cliente_attributes[:provincia]               = cliente.provincia
    end

    return cliente_attributes
  end
end