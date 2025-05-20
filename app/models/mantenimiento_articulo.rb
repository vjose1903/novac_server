class MantenimientoArticulo < ApplicationRecord
  belongs_to :articulo
  belongs_to :user

  attribute :user

  def self.add_historico(parametros, contenidos, formulas)
    res = Response.new
    MantenimientoArticulo.transaction do

      historico                              = MantenimientoArticulo.new
      secuencia                              = "#{Time.now.to_i}#{parametros["id"]}"

      historico.articulo_id                  = parametros["id"]
      historico.user_id                      = get_current_user['id']
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
          historico["ant_medidaHijo"]        = contenido["medida"]
          historico["ant_costoHijo"]         = contenido["costo"]
          historico["ant_precioHijo"]        = contenido["precio"]
          historico["ant_cantidadHijo"]      = contenido["cantidad"]
          historico["ant_idHijo"]            = contenido["id"]
          historico["ant_referenciaHijo"]    = contenido["referencia"]
        else
          historico["ant_medidaPadre"]       = contenido["medida"]
          historico["ant_costoPadre"]        = contenido["costo"]
          historico["ant_precioPadre"]       = contenido["precio"]
          historico["ant_cantidadPadre"]     = contenido["cantidad"]
          historico["ant_idPadre"]           = contenido["id"]
          historico["ant_referenciaPadre"]   = contenido["referencia"]
        end
      end


      if historico.save!
        res_proceso = MantenimientoFormula.add_historico(formulas, secuencia)

        unless res_proceso.status_valid
          res.add_msgs(res_proceso.get_msgs)
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end

      else
        res.add_msgs(historico.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback if !historico.errors.empty? || !res.status_valid
    end
    return res
  end

  # 2021-12-27 09:53:06.892
  # 2021-12-23 14:43:02.006
  # ============================================================================================================================================================

  def self.get_historico_by_date_mayor_or_menor(date, articulo_id, operador, order)

    historico = MantenimientoArticulo
    .where("mantenimiento_articulos.created_at #{operador} '#{date}' AND mantenimiento_articulos.articulo_id = #{articulo_id}")
    .order("mantenimiento_articulos.id #{order}").limit(1)

    return historico
  end

  # ============================================================================================================================================================
  def self.get_one_articulo_by_date(date, articulo_id)

    fecha_factura                   = date.to_s.split(":")[0] + ":" + date.to_s.split(":")[1]
    fecha_factura_parsed            = fecha_factura + ":59"

    historico                       = []
    articulo                        = Articulo.find_by_id(articulo_id)
    fecha_ultima_edicion_articulo   = calculateDateUTC(articulo["updated_at"])

    if fecha_factura_parsed >= fecha_ultima_edicion_articulo
      # historico.push(Articulo.parseal(articulo))
      historico.push(articulo)
    else
      hist        = get_historico_by_date_mayor_or_menor(fecha_factura_parsed, articulo_id, "<=", "DESC")
      hist        = get_historico_by_date_mayor_or_menor(fecha_factura_parsed, articulo_id, ">=", "ASC")   if hist.blank?

      if hist.blank?
        # historico.push(Articulo.parseal(articulo))
        historico.push(articulo)
      else
        articulo  = crearArticuloHistorico(hist.first, articulo)
        historico.push(articulo)
      end
    end

    return historico
  end

  # ============================================================================================================================================================
  def self.crearArticuloHistorico(historico, articulo)

    contenidoArticulo = articulo.contenido_articulos
    formulaArticulo = articulo.formulas_productos_terminados

    articuloHistorico = {}
    articuloHistorico["id"]                     = articulo["id"]
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
    articuloHistorico["existencia"]             = articulo["existencia"]
    articuloHistorico["codigo"]                 = articulo["codigo"]
    articuloHistorico["fecha_ingreso"]          = articulo["fecha_ingreso"]
    articuloHistorico["imagen_id"]              = articulo["imagen_id"]
    articuloHistorico["calcular_saco"]          = articulo["calcular_saco"]

    contents = []

    if historico["ant_medidaHijo"] || historico["ant_medidaPadre"]
      contenidoArticulo.each do |contenido|
        conte = {}
        if contenido["referencia"]
          conte["costo"]          = historico["ant_costoHijo"]
          conte["precio"]         = historico["ant_precioHijo"]
          conte["cantidad"]       = historico["ant_cantidadHijo"]
          conte["medida"]         = historico["ant_medidaHijo"]
          conte["id"]             = contenido["id"]
          conte["referencia"]     = contenido["ant_referenciaHijo"]
          conte["condicion"]      = contenido["condicion"]
          conte["articulo_id"]    = contenido["articulo_id"]
        else
          conte["costo"]          = historico["ant_costoPadre"]
          conte["precio"]         = historico["ant_precioPadre"]
          conte["cantidad"]       = historico["ant_cantidadPadre"]
          conte["medida"]         = historico["ant_medidaPadre"]
          conte["articulo_id"]    = contenido["articulo_id"]
          conte["id"]             = contenido["id"]
          conte["referencia"]     = contenido["ant_referenciaPadre"]
          conte["condicion"]      = contenido["condicion"]
        end
        contents.push(ContenidoArticulo.new(conte))
      end
    end

    articuloHistorico["contenido_articulos"] = contents

    if historico["ant_isCombo"]
      fomulaS = []

      formulas = MantenimientoFormula.where({secuencia: historico["secuencia"]})
      formulaArticulo

      formulas.to_a.each do |f|
        puts "f ==> ".green + " #{f.to_json}"
        obj_formula = f.slice(:articulo_id, :articulo_combo, :cantidad, :costo, :precio, :medida)
        obj_formula["id"]               = f["formula_id"]

        fomulaS.push(FormulasProductosTerminado.new(obj_formula))
      end

      articuloHistorico["formulas_productos_terminados"] = fomulaS
    end

    return articuloHistorico
  end
end

# ============================================================================================================================================================
