class NotaSerializer < ActiveModel::Serializer

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

	def cliente

    cliente = {}
    if object.cliente.blank?
      cliente[:nombre]            = object.no_cliente_nombre
      cliente[:nombre_completo]   = object.no_cliente_nombre
      cliente[:direccion]         = object.no_cliente_direccion
      cliente[:telefono]          = "----------"
      cliente[:rnc]               = "----------"
    else
      client_                     = object.cliente.attributes
      cliente[:nombre]            = object.cliente.nombre_completo
      cliente[:telefono]          = client_[:telefono]
      cliente[:direccion]         = client_[:direccion]
      cliente[:nombre_completo]   = object.cliente.nombre_completo

      documento                    = object.cliente.documentos_de_identidad.find { |doc| doc.principal == true }
      cliente["rnc"]               = documento.nil? ? "----------" : documento.documento
    end
    cliente
  end

	def usuario
    usuario = object.user.nombre_completo
    usuario
  end

	def tipo_factura
    object.tipo_factura.descripcion.capitalize
  end

	def facturas_aplicadas
		serialize_parser(object.facturas_aplicadas, {all: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
