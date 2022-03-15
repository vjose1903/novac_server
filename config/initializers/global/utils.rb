def pasar_notas
	notas         = CabeceraFactura.where({tipo_factura_id: [TiposNotasId.credito, TiposNotasId.debito]})
	notas.each do |nota|

		factura_aplicada = CabeceraFactura.find_by_numero_comprobante(nota.aplicada_a)
		detalles_notas   = nota.detalle_facturas

		obj = {
		:cliente_id                    => nota.cliente_id,
		:user_id                       => nota.user_id,
		:tipo_factura_id               => nota.tipo_factura_id,
		:total                         => nota.total_factura,
		:numero_documento              => nota.numero_factura,
		:numero_comprobante            => nota.numero_comprobante,
		:fecha_equivalente             => nota.fecha_equivalente,
		:estado                        => nota.estado,
		:no_cliente_nombre             => nota.NoCliente_nombre,
		:no_cliente_direccion          => nota.NoCliente_direccion,

		:facturas_aplicadas            => [{
				:cabecera_factura_id         => factura_aplicada.id,
				:total                       => nota.total_factura,
				:detalles_facturas_notas     => []
			}]
		}

		detalles_notas.each do | detalle |
			obj[:facturas_aplicadas][0][:detalles_facturas_notas].push({
				:articulo_id               => detalle.articulo_id,
				:detalle_factura_id        => detalle.detalle_factura_nota,
				:unidad                    => detalle.unidad,
				:cantidad                  => detalle.cantidad,
				:cantidad_en_unidades      => detalle.cantidad_en_unidades,
				:itbis                     => detalle.itbis,
				:costo                     => detalle.costo,
				:precio                    => detalle.precio,
				:total                     => detalle.total,
				:descuento                 => 0
			})
		end

		nota.create_nota(obj)


	end
	nil
end