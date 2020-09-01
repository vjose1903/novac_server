class Trabajo < ApplicationRecord
  belongs_to :cliente
  belongs_to :marca
  belongs_to :modelo

  def self.filtrarTrabajo(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT t.cliente_id,t.descripcion, t.notas, t.estado, t.estado_actual, t.fecha_cancelado, t.id, t.identificador, t.tiene_bateria, t.tipo_trabajo,
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

    where_ = "where lower(t.identificador || ' ' || t.descripcion || ' ' || t.tipo_trabajo || ' ' || c.nombre || ' ' || c.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%') and t.estado_actual >= 0 or ( t.estado_actual = -1 and DATE_PART('day',current_timestamp - t.fecha_cancelado) < 1) AND t.estado = true"
    order_ = "ORDER BY t.id ASC"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.agregarActualmente(trabajo, manual = false)
    if manual
      work = trabajo
    else
      work = trabajo.attributes
    end

    if work["estado_actual"] == -1
      work["actualmente"] = { estado: "Cancelado", color: "bg-red", id: -1 }
    elsif work["estado_actual"] == 0
      work["actualmente"] = { estado: "En espera", color: "bg-grey", id: 0 }
    elsif work["estado_actual"] == 1
      work["actualmente"] = { estado: "Empezado", color: "bg-yellow", id: 1 }
    elsif work["estado_actual"] == 2
      work["actualmente"] = { estado: "Terminado", color: "bg-green", id: 2 }
    elsif work["estado_actual"] == 3
      work["actualmente"] = { estado: "Entregado", color: "bg-white", id: 3 }
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

      work = Trabajo.agregarActualmente(work, true)

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
      'estado_actual': -1,
      'fecha_cancelado': DateTime.now,
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
      'estado_actual': 0,
      'fecha_cancelado': nil,
      'fecha_reactivado': DateTime.now,
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

    obj = { estado_actual: trabajo["num"] }

    msg = ""
    if trabajo["num"] == 1
      msg = "Trabajo empezado."
    elsif trabajo["num"] == 2
      msg = "Trabajo terminado."
    elsif trabajo["num"] == 3
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
