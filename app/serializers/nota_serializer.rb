class NotaSerializer < ActiveModel::Serializer
  extend FastSerializer

  attribute :id,                        if: Proc.new { self.get_param('all') || self.get_param('id') }
  attribute :total,                     if: Proc.new { self.get_param('all') || self.get_param('total') }
  attribute :bruto,                     if: Proc.new { self.get_param('all') || self.get_param('bruto') }
  attribute :itbis,                     if: Proc.new { self.get_param('all') || self.get_param('itbis') }
  attribute :identificador,             if: Proc.new { self.get_param('all') || self.get_param('identificador') }
  attribute :numero_documento,          if: Proc.new { self.get_param('all') || self.get_param('numero_documento') }
  attribute :numero_comprobante,        if: Proc.new { self.get_param('all') || self.get_param('numero_comprobante') }
  attribute :fecha_equivalente,         if: Proc.new { self.get_param('all') || self.get_param('fecha_equivalente') }
  attribute :fecha_valida,              if: Proc.new { self.get_param('all') || self.get_param('fecha_valida') }
  attribute :no_cliente_nombre,         if: Proc.new { self.get_param('all') || self.get_param('no_cliente_nombre') }
  attribute :no_cliente_direccion,      if: Proc.new { self.get_param('all') || self.get_param('no_cliente_direccion') }
  attribute :no_cliente_rnc,            if: Proc.new { self.get_param('all') || self.get_param('no_cliente_rnc') }
  attribute :estado,                    if: Proc.new { self.get_param('all') || self.get_param('estado') }
  attribute :tipo_factura_id,           if: Proc.new { self.get_param('all') || self.get_param('tipo_factura_id') }
  attribute :serie,                     if: Proc.new { self.get_param('all') || self.get_param('serie') }
  attribute :razon,                     if: Proc.new { self.get_param('all') || self.get_param('razon') }
  attribute :fecha_hora_firma,          if: Proc.new { self.get_param('all') || self.get_param('fecha_hora_firma')  }
  attribute :qr_url_dgii,               if: Proc.new { self.get_param('all') || self.get_param('qr_url_dgii')  }
  attribute :trackId,                   if: Proc.new { self.get_param('all') || self.get_param('trackId')  }
  attribute :security_code,             if: Proc.new { self.get_param('all') || self.get_param('security_code')  }
  attribute :is_aceptada,               if: Proc.new { self.get_param('all') || self.get_param('is_aceptada')  }
  attribute :dgii_message,              if: Proc.new { self.get_param('all') || self.get_param('dgii_message')  }

  attribute :cliente,                   if: Proc.new { self.get_param('all') || self.get_param('cliente') }
  attribute :usuario,                   if: Proc.new { self.get_param('all') || self.get_param('usuario') }
  attribute :tipo_factura,              if: Proc.new { self.get_param('all') || self.get_param('tipo_factura') }
  attribute :facturas_aplicadas,        if: Proc.new { self.get_param('all') || self.get_param('facturas_aplicadas') }

  ALL_OR_FIELD_FIELDS = [:id, :total, :bruto, :itbis, :identificador, :numero_documento, :numero_comprobante, :fecha_equivalente, :fecha_valida, :no_cliente_nombre, :no_cliente_direccion, :no_cliente_rnc, :estado, :tipo_factura_id, :serie, :razon, :fecha_hora_firma, :qr_url_dgii, :trackId, :security_code, :is_aceptada, :dgii_message, :cliente, :usuario, :tipo_factura, :facturas_aplicadas].freeze

  def get_param(col)
    return @instance_options[:"#{col}"]
  end

  def self.to_hash(object, params={})
    fields = default_fields.select { |field| show_field?(field, params) }
    serialize_record(object, fields, readers: readers)
  end

  def self.collection_to_hash(collection, params={})
    collection.map { |object| to_hash(object, params) }
  end

  def self.default_fields
    [:id, :total, :bruto, :itbis, :identificador, :numero_documento, :numero_comprobante, :fecha_equivalente, :fecha_valida, :no_cliente_nombre, :no_cliente_direccion, :no_cliente_rnc, :estado, :tipo_factura_id, :serie, :razon, :fecha_hora_firma, :qr_url_dgii, :trackId, :security_code, :is_aceptada, :dgii_message, :cliente, :usuario, :tipo_factura, :facturas_aplicadas]
  end

  def self.show_field?(field, params)
    ALL_OR_FIELD_FIELDS.include?(field) ? (params[:all] || params[field]) : params[field]
  end

  def self.readers
    {
      cliente: ->(record) {
        cliente = {}
        if record.cliente.blank?
          cliente[:nombre]            = record.no_cliente_nombre
          cliente[:nombre_completo]   = record.no_cliente_nombre
          cliente[:direccion]         = record.no_cliente_direccion
          cliente[:telefono]          = "----------"
          cliente[:rnc]               = record.no_cliente_rnc
        else
          client_                     = record.cliente.attributes
          cliente[:nombre]            = record.cliente.nombre_completo
          cliente[:telefono]          = client_[:telefono]
          cliente[:direccion]         = client_[:direccion]
          cliente[:nombre_completo]   = record.cliente.nombre_completo

          documento                   = record.cliente.documentos_de_identidad.find { |doc| doc.principal == true }
          cliente["rnc"]              = documento.nil? ? "----------" : documento.documento
        end
        cliente
      },
      usuario: ->(record) { record.user.nombre_completo },
      tipo_factura: ->(record) { record.tipo_factura.descripcion.titleize },
      facturas_aplicadas: ->(record) { FacturaAplicadaSerializer.collection_to_hash(record.facturas_aplicadas, {all: true}) }
    }
  end
end
