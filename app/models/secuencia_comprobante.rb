class SecuenciaComprobante < ApplicationRecord

  # =========================================================================================================================================================

  def self.create_update_ncf(params , is_save=false)
    res                            = Response.new
    res_valid                      = Response.new
    SecuenciaComprobante.transaction do

      ncf                      = SecuenciaComprobante.where(:id => params["id"]).first_or_create

      ncf.tipo_factura_id      = params["tipo_factura_id"]
      ncf.secuencia            = params["secuencia"]
      ncf.referencia           = params["referencia"]
      ncf.desde                = params["desde"]
      ncf.hasta                = params["hasta"]
      ncf.fecha_compra         = params["fecha_compra"]
      ncf.fecha_valida         = params["fecha_valida"]
      ncf.estado               = params["estado"]
      ncf.usado                = params["usado"]

      ncf.valid?

			if ncf.desde > ncf.hasta
				res.add_msg("El inicio del paquete no puede ser mayor al final del mismo.")
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end

			if ncf.desde == ncf.hasta
				res.add_msg("El final del paquete debe de ser mayor al inicio del mismo.")
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end

			if ncf.estado &&  ncf.desde != ncf.desde
				res.add_msg("Este paquete ya esta en uso no puede cambiar el inicio del paquete.")
				res.set_status(HTTP_STATUS_CODE[:conflict])
			end

      if ncf.errors.empty? && res.status_valid
        res_valid = SecuenciaComprobante.validar_rango(ncf['id'], ncf, 'new')

        if res_valid.status_valid && ncf.save!
          res.set_data(serialize_parser(ncf, {all: true}))

          action = params["id"] ? 'actualizado' : 'creado'
          res.add_msg("Paquete de comprobantes #{action} correctamente.")
        end
      end

      if !ncf.errors.empty? || !res.status_valid || !res_valid.status_valid
        res.add_msgs(res_valid.get_msgs)
        res.add_msgs(ncf.errors.to_a)
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

      raise ActiveRecord::Rollback unless res.status_valid
    end

    return res
  end

  # ============================================================================================================================================================
  def self.get_paquete_rnc_by_estado(tipo_factura_id, estado)
    res = Response.new

    tipoFac = TipoFactura.find_by_id(tipo_factura_id)

    paquete = SecuenciaComprobante
    .select("secuencia_comprobantes.* ,true as is_paquete")
    .where("estado = #{estado} AND usado = false AND tipo_factura_id = #{tipo_factura_id}")
    .order("created_at ASC").limit(1)

    if paquete.blank?
      res_siguientes = ver_si_existen_paquetes_posteriores(tipo_factura_id)

      if res_siguientes.status_valid
        res_activar = activar_nuevo_paquete(tipo_factura_id, res_siguientes.get_data)
        return res_activar
      end

      res_anteriores = ver_si_existen_paquetes_previos(tipo_factura_id)

      if res_anteriores.status_valid
        res.add_msg("Los paquete de comprobantes para #{tipoFac["descripcion"]}, se han agotado debe de solicitar mas.")
      else
        res.add_msg("No se han solicitado paquetes de comprobantes para #{tipoFac["descripcion"]}.")
      end

      res.set_status(HTTP_STATUS_CODE[:conflict])
      return res
    else
      res.set_data(paquete.first)
      return res
    end

  end

  # ============================================================================================================================================================

  def self.filtrar_ncf(arg)

    arg = arg === " " ? "" : arg

    select_ = "SELECT sc.*"
    from_ = "FROM secuencia_comprobantes sc"
    joins_ = "inner join tipo_facturas tf on sc.tipo_factura_id = tf.id"
    where_ = "where lower(tf.descripcion  || ' ' || desde || ' ' || hasta) like lower('%#{arg}%')"
    order_ = "ORDER BY sc.id DESC"

    query = "#{select_} #{from_} #{joins_} #{where_} #{order_}"

    my_query(query)
  end

  # ============================================================================================================================================================
  def self.get_paquetes_por_activar(tipo_factura_id)
    res = Response.new

    paquete = SecuenciaComprobante
    .select("secuencia_comprobantes.* ,true as is_paquete")
    .where("estado = false AND usado = false AND tipo_factura_id = #{tipo_factura_id}")
    .order("created_at ASC").limit(1)

    unless paquete.blank?
      res.set_data(paquete.first)
    else
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================================
  def self.aumentar_secuencia_comprobante(paquete_id)
    res              = Response.new

    paquete          = SecuenciaComprobante.find_by_id(paquete_id)

    if paquete["secuencia"] == paquete["hasta"]
      res_nuevo      = get_paquetes_por_activar(paquete["tipo_factura_id"])

      if res_nuevo.status_valid
        newPac       = res_nuevo.get_data

        unless newPac.update({ estado: true })
          res.add_msg("Error activando nuevo paquete de comprobantes.")
          res.set_status(HTTP_STATUS_CODE[:conflict])
        end
      end

      paquete.update({ estado: false, usado: true })
    else
      unless paquete.update({ secuencia: paquete[:secuencia] + 1 })
        res.add_msg("Error aumentando el paquete de comprobantes.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

  # ============================================================================================================================================================
  def self.activar_nuevo_paquete(tipo_factura, nuevo_paquete = {})
    res = Response.new


    res_nuevo = get_paquetes_por_activar(tipo_factura) if nuevo_paquete.blank?

    if !nuevo_paquete.blank? || res_nuevo.status_valid
      newPac = nuevo_paquete.blank? ? res_nuevo.get_data : nuevo_paquete
      if newPac.update({ estado: true })
        res.set_data(newPac)
      else
        res.add_msg("Error activando el siguiente paquete de comprobantes registrado.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end
    end

    return res
  end

  # ============================================================================================================================================================
  def self.ver_si_existen_paquetes_previos(tipo_factura_id)
    res = Response.new

    paquete = SecuenciaComprobante.where("estado = false AND usado = true AND tipo_factura_id = #{tipo_factura_id}")

    res.set_status(HTTP_STATUS_CODE[:conflict]) if paquete.blank?

    return res
  end

  # ============================================================================================================================================================
  def self.ver_si_existen_paquetes_posteriores(tipo_factura_id)
    res = Response.new

    paquete = SecuenciaComprobante
    .where("estado = false AND usado = false AND tipo_factura_id = #{tipo_factura_id}")
    .order("created_at ASC").limit(1)

    unless paquete.blank?
      res.set_data(paquete.first)
    else
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

  # ============================================================================================================================================================
  def self.validar_rango(id, paquete_ingresando, tipo)
		res = Response.new

    tipo_factura_id = paquete_ingresando["tipo_factura_id"]

    select_ = "select *"
    from_ = "from secuencia_comprobantes"
    where_ = "where tipo_factura_id = #{tipo_factura_id}"
    order_ = "ORDER BY created_at ASC"
    query = "#{select_} #{from_} #{where_} #{order_}"
    paquetes_registrados = my_query(query)


    paquetes_registrados.each do |paquete|
      if tipo == 'new'
        if paquete_ingresando["desde"] <= paquete["hasta"]
					res.add_msg("Numeros introducidos existen en el paquete con el codigo ##{("%05d" % paquete["id"])}.")
					res.set_status(HTTP_STATUS_CODE[:conflict])
          break
        end
      else
        if id != paquete["id"]
          if (paquete_ingresando["desde"] <= paquete["hasta"] && paquete_ingresando["hasta"] >= paquete["desde"]) || (paquete_ingresando["desde"] >= paquete["desde"] && paquete_ingresando["desde"] <= paquete["hasta"])
						res.add_msg("Numeros introducidos existen en el paquete con el codigo ##{("%05d" % paquete["id"])}.")
						res.set_status(HTTP_STATUS_CODE[:conflict])
            break
          end
        end
      end
    end

    return res
  end

  # ============================================================================================================================================================

end
