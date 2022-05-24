class NotaSerializer < ActiveModel::Serializer

	attribute :id,                        if: Proc.new { self.get_param('id') || self.get_param('all') }
	attribute :total,                     if: Proc.new { self.get_param('total') || self.get_param('all') }
	attribute :identificador,             if: Proc.new { self.get_param('identificador') || self.get_param('all') }
	attribute :numero_documento,          if: Proc.new { self.get_param('numero_documento') || self.get_param('all') }
	attribute :numero_comprobante,        if: Proc.new { self.get_param('numero_comprobante') || self.get_param('all') }
	attribute :fecha_equivalente,         if: Proc.new { self.get_param('fecha_equivalente') || self.get_param('all') }
	attribute :fecha_valida,              if: Proc.new { self.get_param('fecha_valida') || self.get_param('all') }
	attribute :no_cliente_nombre,         if: Proc.new { self.get_param('no_cliente_nombre') || self.get_param('all') }
	attribute :no_cliente_direccion,      if: Proc.new { self.get_param('no_cliente_direccion') || self.get_param('all') }
	attribute :estado,                    if: Proc.new { self.get_param('estado') || self.get_param('all') }

	attribute :cliente,                   if: Proc.new { self.get_param('cliente') || self.get_param('all') }
	attribute :usuario,                   if: Proc.new { self.get_param('usuario') || self.get_param('all') }
	attribute :tipo_factura,              if: Proc.new { self.get_param('tipo_factura') || self.get_param('all') }
	attribute :facturas_aplicadas,        if: Proc.new { self.get_param('facturas_aplicadas') || self.get_param('all') }

	def cliente

    cliente = {}
    if object.cliente.blank?
      cliente["nombre"]            = object.no_cliente_nombre
      cliente["direccion"]         = object.no_cliente_direccion
      cliente["telefono"]          = "----------"
      cliente["rnc"]               = "----------"
    else
      client_                      = object.cliente.attributes
      cliente["nombre"]            = object.cliente.nombre_completo
      cliente["telefono"]          = client_["telefono"]
      cliente["direccion"]         = client_["direccion"]

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
    object.tipo_factura.descripcion.titleize
  end

	def facturas_aplicadas
		serialize_parser(object.facturas_aplicadas, {all: true})
	end

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
