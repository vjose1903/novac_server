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
      work[:actualmente] = { estado: "Cancelado", color: "red", id: -1 }
    else
      if trabajo["entregado"]
        work[:actualmente] = { estado: "Entregado", color: "white", id: 3 }
      else
        if !trabajo["empezado"] && !trabajo["terminado"]
          work[:actualmente] = { estado: "En espera", color: "grey", id: 0 }
        elsif trabajo["empezado"] && !trabajo["terminado"]
          work[:actualmente] = { estado: "Empezado", color: "yellow", id: 1 }
        elsif trabajo["empezado"] && trabajo["terminado"]
          work[:actualmente] = { estado: "Terminado", color: "green", id: 2 }
        end
      end
    end
    puts work.to_json.blue
    return work
  end
  def self.parsearTrabajosFiltro(trabajos)
    trabajos.each do |work|
      work["marca"] = { id: work["marca_id"], descripcion: work["marca_descripcion"] }
      work["modelo"] = { id: work["modelo_id"], descripcion: work["modelo_descripcion"] }
      work["cliente"] = { id: work["cliente_id"], nombre: work["cliente_nombre"], apellido: work["cliente_apellido"],
                         documento_de_identidad: { id: work["cliente_doc_id"], documento: work["cliente_doc_documento"], descripcion: work["cliente_doc_descripcion"] } }

      if work["cancelado"]
        work["actualmente"] = { estado: "Cancelado", color: "red", id: -1 }
      else
        if work["entregado"]
          work["actualmente"] = { estado: "Entregado", color: "white", id: 3 }
        else
          if !work["empezado"] && !work["terminado"]
            work["actualmente"] = { estado: "En espera", color: "grey", id: 0 }
          elsif work["empezado"] && !work["terminado"]
            work["actualmente"] = { estado: "Empezado", color: "yellow", id: 1 }
          elsif work["empezado"] && work["terminado"]
            work["actualmente"] = { estado: "Terminado", color: "green", id: 2 }
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
end
