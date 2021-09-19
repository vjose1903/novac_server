class MantenimientoArticulo < ApplicationRecord
  belongs_to :articulo
  belongs_to :user

  attribute :user

  def self.add_historico(parametros, contenidos, formulas)
    MantenimientoArticulo.transaction do
      res = Response.new

      usuario_actual         = get_current_user
      historico              = MantenimientoArticulo.new()
      secuencia              = (MantenimientoArticulo.last.id + 1) || 0


      historico.articulo_id                  = parametros["id"]
      historico.user_id                      = usuario_actual.id
      historico.ant_nombre                   = parametros["nombre"]
      historico.ant_tipoArticuloId           = parametros["tipo_articulo_id"]
      historico.ant_medida                   = parametros["medida"]
      historico.ant_medidaAlerta             = parametros["medida_alerta"]
      historico.ant_costoP                   = parametros["costo_principal"]
      historico.ant_precioP                  = parametros["precio_principal"]
      historico.ant_alertaExistencia         = parametros["aviso_existencia"]
      historico.ant_isDetallable             = parametros["is_detallable"]
      historico.ant_calcularItbis            = parametros["calcular_itbis"]
      historico.ant_isCombo                  = parametros["is_combo"]
      historico.vendido_en                   = parametros["vendido_en"]
      historico.is_materia_prima             = parametros["is_materia_prima"]
      historico.ant_otrosCostos              = parametros["otros_costos"] 
      historico.calcular_saco                = parametros["calcular_saco"] 
      historico.secuencia                    = secuencia


      contenidos.to_a.each do |contenido|
        if contenido["referencia"]
          historico["ant_medidaHijo"]         = contenido["medida"]
          historico["ant_costoHijo"]          = contenido["costo"]
          historico["ant_precioHijo"]         = contenido["precio"]
          historico["ant_cantidadHijo"]       = contenido["cantidad"]
          historico["ant_idHijo"]             = contenido["id"]
          historico["ant_referenciaHijo"]     = contenido["referencia"]
        else
          historico["ant_medidaPadre"]        = contenido["medida"]
          historico["ant_costoPadre"]         = contenido["costo"]
          historico["ant_precioPadre"]        = contenido["precio"]
          historico["ant_cantidadPadre"]      = contenido["cantidad"]
          historico["ant_idPadre"]            = contenido["id"]
          historico["ant_referenciaPadre"]    = contenido["referencia"]
        end
      end
      
      puts "historico ".red  + "#{historico.to_json}"
      puts "historico.errors ".red  + "#{historico.errors.to_json}"

      res_formula = MantenimientoFormula.add_historico(formulas, secuencia)

      unless res_formula.status_valid && historico.save! 
        errores = historico.errors.to_a.concat(res_formula.get_msgs)
        res.add_msgs(errores)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      return res 
    end
  end
  
  # ============================================================================================================================================================
  
  def self.get_historico_by_date_mayor_or_menor(date, articulo_id, operador, order)
    select_ = "select * ,ta.descripcion as descripcion"
    from_ = "from mantenimiento_articulos ma"
    joins_ = 'inner join tipo_articulos ta on ma."ant_tipoArticuloId"= ta.id'
    where_ = "where ma.created_at #{operador} '#{date}' AND ma.articulo_id = #{articulo_id}"
    order_ = "ORDER BY ma.id #{order}"
    query = "#{select_} #{from_} #{joins_} #{where_} #{order_} limit 1"
    return my_query(query)
  end

  # ============================================================================================================================================================
  def self.get_one_articulo_by_date(date, articulo_id)
    fecha_factura = date.to_s.split(":")[0] + ":" + date.to_s.split(":")[1]
    historico = []
    articulo = Articulo.find_by_id(articulo_id)
    fecha_ultima_edicion = parsearDateTimeUTC(articulo["updated_at"])
    if fecha_factura + ":59" >= fecha_ultima_edicion
      historico.push(Articulo.parseal(articulo))
    else
      
      hist = get_historico_by_date_mayor_or_menor(fecha_factura + ":59", articulo_id, "<=", "DESC")
      hist = get_historico_by_date_mayor_or_menor(fecha_factura + ":59", articulo_id, ">=", "ASC") if hist.empty?

      if hist.rows == []
          historico.push(Articulo.parseal(articulo))
      else
        articulo = crearArticuloHistorico(hist[0], articulo)
        historico.push(Articulo.parsealHistorico(articulo))
      end
    end

    return historico
  end

  # ============================================================================================================================================================
  def self.crearArticuloHistorico(historico, articulo)
    
    
    contenidoArticulo = articulo.contenido_articulos
    
    articuloHistorico = {}
    articuloHistorico["tipo_articulo_id"]       = historico["ant_tipoArticuloId"]
    articuloHistorico["nombre"]                 = historico["ant_nombre"]
    articuloHistorico["costo_principal"]        = historico["ant_costoP"]
    articuloHistorico["precio_principal"]       = historico["ant_precioP"]
    articuloHistorico["medida"]                 = historico["ant_medida"]
    articuloHistorico["is_detallable"]          = historico["ant_isDetallable"]
    articuloHistorico["aviso_existencia"]       = historico["ant_alertaExistencia"]
    articuloHistorico["medida_alerta"]          = historico["ant_medidaAlerta"]
    articuloHistorico["calcular_itbis"]         = historico["ant_calcularItbis"]
    articuloHistorico["is_combo"]               = historico["ant_isCombo"]
    articuloHistorico["otros_costos"]           = historico["ant_otrosCostos"]
    articuloHistorico["is_materia_prima"]       = historico["is_materia_prima"]
    articuloHistorico["vendido_en"]             = historico["vendido_en"]
    articuloHistorico["id"]                     = articulo["id"]
    articuloHistorico["existencia"]             = articulo["existencia"]
    articuloHistorico["codigo"]                 = articulo["codigo"]
    articuloHistorico["fecha_ingreso"]          = articulo["fecha_ingreso"]
    articuloHistorico["created_at"]             = articulo["created_at"]
    articuloHistorico["updated_at"]             = articulo["updated_at"]
    articuloHistorico["imagen_id"]              = articulo["imagen_id"]
    articuloHistorico["calcular_saco"]          = articulo["calcular_saco"]
    
    contents = []
    my_print_log("historico ==> #{historico.to_json}")
    my_print_log("contenidoArticulo ==> #{contenidoArticulo.to_json}")

    if historico["ant_medidaHijo"] || historico["ant_medidaPadre"]
      contenidoArticulo.each do |contenido|
        conte = {}
        if contenido["referencia"]
          conte["costo"]          = historico["ant_costoHijo"]
          conte["precio"]         = historico["ant_precioHijo"]
          conte["cantidad"]       = historico["ant_cantidadHijo"]
          conte["medida"]         = historico["ant_medidaHijo"]
          conte["id"]             = contenido["id"]
          conte["referencia"]     = contenido["referencia"]
          conte["condicion"]      = contenido["condicion"]
          conte["articulo_id"]    = contenido["articulo_id"]
          conte["created_at"]     = contenido["created_at"]
          conte["updated_at"]     = contenido["updated_at"]
        else
          conte["costo"]          = historico["ant_costoPadre"]
          conte["precio"]         = historico["ant_precioPadre"]
          conte["cantidad"]       = historico["ant_cantidadPadre"]
          conte["medida"]         = historico["ant_medidaPadre"]
          conte["articulo_id"]    = contenido["articulo_id"]
          conte["id"]             = contenido["id"]
          conte["referencia"]     = contenido["referencia"]
          conte["condicion"]      = contenido["condicion"]
          conte["created_at"]     = contenido["created_at"]
          conte["updated_at"]     = contenido["updated_at"]
        end
        contents.push(conte)
      end
    end


    articuloHistorico["contenido_articulos"] = contents
    
    if historico["ant_isCombo"]
      fomulaS = []
      formulas = MantenimientoFormula.find_by_secuencia(historico["secuencia"])
      formulas.each do |f|
        obj = { 
          :articulo_combo      => f["articulo_combo"],
          :cantidad            => f["cantidad"],
          :costo               => f["costo"],
          :precio              => f["precio"] 
        }
      end

      articuloHistorico["formulas_productos_terminados"] = fomulaS
    end

    unless articuloHistorico["descripcion"]
      des = TipoArticulo.find_by_id(articuloHistorico["tipo_articulo_id"])
      articuloHistorico["descripcion"] = des["descripcion"]
    end

    return articuloHistorico
  end
end

# ============================================================================================================================================================
