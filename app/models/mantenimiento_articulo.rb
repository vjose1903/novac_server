class MantenimientoArticulo < ApplicationRecord
  belongs_to :articulo
  belongs_to :user

  attribute :user

  def self.get_historico_by_id_articulo(id)
    return my_query("SELECT * FROM mantenimiento_articulos WHERE articulo_id = #{id} ORDER BY created_at ASC")
  end

  def self.get_historico_by_date_menor(date, articulo_id)
    select_ = "select * ,ta.descripcion as descripcion"
    from_ = "from mantenimiento_articulos ma"
    joins_ = 'inner join tipo_articulos ta on ma."ant_tipoArticuloId"= ta.id'
    where_ = "where ma.created_at <= '#{date}' AND ma.articulo_id = #{articulo_id}"
    query = "#{select_} #{from_} #{joins_} #{where_}"
    return my_query(query)
  end

  # ============================================================================================================================================================

  def self.get_historico_by_date_mayor(date, articulo_id)
    select_ = "select * ,ta.descripcion as descripcion"
    from_ = "from mantenimiento_articulos ma"
    joins_ = 'inner join tipo_articulos ta on ma."ant_tipoArticuloId"= ta.id'
    where_ = "where ma.created_at >= '#{date}' AND ma.articulo_id = #{articulo_id}"
    query = "#{select_} #{from_} #{joins_} #{where_}"
    return my_query(query)
  end

  # ============================================================================================================================================================
  def self.get_one_articulo_by_date(date, articulo_id)
    
    fechaConHora = date.to_s.split(":")[0] + ":" + date.to_s.split(":")[1]
    
    historico = []
    articulo = Articulo.find_by_id(articulo_id)
    my_print_log("fechaConHora ==> ".red + "#{fechaConHora}")
    my_print_log("fecha articulo update ==> ".blue + "#{parsearDateTimeUTC(articulo["updated_at"])}")

    my_print_log("articulo ==> ".yellow + "#{articulo.to_json}")
    
    if fechaConHora + ":59" >= parsearDateTimeUTC(articulo["updated_at"])      
      historico.push(Articulo.parseal(articulo))
      
    else
      hist = get_historico_by_date_menor(fechaConHora + ":59", articulo_id)

      if hist.rows == []
        histM = get_historico_by_date_mayor(fechaConHora + ":00", articulo_id)
        if histM.rows == []
          historico.push(Articulo.parseal(articulo))
        else
          articulo = crearArticuloHistorico(histM[0], articulo)
          historico.push(Articulo.parsealHistorico(articulo))
        end
      else
        articulo = crearArticuloHistorico(hist[0], articulo)
        historico.push(Articulo.parsealHistorico(articulo))
      end
    end

    return historico
  end
  # ============================================================================================================================================================
  def self.get_all_articulos_by_date(date)
    historico = []

    Articulo.all.each do |articulo|
      hist = get_historico_by_date_menor(date + ":59", articulo["id"])

      if fechaConHora >= parsearDateTimeUTC(articulo["updated_at"])
        historico.push(Articulo.parseal(articulo))
      else
        if hist.rows == []
          histM = get_historico_by_date_mayor(date + ":00", articulo["id"])
          if histM.rows == []
            historico.push(Articulo.parseal(articulo))
          else
            articulo = crearArticuloHistorico(histM[0], articulo)
            historico.push(Articulo.parsealHistorico(articulo))
          end
        else
          articulo = crearArticuloHistorico(hist[0], articulo)
          historico.push(Articulo.parsealHistorico(articulo))
        end
      end
    end
    return historico
  end

  # ============================================================================================================================================================
  def self.crearArticuloHistorico(historico, articulo)
    contenidoArticulo = articulo.contenido_articulos

    articuloHistorico = {}
    articuloHistorico["id"] = articulo["id"]
    articuloHistorico["tipo_articulo_id"] = historico["ant_tipoArticuloId"]
    articuloHistorico["nombre"] = historico["ant_nombre"]
    articuloHistorico["costo_principal"] = historico["ant_costoP"]
    articuloHistorico["precio_principal"] = historico["ant_precioP"]
    articuloHistorico["existencia"] = articulo["existencia"]
    articuloHistorico["codigo"] = articulo["codigo"]
    articuloHistorico["fecha_ingreso"] = articulo["fecha_ingreso"]
    articuloHistorico["medida"] = historico["ant_medida"]
    articuloHistorico["is_detallable"] = historico["ant_isDetallable"]
    articuloHistorico["created_at"] = articulo["created_at"]
    articuloHistorico["updated_at"] = articulo["updated_at"]
    articuloHistorico["imagen_id"] = articulo["imagen_id"]
    articuloHistorico["aviso_existencia"] = historico["ant_alertaExistencia"]
    articuloHistorico["medida_alerta"] = historico["ant_medidaAlerta"]
    articuloHistorico["calcular_itbis"] = historico["ant_calcularItbis"]
    articuloHistorico["is_combo"] = historico["ant_isCombo"]
    articuloHistorico["otros_costos"] = historico["ant_otrosCostos"]
    articuloHistorico["is_materia_prima"] = historico["is_materia_prima"]
    articuloHistorico["vendido_en"] = historico["vendido_en"]

    contents = []
    contenidoArticulo.each do |contenido|
      conte = {}
      if contenido["referencia"]
        conte["id"] = contenido["id"]
        conte["articulo_id"] = contenido["articulo_id"]
        conte["referencia"] = contenido["referencia"]
        conte["costo"] = historico["ant_costoHijo"]
        conte["precio"] = historico["ant_precioHijo"]
        conte["cantidad"] = historico["ant_cantidadHijo"]
        conte["condicion"] = contenido["condicion"]
        conte["medida"] = historico["ant_medidaHijo"]
        conte["created_at"] = contenido["created_at"]
        conte["updated_at"] = contenido["updated_at"]
      else
        conte["id"] = contenido["id"]
        conte["articulo_id"] = contenido["articulo_id"]
        conte["referencia"] = contenido["referencia"]
        conte["costo"] = historico["ant_costoPadre"]
        conte["precio"] = historico["ant_precioPadre"]
        conte["cantidad"] = historico["ant_cantidadPadre"]
        conte["condicion"] = contenido["condicion"]
        conte["medida"] = historico["ant_medidaPadre"]
        conte["created_at"] = contenido["created_at"]
        conte["updated_at"] = contenido["updated_at"]
      end
      contents.push(conte)
    end
    articuloHistorico["contenido_articulos"] = contents

    if historico["ant_isCombo"]
      fomulaS = []
      formulas = MantenimientoFormula.get_mantenimiento_formulas_by_secuencia(historico["secuencia"])
      formulas.each do |f|
        obj = { "articulo_combo": f["articulo_combo"],
               "cantidad": f["cantidad"],
               "costo": f["costo"],
               "precio": f["precio"] }
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
