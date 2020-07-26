class Trabajo < ApplicationRecord
  belongs_to :cliente
  belongs_to :marca
  belongs_to :modelo

  def self.filtrarTrabajo(arg)
    arg = arg === " " ? "" : arg
    select_ = "SELECT t.*, c.nombre as cliente_nombre, c.apellido as cliente_apellido , doc.documento as cliente_doc_documento  , doc.id as cliente_doc_id , doc.descripcion as cliente_doc_descripcion , mo.descripcion as modelo_descripcion, mo.id as modelo_id , ma.descripcion as marca_descripcion , ma.id as marca_id"
    from_ = "FROM trabajos t "
    joins_ = "inner join clientes c on t.cliente_id = c.id
              inner join marcas ma on t.marca_id = ma.id
              inner join modelos mo on t.modelo_id = mo.id
              inner join documentos_de_identidad doc on doc.cliente_id = t.cliente_id "
    where_ = "where lower(t.identificador || ' ' || t.descripcion || ' ' || t.tipo_trabajo || ' ' || c.nombre || ' ' || c.apellido || ' ' || coalesce(doc.documento, '') ) like lower('%#{arg}%') AND estado = true"

    query = "#{select_} #{from_} #{joins_} #{where_}"

    my_query(query)
  end

  # =====================================================================================================================

  def self.parsearTrabajosFiltro(trabajos)
    trabajos.each do |work|
      work["marca"] = { id: work["marca_id"], descripcion: work["marca_descripcion"] }
      work["modelo"] = { id: work["modelo_id"], descripcion: work["modelo_descripcion"] }
      work["cliente"] = { id: work["cliente_id"], nombre: work["cliente_nombre"], apellido: work["cliente_apellido"],
                         documento_de_identidad: { id: work["cliente_doc_id"], documento: work["cliente_doc_documento"], descripcion: work["cliente_doc_descripcion"] } }

      work.delete("marca_descripcion")
      work.delete("marca_id")

      work.delete("modelo_descripcion")
      work.delete("modelo_id")

      work.delete("cliente_nombre")
      work.delete("cliente_apellido")
      work.delete("cliente_doc_id")
      work.delete("cliente_doc_descripcion")
      work.delete("cliente_doc_documento")
    end

    return trabajos
  end
end
