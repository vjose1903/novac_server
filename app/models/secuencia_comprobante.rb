class SecuenciaComprobante < ApplicationRecord

		def self.get_paquete_rnc_by_estado(tipo_factura_id, estado)
			puts ' -------------- Inicio get_paquete_rnc_by_estado -------------- '
			
			tipoFac= TipoFactura.find_by_id(tipo_factura_id)
			
			select_ = "select *"
			from_ = "from secuencia_comprobantes"
			where_ = "where estado = #{estado} AND usado = #{false} AND tipo_factura_id = #{tipo_factura_id}"
			order_ = "ORDER BY created_at ASC LIMIT 1"
			query = "#{select_} #{from_} #{where_} #{order_}"
			paquete = ActiveRecord::Base.connection.exec_query(query)[0]
			
			if paquete == [] || paquete == nil
				puts ' -------------- fin get_paquete_rnc_by_estado -------------- '
				existen = ver_si_existen_paquetes_previos(tipo_factura_id)
				if existen
					return { :error => true, :msg => "Los paquete de comprobantes para #{tipoFac['descripcion']}, se han agotado debe de comprar mas.", :body => [], :status => 404 } #respuesta correcta
				else
					return { :error => true, :msg => "No se han comprado paquete de comprobantes para #{tipoFac['descripcion']}", :body => [], :status => 404 } #respuesta correcta
				end
				#
			elsif paquete['secuencia'] == paquete['hasta']
				puts ' -------------- fin get_paquete_rnc_by_estado -------------- '
				return { :error => false, :msg => "Ultimo comprobante de este paquete", :body => paquete, :status => 200 } #respuesta correcta
				#
			elsif paquete['secuencia'] > paquete['hasta']
				
				select_ = "select *"
				from_ = "from secuencia_comprobantes"
				where_ = "where estado = #{false} AND usado = #{false} AND tipo_factura_id = #{tipo_factura_id}"
				order_ = "ORDER BY created_at ASC LIMIT 1"
				newQuery = "#{select_} #{from_} #{where_} #{order_}"
				nuevoPaquete = ActiveRecord::Base.connection.exec_query(newQuery)[0]
				
				
				
				if nuevoPaquete == [] || nuevoPaquete == nil
					puts ' -------------- fin get_paquete_rnc_by_estado -------------- '
					return { :error => true, :msg => "Los paquete de comprobantes para #{tipoFac['descripcion']}, se han agotado debe de comprar mas.", :body => [], :status => 404 } #respuesta correcta
				else
					# return { :error => true, :msg => "Existen errores en la base de datos, secuencia no pertene al paquete de NCF seleccionado", :body => [], :status => 404 } #respuesta correcta
					puts ' -------------- fin get_paquete_rnc_by_estado -------------- '
					return { :error => false, :msg => "siguiente paquete", :body => nuevoPaquete, :status => 200 } #respuesta correcta
				end
				#
			else
				puts ' -------------- fin get_paquete_rnc_by_estado -------------- '
					return { :error => false, :msg => "correcto", :body => paquete, :status => 200 } #respuesta correcta
				end
    end
		# ============================================================================================================================================================
		def self.get_paquetes_por_activar(tipo_factura_id)
			puts ' -------------- Inicio get_paquetes_por_activar -------------- '
			tipoFac= TipoFactura.find_by_id(tipo_factura_id)
			
			select_ = "select *"
			from_ = "from secuencia_comprobantes"
			where_ = "where estado = #{false} AND usado != #{true} AND tipo_factura_id = #{tipo_factura_id}"
			order_ = "ORDER BY created_at ASC LIMIT 1"
			newQuery = "#{select_} #{from_} #{where_} #{order_}"
			nuevoPaquete = ActiveRecord::Base.connection.exec_query(newQuery)[0]
			
			if nuevoPaquete == [] || nuevoPaquete == nil
				puts ' -------------- fin get_paquetes_por_activar -------------- '
				return { :continuar => false} #respuesta correcta
				
			else
				puts ' -------------- fin get_paquetes_por_activar -------------- '
				return { :continuar => true, :body=> nuevoPaquete} #respuesta correcta
			end
			
    end
		# ============================================================================================================================================================
		def self.aumentar_secuencia(paquete_id)
			puts ' -------------- inicio aumentar_secuencia -------------- '
			paquete = SecuenciaComprobante.find_by_id(paquete_id)
			
			sigue = true
			
			if paquete['secuencia'] == paquete['hasta']
				nuevoPac = get_paquetes_por_activar(paquete['tipo_factura_id'])
				
				if nuevoPac[:continuar]
					newPac = SecuenciaComprobante.find_by_id(nuevoPac[:body]["id"])
					unless newPac.update({ estado: true })
						sigue = false
					end
				end
				
				paquete.update({ estado: false, usado: true })
				
			else
				unless paquete.update({ secuencia: paquete[:secuencia]+1 })
					sigue = false
				end
			end
			
			puts ' -------------- fin aumentar_secuencia -------------- '
			return sigue
		end
		
		# ============================================================================================================================================================
		
		def self.ver_si_existen_paquetes_previos(tipo_factura_id)
			select_ = "select *"
			from_ = "from secuencia_comprobantes"
			where_ = "where estado = false AND usado = true AND tipo_factura_id = #{tipo_factura_id}"
			query = "#{select_} #{from_} #{where_}"
			paquete = ActiveRecord::Base.connection.exec_query(query)[0]

			if paquete == [] || paquete == nil
				return false
			else
				return true
			end
    end
		# ============================================================================================================================================================
		
end
