class Trabajo < ApplicationRecord
  belongs_to :cliente
  belongs_to :marca
  belongs_to :modelo

  def self.filtrarTrabajo(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT t.cliente_id,t.descripcion, t.empezado, t.notas, t.estado, t.fecha_cancelado, t.id, t.identificador, t.terminado, t.tiene_bateria, t.tipo_trabajo,
    CASE 
      WHEN t.tipo_trabajo = 'reparacion' THEN 'Reparación'
      WHEN t.tipo_trabajo = 'desbloqueo'THEN 'Desbloqueo'
    END as tipo_trabajo_mostrar,
    c.nombre as cliente_nombre, c.apellido as cliente_apellido , doc.documento as cliente_doc_documento  , doc.id as cliente_doc_id , doc.descripcion as cliente_doc_descripcion , mo.descripcion as modelo_descripcion, mo.id as modelo_id , ma.descripcion as marca_descripcion , ma.id as marca_id"
    from_ = "FROM trabajos t "
    joins_ = "inner join clientes c on t.cliente_id = c.id
              inner join marcas ma on t.marca_id = ma.id
              inner join modelos mo on t.modelo_id = mo.id
              left join documentos_de_identidad doc on doc.cliente_id = t.cliente_id "
    where_ = "where lower(t.identificador || ' ' || t.descripcion || ' ' || t.tipo_trabajo || ' ' || c.nombre || ' ' || c.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%') AND t.estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.agregarActualmente(trabajo)
    work = trabajo.attributes
    if trabajo["cancelado"]
      work[:actualmente] = { estado: "Cancelado", color: "bg-red", id: -1 }
    else
      if trabajo["entregado"]
        work[:actualmente] = { estado: "Entregado", color: "bg-white", id: 3 }
      else
        if !trabajo["empezado"] && !trabajo["terminado"]
          work[:actualmente] = { estado: "En espera", color: "bg-grey", id: 0 }
        elsif trabajo["empezado"] && !trabajo["terminado"]
          work[:actualmente] = { estado: "Empezado", color: "bg-yellow", id: 1 }
        elsif trabajo["empezado"] && trabajo["terminado"]
          work[:actualmente] = { estado: "Terminado", color: "bg-green", id: 2 }
        end
      end
    end
    puts work.to_json.blue
    return work
  end

  # =====================================================================================================================

  def self.parsearTrabajosFiltro(trabajos)
    trabajos.each do |work|
      work["marca"] = { id: work["marca_id"], descripcion: work["marca_descripcion"] }
      work["modelo"] = { id: work["modelo_id"], descripcion: work["modelo_descripcion"] }
      work["cliente"] = { id: work["cliente_id"], nombre: work["cliente_nombre"], apellido: work["cliente_apellido"],
                         documento_de_identidad: { id: work["cliente_doc_id"], documento: work["cliente_doc_documento"], descripcion: work["cliente_doc_descripcion"] } }

      if work["cancelado"]
        work["actualmente"] = { estado: "Cancelado", color: "bg-red", id: -1 }
      else
        if work["entregado"]
          work["actualmente"] = { estado: "Entregado", color: "bg-white", id: 3 }
        else
          if !work["empezado"] && !work["terminado"]
            work["actualmente"] = { estado: "En espera", color: "bg-grey", id: 0 }
          elsif work["empezado"] && !work["terminado"]
            work["actualmente"] = { estado: "Empezado", color: "bg-yellow", id: 1 }
          elsif work["empezado"] && work["terminado"]
            work["actualmente"] = { estado: "Terminado", color: "bg-green", id: 2 }
          end
        end
      end

      work.delete("marca_descripcion")

      work.delete("modelo_descripcion")

      work.delete("cliente_nombre")
      work.delete("cliente_apellido")
      work.delete("cliente_doc_id")
      work.delete("cliente_doc_descripcion")
      work.delete("cliente_doc_documento")
    end

    return trabajos
  end

  # =====================================================================================================================
  def self.cancelar_trabajo(trabajo)
    work = Trabajo.find_by_id(trabajo["id"])

    obj_cancel = {
      'estado': false,
      'fecha_cancelado': trabajo["fecha_cancelado"],
    }

    if work.update(obj_cancel)
      res = { obj: work, error: false, msg: "", status: 200 }
    else
      res = { obj: "", error: true, msg: work.errors, status: :unprocessable_entity }
    end

    return res
  end

  # =====================================================================================================================
  def self.reactivar_trabajo(trabajo)
    work = Trabajo.find_by_id(trabajo["id"])

    obj_reactivate = {
      'estado': false,
      'fecha_reactivado': trabajo["fecha_reactivado"],
    }

    if work.update(obj_reactivate)
      res = { obj: work, error: false, msg: "", status: 200 }
    else
      res = { obj: "", error: true, msg: work.errors, status: :unprocessable_entity }
    end

    return res
  end

  # =====================================================================================================================
  def self.cambiar_estado_trabajo(trabajo)
    work = Trabajo.find_by_id(trabajo["id"])

    obj = {}

    obj["empezado"] = false
    obj["terminado"] = false
    obj["entregado"] = false
    msg = ""
    if trabajo["num"] == 1
      obj["empezado"] = true
      msg = "Trabajo empezado."
    elsif trabajo["num"] == 2
      obj["terminado"] = true
      obj["empezado"] = true
      msg = "Trabajo terminado."
    elsif trabajo["num"] == 3
      obj["entregado"] = true
      msg = "Trabajo entregado."
    else
      msg = "Trabajo en espera."
    end

    if work.update(obj)
      res = { obj: work, error: false, msg: msg, status: 200 }
    else
      res = { obj: "", error: true, msg: work.errors, status: :unprocessable_entity }
    end

    return res
  end
end
