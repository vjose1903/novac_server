module Balances
	def self.get_balances_and_facturas(params, paginate_options, query, detalleKey)
		paginate_class               = Paginator.new(paginate_options)
		res                          = Response.new()

		factura_a_buscar             = params[:factura_a_buscar]
		next_page                    = nil

		data       = { balances: { total_facturado: 0, notas_credito: 0, notas_debito: 0, debiendo: 0, abonado: 0 }, facturas: [], page: paginate_class.get_page }.with_indifferent_access

		facturas   = CabeceraFactura.where(query).order('id DESC').includes(CabeceraFactura.models_includes).each do | factura |

			data[:balances][:total_facturado] += factura.total_factura
			data[:balances][:debiendo]        += factura.balance

			facturas_aplicadas                 = factura.facturas_aplicadas
			notas_credito                      = facturas_aplicadas.select { | factura_aplicada | factura_aplicada.nota.tipo_factura_id == TiposNotasId.credito }
			notas_debito                       = facturas_aplicadas.select { | factura_aplicada | factura_aplicada.nota.tipo_factura_id == TiposNotasId.debito }

			data[:balances][:notas_credito]   += notas_credito.reduce(0) { | acu, item |  (item.total).abs + acu }
			data[:balances][:notas_debito]    += notas_debito.reduce(0) { | acu, item |  (item.total).abs + acu }

			detalles                           = factura.send(detalleKey)
			data[:balances][:abonado]         += detalles.reduce(0) { | acu, item |  item.deposito + acu }

		end

		unless factura_a_buscar.nil?
			index_factura_a_buscar   = facturas.index { |fact| "#{fact.id}" == "#{factura_a_buscar}" }

			unless index_factura_a_buscar.nil?
				next_page              = (index_factura_a_buscar / paginate_class.get_per_page.to_f).ceil
				next_page = 1 if next_page == 0

				paginate_class.set_page(next_page)
				data[:page]            = paginate_class.get_page
			end
		end

		paginate_class.paginate_data(facturas)

		data[:facturas]         = paginate_class.data_paginated
		data[:facturas][:data]  = serialize_parser(paginate_class.get_data, {all: true})

		res.set_data(data)
		return res

	end
end

