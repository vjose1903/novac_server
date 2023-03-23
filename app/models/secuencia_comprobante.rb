class SecuenciaComprobante < ApplicationRecord
  belongs_to :tipo_factura

  validates :desde,    numericality: { less_than_or_equal_to: :hasta, :message => "El inicio del paquete no puede ser mayor al final del mismo."}
  validates :desde,    numericality: { other_than: :hasta, :message => "El final del paquete debe de ser mayor al inicio del mismo."}

  # =========================================================================================================================================================

  def self.models_includes
    includes = [:tipo_factura]
    return includes
  end

  # =========================================================================================================================================================

  def self.create_update_ncf(params , is_save=false)

    res                        = Response.new
    res_valid                  = Response.new
    SecuenciaComprobante.transaction do

      ncf                      = SecuenciaComprobante.where(:id => params["id"]).first_or_create

      if ncf.estado && params["desde"] != ncf.desde
        res.add_msg("Este paquete ya esta en uso no puede cambiar el inicio del paquete.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
      end

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

      if ncf.errors.empty? && res.status_valid
        res_valid = SecuenciaComprobante.validar_rango(ncf, params["action"])

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

      transaction_rollback if !ncf.errors.empty? || !res.status_valid
    end

    return res
  end

    # ============================================================================================================================================================

    def self.filtrar_ncf(arg, params)
      res = Response.new(params)

      paquetes = SecuenciaComprobante
      .joins("inner join tipo_facturas on secuencia_comprobantes.tipo_factura_id = tipo_facturas.id")
      .where("lower(tipo_facturas.descripcion  || ' ' || secuencia_comprobantes.desde || ' ' || secuencia_comprobantes.hasta) like lower('%#{arg}%')")
      .order("secuencia_comprobantes.id DESC")

      if paquetes.length > 0
        res.set_data(paquetes, {all: true}, SecuenciaComprobante.models_includes)
      else
        res.set_data([])
        cantidad_registros = SecuenciaComprobante.all.count
        res.add_msg(cantidad_registros == 0 ? "No existen paquetes de comprobantes registrados." : "No existe paquetes de comprobantes con las especificaciones introducidas")
        res.set_status(HTTP_STATUS_CODE[:conflict])
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
  def self.validar_rango(paquete_ingresando, tipo)
    res              = Response.new
    id               = paquete_ingresando["id"]
    tipo_factura_id  = paquete_ingresando["tipo_factura_id"]

    query = "hasta between #{paquete_ingresando["desde"]} AND #{paquete_ingresando["hasta"]}"
    query += id.nil? ? "" : "id != #{id}"

    anothers_comprobantes = SecuenciaComprobante.where({tipo_factura_id: tipo_factura_id}).where(query).order('id ASC')

    anothers_comprobantes.each do | paquete |

      comparations = {:create => paquete_ingresando["desde"] <= paquete.hasta, :update => (paquete_ingresando["desde"] <= paquete.hasta && paquete_ingresando["hasta"] >= paquete.desde) || (paquete_ingresando["desde"] >= paquete.desde && paquete_ingresando["desde"] <= paquete.hasta) }.with_indifferent_access

      if comparations[tipo]
        res.add_msg("Numeros introducidos existen en el paquete con el codigo ##{("%05d" % paquete.id)}.")
        res.set_status(HTTP_STATUS_CODE[:conflict])
        break
      end
    end

    return res
  end

  # ============================================================================================================================================================

end
