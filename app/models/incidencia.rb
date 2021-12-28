class Incidencia < ApplicationRecord

    belongs_to :origen, polymorphic: true

    def self.crear_actualizar_incidencia(params, padre, is_save=false)
        res = Response.new
    
        unless params["id"]
          incidencia              = DocumentoDeIdentidad.new
        else
          incidencia              = DocumentoDeIdentidad.find_by_id(params["id"])
        end
    
        incidencia.descripcion    = params["descripcion"]
        incidencia.origen         = padre
    
        incidencia.valid?
    
        if incidencia.errors.empty? && (!is_save || (is_save && incidencia.save!))
          res.set_data(incidencia)
        else
          res.add_msgs(incidencia.errors.to_a)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
    
        return res
      end
    
      def self.validar_e_inicializar(items, padre, save)
        res_valid = Response.new
        array_valid=[]
        
        items.each do |item|
          res_temp = self.crear_actualizar_incidencia(item, padre, !item[:id].nil?)
    
          if res_temp.status_valid
            array_valid.push(res_temp.get_data)
          else
            return res_temp 
          end
        end
    
        res_valid.set_data array_valid
        return res_valid
      end

end
